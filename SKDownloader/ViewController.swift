//
//  ViewController.swift
//  SKDownloader
//
//  Created by liupeng on 11/19/15.
//  Copyright © 2015 liupeng. All rights reserved.
//

import Cocoa
import SKDownloaderFramework

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }
    
    @IBAction func download(sender: NSButton) {
        if let item = SKDownloaderDatabase.sharedDatabase.getDownloadItemByUrl("http://devstreaming.apple.com/videos/wwdc/2014/101xx36lr6smzjo/101/101_hd.mov") {
            SKDownloaderManager.SharedDownloaderManager().cancelDownload(item)
        }
       
        let item: SKDownloadItem = SKDownloadItem(title: "WWDC 2014 Keynote", summary: "Keynote", downloadURL: "http://devstreaming.apple.com/videos/wwdc/2014/101xx36lr6smzjo/101/101_hd.mov")
        SKDownloaderManager.SharedDownloaderManager().download(item)
        
        let w: SKDownloadListWindowController = SKDownloadListWindowController()
        w.showWindow(sender)
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

