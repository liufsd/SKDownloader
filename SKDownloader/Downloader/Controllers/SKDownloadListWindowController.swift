//
//  SKDownloadListWindowController.swift
//  SKDownloader
//
//  Created by liupeng on 11/19/15.
//  Copyright © 2015 liupeng. All rights reserved.
//

import Cocoa

private let SKDownloadListCellIdentifier = "SKDownloadListCellIdentifier"


public class SKDownloadListWindowController: NSWindowController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet var tableView: NSTableView!
    
    private var items: [SKDownloadListItem] = []
    private var downloadStartedHndl: AnyObject?
    private var downloadFinishedHndl: AnyObject?
    private var downloadChangedHndl: AnyObject?
    private var downloadCancelledHndl: AnyObject?
    private var downloadPausedHndl: AnyObject?
    private var downloadResumedHndl: AnyObject?
    
    private var fileSizeFormatter: NSByteCountFormatter!
    private var percentFormatter: NSNumberFormatter!
    
    override public func windowDidLoad() {
        super.windowDidLoad()
        self.tableView.setDelegate(self)
        self.tableView.setDataSource(self)
        self.tableView.columnAutoresizingStyle = .FirstColumnOnlyAutoresizingStyle
        
        fileSizeFormatter = NSByteCountFormatter()
        fileSizeFormatter.zeroPadsFractionDigits = true
        fileSizeFormatter.allowsNonnumericFormatting = false
        
        percentFormatter = NSNumberFormatter()
        percentFormatter.numberStyle = .PercentStyle
        percentFormatter.minimumFractionDigits = 1
        
        let nc = NSNotificationCenter.defaultCenter()
        self.downloadStartedHndl = nc.addObserverForName(FileStoreNotificationDownloadStarted, object: nil, queue: NSOperationQueue.mainQueue()) { note in
            let url = note.object as! String?
            if url != nil {
                let (item, _) = self.listItemForURL(url)
                if item != nil {
                    return
                }
                let tasks = self.fileStore.allTasks()
                for task in tasks {
                    if let _url = task.originalRequest?.URL?.absoluteString where _url == url {
                        guard let downloadItem = SKDownloaderDatabase.sharedDatabase.realm.objects(SKDownloadItem.self).filter("downloadURL = %@", _url).first else { return }
                        let item = SKDownloadListItem(url: url!, downloadItem: downloadItem, task: task)
                        self.items.append(item)
                        self.tableView.insertRowsAtIndexes(NSIndexSet(index: self.items.count), withAnimation: .SlideUp)
                    }
                }
            }
        }
        self.downloadFinishedHndl = nc.addObserverForName(FileStoreNotificationDownloadFinished, object: nil, queue: NSOperationQueue.mainQueue()) { note in
            if let object = note.object as? String {
                let url = object as String
                let (item, idx) = self.listItemForURL(url)
                if item != nil {
                    self.items.remove(item!)
                    self.tableView.removeRowsAtIndexes(NSIndexSet(index: idx), withAnimation: .SlideDown)
                }
            }
        }
        self.downloadChangedHndl = nc.addObserverForName(FileStoreNotificationDownloadProgressChanged, object: nil, queue: NSOperationQueue.mainQueue()) { note in
            if let info = note.userInfo {
                if let object = note.object as? String {
                    let url = object as String
                    let (item, idx) = self.listItemForURL(url)
                    if let item = item {
                        if let expected = info["totalBytesExpectedToWrite"] as? Int,
                            let written = info["totalBytesWritten"] as? Int
                        {
                            item.downloadedSize = written
                            item.totalSize = expected
                            self.tableView.reloadDataForRowIndexes(NSIndexSet(index: idx), columnIndexes: NSIndexSet(index: 0))
                        }
                    }
                }
            }
        }
        self.downloadCancelledHndl = nc.addObserverForName(FileStoreNotificationDownloadCancelled, object: nil, queue: NSOperationQueue.mainQueue()) { note in
            if let object = note.object as? String {
                let url = object as String
                let (item, _) = self.listItemForURL(url)
                if item != nil {
                    self.items.remove(item!)
                    self.tableView.removeRowsAtIndexes(NSIndexSet(index: self.tableView.selectedRow), withAnimation: .EffectGap)
                }
            }
        }
        self.downloadPausedHndl = nc.addObserverForName(FileStoreNotificationDownloadPaused, object: nil, queue: NSOperationQueue.mainQueue()) { note in
            if let object = note.object as? String {
                let url = object as String
                let (item, idx) = self.listItemForURL(url)
                if item != nil {
                    self.tableView.reloadDataForRowIndexes(NSIndexSet(index: idx), columnIndexes: NSIndexSet(index: 0))
                }
            }
        }
        self.downloadResumedHndl = nc.addObserverForName(FileStoreNotificationDownloadResumed, object: nil, queue: NSOperationQueue.mainQueue()) { note in
            if let object = note.object as? String {
                let url = object as String
                let (item, idx) = self.listItemForURL(url)
                if item != nil {
                    self.tableView.reloadDataForRowIndexes(NSIndexSet(index: idx), columnIndexes: NSIndexSet(index: 0))
                }
            }
        }
    }
    
    private func listItemForURL(url: String!) -> (SKDownloadListItem?, Int) {
        for (idx, item) in self.items.enumerate() {
            if item.url == url {
                return (item, idx)
            }
        }
        return (nil, NSNotFound)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self.downloadStartedHndl!)
        NSNotificationCenter.defaultCenter().removeObserver(self.downloadFinishedHndl!)
        NSNotificationCenter.defaultCenter().removeObserver(self.downloadChangedHndl!)
        NSNotificationCenter.defaultCenter().removeObserver(self.downloadCancelledHndl!)
        NSNotificationCenter.defaultCenter().removeObserver(self.downloadPausedHndl!)
        NSNotificationCenter.defaultCenter().removeObserver(self.downloadResumedHndl!)
    }
    
    override public func showWindow(sender: AnyObject?) {
        super.showWindow(sender)
        self.items.removeAll(keepCapacity: false)
        self.items = SKDownloaderManager.SharedDownloaderManager().getAllDownloadListItems()
        self.tableView.reloadData()
    }
    
    var fileStore: SKFileStore {
        get {
            return SKFileStore.SharedStore()
        }
    }
    
    convenience init() {
        self.init(windowNibName: "SKDownloadListWindowController")
    }
    
    public func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.items.count
    }
    
    public func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let identifier = tableColumn?.identifier
        let cellView = tableView.makeViewWithIdentifier(identifier!, owner: self) as! SKDownloadListCellView
        let item = self.items[row]
        
        cellView.textField?.stringValue = " \(item.downloadItem.title) - \(item.downloadItem.summary)"
        
        if item.progress > 0 {
            if cellView.started == false {
                cellView.startProgress()
            }
            cellView.progressIndicator.doubleValue = item.progress * 100
        }
        cellView.item = item
        
        cellView.cancelBlock = { [weak self] item, cell in
            let listItem = item as! SKDownloadListItem
            let task = listItem.task
            switch task.state {
            case .Running:
                self?.fileStore.pauseDownload(listItem.url)
            case .Suspended:
                self?.fileStore.resumeDownload(listItem.url)
            default: break
            }
        };
        
        var statusText: String?
        
        switch item.task.state {
        case .Running:
            cellView.progressIndicator.indeterminate = false
            cellView.cancelButton.image = NSImage(named: "NSStopProgressFreestandingTemplate")
            cellView.cancelButton.toolTip = NSLocalizedString("Pause", comment: "pause button tooltip in downloads window")
            
            statusText = NSLocalizedString("Downloading", comment: "video downloading status in downloads window")
        case .Suspended:
            cellView.progressIndicator.indeterminate = true
            cellView.cancelButton.image = NSImage(named: "NSRefreshFreestandingTemplate")
            cellView.cancelButton.toolTip = NSLocalizedString("Resume", comment: "resume button tooltip in downloads window")
            
            statusText = NSLocalizedString("Paused", comment: "video paused status in downloads window")
        default: break
        }
        
        if let statusText = statusText {
            if let totalSize = item.totalSize {
                let downloaded = fileSizeFormatter.stringFromByteCount(Int64(item.downloadedSize))
                let total = fileSizeFormatter.stringFromByteCount(Int64(totalSize))
                let progress = percentFormatter.stringFromNumber(item.progress) ?? "? %"
                
                cellView.statusLabel.stringValue = "\(statusText) – \(downloaded) / \(total) (\(progress))"
            } else {
                cellView.statusLabel.stringValue = statusText
            }
        }
        
        return cellView
    }
    
    func delete(sender: AnyObject?) {
        let item = self.items[tableView.selectedRow]
        self.fileStore.cancelDownload(item.url)
    }
    
}