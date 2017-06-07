//
//  WebViewController.swift
//  Helium
//
//  Created by Jaden Geller on 4/9/15.
//  Copyright (c) 2015 Jaden Geller. All rights reserved.
//

import Cocoa
import WebKit
import AVFoundation

class MyWebView : WKWebView {
	internal func menuClicked(sender: AnyObject) {
		if let menuItem = sender as? NSMenuItem {
			Swift.print("Menu \(menuItem.title) clicked")
		}
	}

	override func willOpenMenu(menu: NSMenu, withEvent event: NSEvent) {
		let wc = self.window?.windowController as! HeliumPanelController
		menu.addItem(NSMenuItem.separatorItem())
		var item = NSMenuItem()
		item.title = "Preferences"
		item.indentationLevel = 0
		item.target = self
		menu.addItem(item)

		// Switch to submenu
		let subMenu = NSMenu()
		item.submenu = subMenu

		item = NSMenuItem(title: "Home Page", action: #selector(HeliumPanelController.setHomePage(_:)), keyEquivalent: "")
		item.target = wc
		subMenu.addItem(item)

		item = NSMenuItem(title: "Open", action: #selector(menuClicked(_:)), keyEquivalent: "")
		subMenu.addItem(item)
		let subOpen = NSMenu()
		item.submenu = subOpen

		item = NSMenuItem(title: "File", action: #selector(HeliumPanelController.openFilePress(_:)), keyEquivalent: "")
		item.target = wc
		subOpen.addItem(item)

		item = NSMenuItem(title: "Location", action: #selector(HeliumPanelController.openLocationPress(_:)), keyEquivalent: "")
		item.target = self.window?.windowController
		subOpen.addItem(item)

		subMenu.addItem(NSMenuItem.separatorItem())

		item = NSMenuItem(title: "Float Above All Spaces", action: #selector(HeliumPanelController.floatOverFullScreenAppsToggled(_:)), keyEquivalent: "")
		item.state = 1 - NSUserDefaults.standardUserDefaults().integerForKey(UserSetting.DisabledFullScreenFloat.userDefaultsKey)
		item.target = wc
		subMenu.addItem(item)
		
		item = NSMenuItem(title: "Magic URL Redirects", action: #selector(AppDelegate.magicURLRedirectToggled(_:)), keyEquivalent: "")
		item.state = 1 - NSUserDefaults.standardUserDefaults().integerForKey(UserSetting.DisabledMagicURLs.userDefaultsKey)
		item.target = NSApp.delegate
		subMenu.addItem(item)

		item = NSMenuItem(title: "Title Bar", action: #selector(menuClicked(_:)), keyEquivalent: "")
		subMenu.addItem(item)
		let subTitleBar = NSMenu()
		item.submenu = subTitleBar

		item = NSMenuItem(title: "Auto Hide", action: #selector(HeliumPanelController.autoHideTitle(_:)), keyEquivalent: "b")
		item.state = NSUserDefaults.standardUserDefaults().integerForKey(UserSetting.AutoHideTitle.userDefaultsKey)
		item.target = wc
		subTitleBar.addItem(item)

		item = NSMenuItem(title: "Translucency", action: #selector(menuClicked(_:)), keyEquivalent: "")
		subMenu.addItem(item)
		let subTranslucency = NSMenu()
		item.submenu = subTranslucency

		item = NSMenuItem(title: "Enabled", action: #selector(HeliumPanelController.translucencyPress(_:)), keyEquivalent: "t")
		item.state = wc.translucencyEnabled == true ? NSOnState : NSOffState
		item.target = wc
		subTranslucency.addItem(item)

		item = NSMenuItem(title: "Opacity", action: #selector(menuClicked(_:)), keyEquivalent: "")
		let opacity = NSUserDefaults.standardUserDefaults().integerForKey(UserSetting.OpacityPercentage.userDefaultsKey)
		subTranslucency.addItem(item)
		let subOpacity = NSMenu()
		item.submenu = subOpacity

		item = NSMenuItem(title: "10%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "1")
		item.state = (10 == opacity ? NSOnState : NSOffState)
		item.target = wc
		subOpacity.addItem(item)
		item = NSMenuItem(title: "20%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "2")
		item.state = (20 == opacity ? NSOnState : NSOffState)
		item.target = wc
		subOpacity.addItem(item)
		item = NSMenuItem(title: "30%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "3")
		item.state = (30 == opacity ? NSOnState : NSOffState)
		item.target = wc
		subOpacity.addItem(item)
		item = NSMenuItem(title: "40%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "4")
		item.state = (40 == opacity ? NSOnState : NSOffState)
		item.target = wc
		subOpacity.addItem(item)
		item = NSMenuItem(title: "50%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "5")
		item.state = (50 == opacity ? NSOnState : NSOffState)
		item.target = wc
		subOpacity.addItem(item)
		item = NSMenuItem(title: "60%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "6")
		item.state = (60 == opacity ? NSOnState : NSOffState)
		item.target = wc
		subOpacity.addItem(item)
		item = NSMenuItem(title: "70%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "7")
		item.state = (70 == opacity ? NSOnState : NSOffState)
		item.target = wc
		subOpacity.addItem(item)
		item = NSMenuItem(title: "80%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "8")
		item.state = (80 == opacity ? NSOnState : NSOffState)
		item.target = wc
		subOpacity.addItem(item)
		item = NSMenuItem(title: "90%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "9")
		item.state = (90 == opacity ? NSOnState : NSOffState)
		item.target = wc
		subOpacity.addItem(item)
		item = NSMenuItem(title: "100%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "0")
		item.state = (100 == opacity ? NSOnState : NSOffState)
		item.target = wc
		subOpacity.addItem(item)

		subTranslucency.addItem(NSMenuItem.separatorItem())
		let translucency: HeliumPanelController.TranslucencyPreference = wc.translucencyPreference

		item = NSMenuItem(title: "Always", action: #selector(HeliumPanelController.alwaysPreferencePress(_:)), keyEquivalent: "")
		item.state = translucency == .Always ? NSOnState : NSOffState
		item.target = wc
		subTranslucency.addItem(item)
		item = NSMenuItem(title: "Mouse Over", action: #selector(HeliumPanelController.overPreferencePress(_:)), keyEquivalent: "")
		item.state = translucency == .MouseOver ? NSOnState : NSOffState
		item.target = wc
		subTranslucency.addItem(item)
		item = NSMenuItem(title: "Mouse Outside", action: #selector(HeliumPanelController.outsidePreferencePress(_:)), keyEquivalent: "")
		item.state = translucency == .MouseOutside ? NSOnState : NSOffState
		item.target = wc
		subTranslucency.addItem(item)

		subMenu.addItem(NSMenuItem.separatorItem())

		item = NSMenuItem(title: "Playlists", action: #selector(WebViewController.presentPlaylistSheet(_:)), keyEquivalent: "")
		item.target = self.UIDelegate
		subMenu.addItem(item)
	}	
}

class WebViewController: NSViewController, WKNavigationDelegate {

    var trackingTag: NSTrackingRectTag?

    // MARK: View lifecycle
    func fit(childView: NSView, parentView: NSView) {
        childView.translatesAutoresizingMaskIntoConstraints = false
        childView.topAnchor.constraintEqualToAnchor(parentView.topAnchor).active = true
        childView.leadingAnchor.constraintEqualToAnchor(parentView.leadingAnchor).active = true
        childView.trailingAnchor.constraintEqualToAnchor(parentView.trailingAnchor).active = true
        childView.bottomAnchor.constraintEqualToAnchor(parentView.bottomAnchor).active = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WebViewController.loadURLObject(_:)), name: "HeliumLoadURL", object: nil)
        
        // Layout webview
        view.addSubview(webView)
        fit(webView, parentView: view)

        webView.frame = view.bounds
        webView.autoresizingMask = [NSAutoresizingMaskOptions.ViewHeightSizable, NSAutoresizingMaskOptions.ViewWidthSizable]
        
        // Allow plug-ins such as silverlight
        webView.configuration.preferences.plugInsEnabled = true
        
        // Custom user agent string for Netflix HTML5 support
        webView._customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/601.6.17 (KHTML, like Gecko) Version/9.1.1 Safari/601.6.17"
        
        // Setup magic URLs
        webView.navigationDelegate = self
        
        // Allow zooming
        webView.allowsMagnification = true
        
        // Alow back and forth
        webView.allowsBackForwardNavigationGestures = true
        
        // Listen for load progress
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.New, context: nil)

        // Listen for auto hide title changes
        NSUserDefaults.standardUserDefaults().addObserver(self, forKeyPath: UserSetting.AutoHideTitle.userDefaultsKey, options: NSKeyValueObservingOptions.New, context: nil)

        clear()
    }
    
    var lastStyle : Int = 0
    var lastTitle = "Helium"
    var autoHideTitle : Bool = NSUserDefaults.standardUserDefaults().boolForKey(UserSetting.AutoHideTitle.userDefaultsKey)

    override func mouseExited(theEvent: NSEvent) {
        if autoHideTitle {
            if lastStyle == 0 { lastStyle = (self.view.window?.styleMask)! }
            self.view.window!.titleVisibility = NSWindowTitleVisibility.Hidden;
            self.view.window?.styleMask = NSBorderlessWindowMask
        }
    }
    override func mouseEntered(theEvent: NSEvent) {
        if autoHideTitle {
            if lastStyle == 0 { lastStyle = (self.view.window?.styleMask)! }
            self.view.window!.titleVisibility = NSWindowTitleVisibility.Visible;
            self.view.window?.styleMask = lastStyle

            let notif = NSNotification(name: "HeliumUpdateTitle", object: lastTitle);
            NSNotificationCenter.defaultCenter().postNotification(notif)
        }
    }

    override func viewDidLayout() {
        super.viewDidLayout()

        if let tag = trackingTag {
            view.removeTrackingRect(tag)
        }

        if videoFileReferencedURL {
            let newSize = webView.bounds.size
            let aspect = webSize.height / webSize.width
            let magnify = newSize.width / webSize.width
            let newHeight = newSize.width * aspect
            let adjSize = NSMakeSize(newSize.width-1,newHeight-1)
			webView.setMagnification((magnify > 1 ? magnify : 1), centeredAtPoint: NSMakePoint(adjSize.width/2.0, adjSize.height/2.0))
            view.setBoundsSize(adjSize)
		}

        trackingTag = view.addTrackingRect(view.bounds, owner: self, userData: nil, assumeInside: false)
    }

    // MARK: Actions
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool{
        switch menuItem.title {
        case "Back":
            return webView.canGoBack
        case "Forward":
            return webView.canGoForward
        default:
            return true
        }
    }

	@IBAction func perferences(sender: AnyObject) {
		print("show preferences sheet")
	}
	
    @IBAction func backPress(sender: AnyObject) {
        webView.goBack()
    }
    
    @IBAction func forwardPress(sender: AnyObject) {
        webView.goForward()
    }
    
    private func zoomIn() {
        if !videoFileReferencedURL {
            webView.magnification += 0.1
        }
     }
    
    private func zoomOut() {
        if !videoFileReferencedURL {
            webView.magnification -= 0.1
        }
    }
    
    private func resetZoom() {
        if !videoFileReferencedURL {
            webView.magnification = 1
        }
    }

    @IBAction private func reloadPress(sender: AnyObject) {
        requestedReload()
    }
    
    @IBAction private func clearPress(sender: AnyObject) {
        clear()
    }
    
    @IBAction private func resetZoomLevel(sender: AnyObject) {
        resetZoom()
    }
    @IBAction private func zoomIn(sender: AnyObject) {
        zoomIn()
    }
    @IBAction private func zoomOut(sender: AnyObject) {
        zoomOut()
    }
    
    lazy var playlistViewController: PlaylistViewController = {
        return self.storyboard!.instantiateControllerWithIdentifier("PlaylistViewController")
            as! PlaylistViewController
    }()
    
    @IBAction func presentPlaylistSheet(sender: AnyObject) {
        self.presentViewControllerAsSheet(playlistViewController)
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    internal func loadAlmostURL( text_in: String) {
        var text = text_in
        if !(text.lowercaseString.hasPrefix("http://") || text.lowercaseString.hasPrefix("https://") || text.lowercaseString.hasPrefix("file://")) {
            text = "http://" + text
        }
        
        if let url = NSURL(string: text) {
            loadURL(url)
        }
        
    }
    
    // MARK: Loading
    
    internal func loadURL(url:NSURL) {
        webView.loadRequest(NSURLRequest(URL: url))
    }

    func playerDidFinishPlaying(note: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: note.object)
        print("Video Finished")
    }

    func loadURLObject(urlObject : NSNotification) {
        if let url = urlObject.object as? NSURL {
            loadAlmostURL(url.absoluteString);
        }
    }
    
    private func requestedReload() {
        webView.reload()
    }
    
    // MARK: Webview functions
    func clear() {
        // Reload to home page (or default if no URL stored in UserDefaults)
        if let homePage = NSUserDefaults.standardUserDefaults().stringForKey(UserSetting.HomePageURL.userDefaultsKey) {
            loadAlmostURL(homePage)
        }
        else{
            loadURL(NSURL(string: Constants.defaultURL)!)
        }
    }

    var webView = MyWebView()
    var webSize = CGSize(width: 0,height: 0)
    var shouldRedirect: Bool {
        get {
            return !NSUserDefaults.standardUserDefaults().boolForKey(UserSetting.DisabledMagicURLs.userDefaultsKey)
        }
    }
    
    // Redirect Hulu and YouTube to pop-out videos
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        
        if shouldRedirect, let url = navigationAction.request.URL {
            let urlString = url.absoluteString
            var modified = urlString
            modified = modified.replacePrefix("https://www.youtube.com/watch?v=", replacement: modified.containsString("list") ? "https://www.youtube.com/embed/?v=" : "https://www.youtube.com/embed/")
            modified = modified.replacePrefix("https://vimeo.com/", replacement: "http://player.vimeo.com/video/")
            modified = modified.replacePrefix("http://v.youku.com/v_show/id_", replacement: "http://player.youku.com/embed/")
            modified = modified.replacePrefix("https://www.twitch.tv/", replacement: "https://player.twitch.tv?html5&channel=")
            modified = modified.replacePrefix("http://www.dailymotion.com/video/", replacement: "http://www.dailymotion.com/embed/video/")
            modified = modified.replacePrefix("http://dai.ly/", replacement: "http://www.dailymotion.com/embed/video/")
 
            if modified.containsString("https://youtu.be") {
                modified = "https://www.youtube.com/embed/" + getVideoHash(urlString)
                if urlString.containsString("?t=") {
                        modified += makeCustomStartTimeURL(urlString)
                }
            }
            
            if urlString != modified {
                decisionHandler(WKNavigationActionPolicy.Cancel)
                loadURL(NSURL(string: modified)!)
                return
            }
        }
        
        decisionHandler(WKNavigationActionPolicy.Allow)
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation) {
        if let pageTitle = webView.title {
            var title = pageTitle;
            if title.isEmpty { title = "Helium" }
            let notif = NSNotification(name: "HeliumUpdateTitle", object: title);
            NSNotificationCenter.defaultCenter().postNotification(notif)
            lastTitle = title
        }
    }
    
    func webView(webView: WKWebView, didFinishLoad navigation: WKNavigation) {
    }
    
    var videoFileReferencedURL = false
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if object as! NSObject == webView && keyPath == "estimatedProgress" {
            if let progress = change?["new"] as? Float {
                let percent = progress * 100
                var title = NSString(format: "Loading... %.2f%%", percent)
                if percent == 100 {
                    videoFileReferencedURL = false
                    let url = (self.webView.URL)

                    // once loaded update window title,size with video name,dimension
                    if let urlTitle = (self.webView.URL?.absoluteString) {
                        title = urlTitle

                        if ((url?.isFileReferenceURL()) != nil) {

                            //    if it's a video file, get and set window content size to its dimentions
                            if let track0 : AVAssetTrack = AVURLAsset(URL:url!, options:nil).tracks[0] {
                                if track0.mediaType == AVMediaTypeVideo {
                                    title = url!.lastPathComponent!
                                    webSize = track0.naturalSize
                                    webView.window?.setContentSize(webSize)
                                    webView.bounds.size = webSize
                                    videoFileReferencedURL = true
                                }
                            }
                            
                            //  Wait for URL to finish
                            let videoPlayer = AVPlayer(URL: url!)
                            let item = videoPlayer.currentItem
                            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WebViewController.playerDidFinishPlaying(_:)),
                                                                             name: AVPlayerItemDidPlayToEndTimeNotification, object: item)
                        }
                    } else {
                        title = "Helium"
                    }
                    lastTitle = title as String
                }

                let notif = NSNotification(name: "HeliumUpdateTitle", object: title);
                NSNotificationCenter.defaultCenter().postNotification(notif)
            }
        }

        if (keyPath == UserSetting.AutoHideTitle.userDefaultsKey) {
            autoHideTitle = NSUserDefaults.standardUserDefaults().boolForKey(keyPath!)
            if autoHideTitle {
                if lastStyle == 0 { lastStyle = (self.view.window?.styleMask)! }
                self.view.window!.titleVisibility = NSWindowTitleVisibility.Hidden;
                self.view.window?.styleMask = NSBorderlessWindowMask
            } else {
                if lastStyle == 0 { lastStyle = (self.view.window?.styleMask)! }
                self.view.window!.titleVisibility = NSWindowTitleVisibility.Visible;
                self.view.window?.styleMask = lastStyle
            }

            let notif = NSNotification(name: "HeliumUpdateTitle", object: lastTitle);
            NSNotificationCenter.defaultCenter().postNotification(notif)
        }
        
    }
    
    //Convert a YouTube video url that starts at a certian point to popup/embedded design
    // (i.e. ...?t=1m2s --> ?start=62)
    private func makeCustomStartTimeURL(url: String) -> String {
        let startTime = "?t="
        let idx = url.indexOf(startTime)
        if idx == -1 {
            return url
        } else {
            var returnURL = url
            let timing = url.substringFromIndex(url.startIndex.advancedBy(idx+3))
            let hoursDigits = timing.indexOf("h")
            var minutesDigits = timing.indexOf("m")
            let secondsDigits = timing.indexOf("s")
            
            returnURL.removeRange(returnURL.startIndex.advancedBy(idx+1) ..< returnURL.endIndex)
            returnURL = "?start="
            
            //If there are no h/m/s params and only seconds (i.e. ...?t=89)
            if (hoursDigits == -1 && minutesDigits == -1 && secondsDigits == -1) {
                let onlySeconds = url.substringFromIndex(url.startIndex.advancedBy(idx+3))
                returnURL = returnURL + onlySeconds
                return returnURL
            }
            
            //Do check to see if there is an hours parameter.
            var hours = 0
            if (hoursDigits != -1) {
                hours = Int(timing.substringToIndex(timing.startIndex.advancedBy(hoursDigits)))!
            }
            
            //Do check to see if there is a minutes parameter.
            var minutes = 0
            if (minutesDigits != -1) {
                minutes = Int(timing.substringWithRange(timing.startIndex.advancedBy(hoursDigits+1) ..< timing.startIndex.advancedBy(minutesDigits)))!
            }
            
            if minutesDigits == -1 {
                minutesDigits = hoursDigits
            }
            
            //Do check to see if there is a seconds parameter.
            var seconds = 0
            if (secondsDigits != -1) {
                seconds = Int(timing.substringWithRange(timing.startIndex.advancedBy(minutesDigits+1) ..< timing.startIndex.advancedBy(secondsDigits)))!
            }
            
            //Combine all to make seconds.
            let secondsFinal = 3600*hours + 60*minutes + seconds
            returnURL = returnURL + String(secondsFinal)
            
            return returnURL
        }
    }
    
    //Helper function to return the hash of the video for encoding a popout video that has a start time code.
    private func getVideoHash(url: String) -> String {
        let startOfHash = url.indexOf(".be/")
        let endOfHash = url.indexOf("?t")
        let hash = url.substringWithRange(url.startIndex.advancedBy(startOfHash+4) ..<
                                                        (endOfHash == -1 ? url.endIndex : url.startIndex.advancedBy(endOfHash)))
        return hash
    }
}
