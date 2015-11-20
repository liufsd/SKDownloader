//
//  SKFileStore.swift
//  SKDownloader
//
//  Created by liupeng on 11/20/15.
//  Copyright © 2015 liupeng. All rights reserved.
//

import Cocoa

public let FileStoreDownloadedFilesChangedNotification = "FileStoreDownloadedFilesChangedNotification"
public let FileStoreNotificationDownloadStarted = "FileStoreNotificationDownloadStarted"
public let FileStoreNotificationDownloadCancelled = "FileStoreNotificationDownloadCancelled"
public let FileStoreNotificationDownloadPaused = "FileStoreNotificationDownloadPaused"
public let FileStoreNotificationDownloadResumed = "FileStoreNotificationDownloadResumed"
public let FileStoreNotificationDownloadFinished = "FileStoreNotificationDownloadFinished"
public let FileStoreNotificationDownloadProgressChanged = "FileStoreNotificationDownloadProgressChanged"

private let _SharedFileStore = SKFileStore()
private let _BackgroundSessionIdentifier = "SKFileStore Downloader"

public class SKFileStore : NSObject, NSURLSessionDownloadDelegate {

    private let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(_BackgroundSessionIdentifier)
    private var backgroundSession: NSURLSession!
    private var downloadTasks: [String : NSURLSessionDownloadTask] = [:]
    private let defaults = NSUserDefaults.standardUserDefaults()
    
   public class func SharedStore() -> SKFileStore
    {
        return _SharedFileStore;
    }
    
    override init() {
        super.init()
        backgroundSession = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
    }
    
    public func initialize() {
        backgroundSession.getTasksWithCompletionHandler { _, _, pendingTasks in
            for task in pendingTasks {
                if let key = task.originalRequest?.URL!.absoluteString {
                    self.downloadTasks[key] = task
                }
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(LocalVideoStoragePathPreferenceChangedNotification, object: nil, queue: nil) { _ in
            self.monitorDownloadsFolder()
            NSNotificationCenter.defaultCenter().postNotificationName(FileStoreDownloadedFilesChangedNotification, object: nil)
        }
        
        monitorDownloadsFolder()
    }
    
    // MARK: Public interface
	
	func allTasks() -> [NSURLSessionDownloadTask] {
		return Array(self.downloadTasks.values)
	}
	
    func download(url: String) -> Bool {
        if isDownloading(url) {
            return false
        }
        
        let task = backgroundSession.downloadTaskWithURL(NSURL(string: url)!)
		if let key = task.originalRequest?.URL!.absoluteString {
			self.downloadTasks[key] = task
		}
        task.resume()
		
        NSNotificationCenter.defaultCenter().postNotificationName(FileStoreNotificationDownloadStarted, object: url)
        return true
    }
    
    func pauseDownload(url: String) -> Bool {
        if let task = downloadTasks[url] {
			task.suspend()
			NSNotificationCenter.defaultCenter().postNotificationName(FileStoreNotificationDownloadPaused, object: url)
			return true
        }
		print("FileStore was asked to pause downloading URL \(url), but there's no task for that URL")
		return false
    }
	
	func resumeDownload(url: String) -> Bool {
		if let task = downloadTasks[url] {
			task.resume()
			NSNotificationCenter.defaultCenter().postNotificationName(FileStoreNotificationDownloadResumed, object: url)
			return true
		}
		print("FileStore was asked to resume downloading URL \(url), but there's no task for that URL")
		return false
	}
	
	func cancelDownload(url: String) -> Bool {
		if let task = downloadTasks[url] {
			task.cancel()
			self.downloadTasks.removeValueForKey(url)
			NSNotificationCenter.defaultCenter().postNotificationName(FileStoreNotificationDownloadCancelled, object: url)
			return true
		}
		print("FileStore was asked to cancel downloading URL \(url), but there's no task for that URL")
		return false
	}
	
    func isDownloading(url: String) -> Bool {
        let downloading = downloadTasks.keys.filter { taskURL in
            return url == taskURL
        }

        return (downloading.count > 0)
    }
    
    func localVideoPath(remoteURL: String) -> String {
        return (SKPreferences.SharedPreferences().localVideoStoragePath as NSString).stringByAppendingPathComponent((remoteURL as NSString).lastPathComponent)
    }
    
    func localVideoAbsoluteURLString(remoteURL: String) -> String {
        return NSURL(fileURLWithPath: localVideoPath(remoteURL)).absoluteString
    }
    
    func hasVideo(url: String) -> Bool {
        return (NSFileManager.defaultManager().fileExistsAtPath(localVideoPath(url)))
    }
    
    // MARK: URL Session
    
    public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        let originalURL = downloadTask.originalRequest!.URL!
        let originalAbsoluteURLString = originalURL.absoluteString

        let fileManager = NSFileManager.defaultManager()
        
        if (fileManager.fileExistsAtPath(SKPreferences.SharedPreferences().localVideoStoragePath) == false) {
            do {
                try fileManager.createDirectoryAtPath(SKPreferences.SharedPreferences().localVideoStoragePath, withIntermediateDirectories: false, attributes: nil)
            } catch _ {
            }
        }
        
        let localURL = NSURL(fileURLWithPath: localVideoPath(originalAbsoluteURLString))
        
        do {
            try fileManager.moveItemAtURL(location, toURL: localURL)
        } catch _ {
            print("FileStore was unable to move \(location) to \(localURL)")
        }
        
        downloadTasks.removeValueForKey(originalAbsoluteURLString)
        
        NSNotificationCenter.defaultCenter().postNotificationName(FileStoreNotificationDownloadFinished, object: originalAbsoluteURLString)
    }
    
    public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let originalURL = downloadTask.originalRequest!.URL!.absoluteString

        let info = ["totalBytesWritten": Int(totalBytesWritten), "totalBytesExpectedToWrite": Int(totalBytesExpectedToWrite)]
        NSNotificationCenter.defaultCenter().postNotificationName(FileStoreNotificationDownloadProgressChanged, object: originalURL, userInfo: info)
    }
    
    // MARK: File observation
    
    var folderMonitor: DTFolderMonitor!
    
    func monitorDownloadsFolder() {
        if folderMonitor != nil {
            folderMonitor.stopMonitoring()
            folderMonitor = nil
        }
        
        folderMonitor = DTFolderMonitor(forURL: NSURL(fileURLWithPath: SKPreferences.SharedPreferences().localVideoStoragePath)) {
            NSNotificationCenter.defaultCenter().postNotificationName(FileStoreDownloadedFilesChangedNotification, object: nil)
        }
        folderMonitor.startMonitoring()
    }
    
    // MARK: Teardown
    
    deinit {
        if folderMonitor != nil {
            folderMonitor.stopMonitoring()
        }
    }
    
    
}

