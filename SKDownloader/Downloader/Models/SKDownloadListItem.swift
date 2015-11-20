//
//  DownloadListItem.swift
//  SKDownloader
//
//  Created by liupeng on 11/19/15.
//  Copyright © 2015 liupeng. All rights reserved.
//

import Cocoa

class SKDownloadListItem: NSObject {

    let url: String
    let downloadItem: SKDownloadItem
    let task: NSURLSessionDownloadTask
    var totalSize: Int?
    var downloadedSize: Int = 0
    
    var progress: Double {
        if let totalSize = totalSize where totalSize > 0 {
            return Double(downloadedSize) / Double(totalSize)
        } else {
            return 0
        }
    }
    
    init(url: String, downloadItem: SKDownloadItem, task: NSURLSessionDownloadTask) {
        self.url = url
        self.downloadItem = downloadItem
        self.task = task
    }
    
}
