//
//  AppDelegate.swift
//  SKDownloader
//
//  Created by liupeng on 11/19/15.
//  Copyright © 2015 liupeng. All rights reserved.
//

import Cocoa
import SKDownloaderFramework

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        // continue any paused downloads
        SKFileStore.SharedStore().initialize()
  
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

