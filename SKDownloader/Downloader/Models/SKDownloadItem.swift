//
//  SKDownloadItem.swift
//  SKDownloader
//
//  Created by liupeng on 11/19/15.
//  Copyright © 2015 liupeng. All rights reserved.
//

import Foundation
import RealmSwift

public class SKDownloadItem: Object {
    dynamic var title = ""
    dynamic var summary = ""
    dynamic var downloadURL = ""
    dynamic var progress = 0.0
    dynamic var downloaded = false
    dynamic var createTime = 0
    
    convenience required public init(title: String, summary: String, downloadURL: String) {
        self.init()
        self.title = title
        self.summary = summary
        self.downloadURL = downloadURL
    }
    
    override public static func primaryKey() -> String? {
        return "downloadURL"
    }
    
    override public static func indexedProperties() -> [String] {
        return ["title"]
    }
    
}
