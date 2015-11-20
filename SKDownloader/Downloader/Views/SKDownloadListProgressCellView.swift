//
//  SKDownloadListCellView.swift
//  SKDownloader
//
//  Created by liupeng on 11/20/15.
//  Copyright © 2015 liupeng. All rights reserved.
//
import Cocoa

class SKDownloadListCellView: NSTableCellView {
	
	weak var item: AnyObject?
	var cancelBlock: ((AnyObject?, SKDownloadListCellView) -> Void)?
	var started: Bool = false
	
	@IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var cancelButton: NSButton!
	
	@IBAction func cancelBtnPressed(sender: NSButton) {
		if let block = self.cancelBlock {
			block(self.item, self)
		}
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		self.progressIndicator.indeterminate = true
		self.progressIndicator.startAnimation(nil)
	}
	
	func startProgress() {
		if (self.started) {
			return
		}
		self.progressIndicator.indeterminate = false
		self.started = true
	}
	
}
