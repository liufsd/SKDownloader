//
//  SKPreferences.swift
//  SKDownloader
//
//  Created by liupeng on 11/20/15.
//  Copyright © 2015 liupeng. All rights reserved.
//

import Cocoa

let LocalVideoStoragePathPreferenceChangedNotification = "LocalVideoStoragePathPreferenceChangedNotification"

private let _SharedPreferences = SKPreferences();

class SKPreferences {
    
    class func SharedPreferences() -> SKPreferences {
        return _SharedPreferences
    }
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    private let nc = NSNotificationCenter.defaultCenter()
    
    // keys for NSUserDefault's dictionary
    private struct Keys {
        static let mainWindowFrame = "mainWindowFrame"
        static let localVideoStoragePath = "localVideoStoragePath"
     }
    
    // default values if preferences were not set
    private struct DefaultValues {
        static let localVideoStoragePath = NSString.pathWithComponents([NSHomeDirectory(), "Library", "Application Support", "SKDownloader"])
    }
    
    // the main window's frame
    var mainWindowFrame: NSRect {
        set {
            defaults.setObject(NSStringFromRect(newValue), forKey: Keys.mainWindowFrame)
        }
        get {
            if let rectString = defaults.objectForKey(Keys.mainWindowFrame) as? String {
                return NSRectFromString(rectString)
            } else {
                return NSZeroRect
            }
        }
    }
    
    
    // where to save downloaded videos
    var localVideoStoragePath: String {
        set {
            defaults.setObject(newValue, forKey: Keys.localVideoStoragePath)
            nc.postNotificationName(LocalVideoStoragePathPreferenceChangedNotification, object: newValue)
        }
        get {
            if let path = defaults.objectForKey(Keys.localVideoStoragePath) as? String {
                return path
            } else {
                return DefaultValues.localVideoStoragePath
            }
        }
    }
    
 }