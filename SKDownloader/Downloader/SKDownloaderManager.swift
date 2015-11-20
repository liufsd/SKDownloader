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
        if SKFileStore.SharedStore().download(item.downloadURL) {
            SKDownloaderDatabase.sharedDatabase.addDownloadItem(item)
        }
    }
    
    public func pauseDownload(item: SKDownloadItem) -> Bool {
        return  SKFileStore.SharedStore().pauseDownload(item.downloadURL)
    }
    
    public func resumeDownload(item: SKDownloadItem) -> Bool {
        return  SKFileStore.SharedStore().resumeDownload(item.downloadURL)
    }
    
    public func cancelDownload(item: SKDownloadItem) -> Bool {
        let cancel = SKFileStore.SharedStore().cancelDownload(item.downloadURL)
        if cancel {
            SKDownloaderDatabase.sharedDatabase.deleteDownloadItem(item)
        }
        return cancel
    }
    
    public func isDownloading(item: SKDownloadItem) -> Bool {
        return  SKFileStore.SharedStore().isDownloading(item.downloadURL)
    }
 
}
