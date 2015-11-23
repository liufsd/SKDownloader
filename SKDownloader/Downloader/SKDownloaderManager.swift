//
//  SKDownloaderManager.swift
//  SKDownloader
//
//  Created by liupeng on 11/20/15.
//  Copyright © 2015 liupeng. All rights reserved.
//

import Cocoa

private let _SharedDownloaderManager = SKDownloaderManager()

public class SKDownloaderManager: NSObject {
    
    public class func SharedDownloaderManager() -> SKDownloaderManager
    {
        return _SharedDownloaderManager;
    }
    
    override init() {
        super.init()
        
    }
    
    public func download(item: SKDownloadItem) {
        if getSKFileStore().download(item.downloadURL) {
            SKDownloaderDatabase.sharedDatabase.addDownloadItem(item)
        }
    }
    
    public func pauseDownload(item: SKDownloadItem) -> Bool {
        return  getSKFileStore().pauseDownload(item.downloadURL)
    }
    
    public func resumeDownload(item: SKDownloadItem) -> Bool {
        return  getSKFileStore().resumeDownload(item.downloadURL)
    }
    
    public func cancelDownload(item: SKDownloadItem) -> Bool {
        let cancel = getSKFileStore().cancelDownload(item.downloadURL)
        if cancel {
            SKDownloaderDatabase.sharedDatabase.deleteDownloadItem(item)
        }
        return cancel
    }
    
    public func isDownloading(item: SKDownloadItem) -> Bool {
        return  getSKFileStore().isDownloading(item.downloadURL)
    }
    
    public func getAllDownloadListItems() -> [SKDownloadListItem] {
        var items: [SKDownloadListItem] = []
        let tasks = getSKFileStore().allTasks()
        for task in tasks {
            guard let url = task.originalRequest?.URL?.absoluteString else { continue }
            guard let downloadItem = SKDownloaderDatabase.sharedDatabase.realm.objects(SKDownloadItem.self).filter("downloadURL = %@", url).first else { continue }
            let item = SKDownloadListItem(url: url, downloadItem: downloadItem, task: task)
            items.append(item)
        }
        return items
    }
    
    public func getSKFileStore() -> SKFileStore {
        return SKFileStore.SharedStore()
    }
 
}
