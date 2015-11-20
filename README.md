# SKDownloader
    downloader for mac

# SKDownloaderFramework.framework

    dependencies:

	Realm.framework
	RealmSwift.framework
	
# SKDownloaderFramework 

   1. download/pause/resume/cancel
        
        let item: SKDownloadItem = SKDownloadItem(title: "WWDC 2014 Keynote", summary: "Keynote", downloadURL: "http://devstreaming.apple.com/videos/wwdc/2014/101xx36lr6smzjo/101/101_hd.mov")
       
        SKDownloaderManager.SharedDownloaderManager().download(item)
   
        
   2. SKDownloadListWindowController
        
        let w: SKDownloadListWindowController = SKDownloadListWindowController()
        w.showWindow(sender)
        