//
//  SKDownloaderDatabase.swift
//  SKDownloader
//
//  Created by liupeng on 11/19/15.
//  Copyright © 2015 liupeng. All rights reserved.
//

import Foundation
import RealmSwift

func mainQS(block: () -> ()) {
    dispatch_sync(dispatch_get_main_queue(), block)
}
func mainQ(block: () -> ()) {
    dispatch_async(dispatch_get_main_queue(), block)
}

private let _sharedDownloaderDatabase = SKDownloaderDatabase()


@objc public class SKDownloaderDatabase: NSObject {

   public class var sharedDatabase: SKDownloaderDatabase {
        return _sharedDownloaderDatabase
    }

    
    let realm = try! Realm()
    
    /// Returns the list of sessions available sorted by year and session id
    /// - Warning: can only be used from the main thread
    var standardDownloadItemList: Results<SKDownloadItem> {
        return realm.objects(SKDownloadItem.self).sorted(sortDescriptorsForSessionList)
    }
    
    /// #### The best sort descriptors for the list of videos
    /// Orders the DownloadItems by createTime (descending)
    lazy var sortDescriptorsForSessionList: [SortDescriptor] = [SortDescriptor(property: "createTime", ascending: false)]
    
    
    /// save download item
   public func addDownloadItem(item: SKDownloadItem) {
        let backgroundRealm = try! Realm()
        if backgroundRealm.objectForPrimaryKey(SKDownloadItem.self, key: item.downloadURL) == nil {
         //new item
        }
        backgroundRealm.beginWrite()
        backgroundRealm.add(item, update: true)
        try!  backgroundRealm.commitWrite()
    }
    
     /// delete download item
   public func deleteDownloadItem(item: SKDownloadItem) {
        let backgroundRealm = try! Realm()
        backgroundRealm.beginWrite()
        backgroundRealm.delete(item)
        try!  backgroundRealm.commitWrite()
    }
    
     /// delete download item by url
   public func deleteDownloadItemByUrl(url: String) {
        let backgroundRealm = try! Realm()
        if let item = SKDownloaderDatabase.sharedDatabase.getDownloadItemByUrl(url) {
            backgroundRealm.beginWrite()
            backgroundRealm.delete(item)
            try!  backgroundRealm.commitWrite()
        }
    }
    
     /// get download item
   public func getDownloadItemByUrl(url: String) -> SKDownloadItem? {
        let backgroundRealm = try! Realm()
        return backgroundRealm.objectForPrimaryKey(SKDownloadItem.self, key: url)
    }
}
