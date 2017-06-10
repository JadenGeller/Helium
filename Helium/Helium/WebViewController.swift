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
	var appDelegate: AppDelegate = NSApp.delegate as! AppDelegate
	internal func menuClicked(_ sender: AnyObject) {
		if let menuItem = sender as? NSMenuItem {
			Swift.print("Menu \(menuItem.title) clicked")
		}
	}

	override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
		publishApplicationMenu(menu);
	}

	//	Either by contextual menu, or status item, populate our app menu
	func publishApplicationMenu(_ menu: NSMenu) {
		let wc = self.window?.windowController as! HeliumPanelController
		var item: NSMenuItem

		item = NSMenuItem(title: "Open", action: #selector(menuClicked(_:)), keyEquivalent: "")
		menu.addItem(item)
		let subOpen = NSMenu()
		item.submenu = subOpen

		item = NSMenuItem(title: "File", action: #selector(HeliumPanelController.openFilePress(_:)), keyEquivalent: "")
		item.target = wc
		subOpen.addItem(item)

		item = NSMenuItem(title: "Location", action: #selector(HeliumPanelController.openLocationPress(_:)), keyEquivalent: "")
		item.target = wc
		subOpen.addItem(item)

		item = NSMenuItem(title: "Playlists", action: #selector(WebViewController.presentPlaylistSheet(_:)), keyEquivalent: "")
		item.target = self.uiDelegate
		menu.addItem(item)

		item = NSMenuItem(title: "Preferences", action: #selector(menuClicked(_:)), keyEquivalent: "")
		menu.addItem(item)
		let subPref = NSMenu()
		item.submenu = subPref

		item = NSMenuItem(title: "Auto-hide Title Bar", action: #selector(appDelegate.autoHideTitle(_:)), keyEquivalent: "")
		item.state = UserDefaults.standard.integer(forKey: UserSetting.autoHideTitle.userDefaultsKey)
		item.target = appDelegate
		subPref.addItem(item)

		item = NSMenuItem(title: "Float Above All Spaces", action: #selector(AppDelegate.floatOverFullScreenAppsPress(_:)), keyEquivalent: "")
		item.state = 1 - UserDefaults.standard.integer(forKey: UserSetting.disabledFullScreenFloat.userDefaultsKey)
		item.target = appDelegate
		subPref.addItem(item)
		
		item = NSMenuItem(title: "Home Page", action: #selector(AppDelegate.homePagePress(_:)), keyEquivalent: "")
		item.target = appDelegate
		subPref.addItem(item)

		item = NSMenuItem(title: "Magic URL Redirects", action: #selector(AppDelegate.magicURLRedirectToggled(_:)), keyEquivalent: "")
		item.state = 1 - UserDefaults.standard.integer(forKey: UserSetting.disabledMagicURLs.userDefaultsKey)
		item.target = NSApp.delegate
		subPref.addItem(item)

		item = NSMenuItem(title: "Translucency", action: #selector(menuClicked(_:)), keyEquivalent: "")
		subPref.addItem(item)
		let subTranslucency = NSMenu()
		item.submenu = subTranslucency

		item = NSMenuItem(title: "Enabled", action: #selector(HeliumPanelController.translucencyPress(_:)), keyEquivalent: "")
		item.state = wc.translucencyEnabled == true ? NSOnState : NSOffState
		item.target = wc
		subTranslucency.addItem(item)

		item = NSMenuItem(title: "Opacity", action: #selector(menuClicked(_:)), keyEquivalent: "")
		let opacity = UserDefaults.standard.integer(forKey: UserSetting.opacityPercentage.userDefaultsKey)
		subTranslucency.addItem(item)
		let subOpacity = NSMenu()
		item.submenu = subOpacity

		item = NSMenuItem(title: "10%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "")
		item.state = (10 == opacity ? NSOnState : NSOffState)
		item.target = wc
		subOpacity.addItem(item)
		item = NSMenuItem(title: "20%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "")
		item.state = (20 == opacity ? NSOnState : NSOffState)
		item.target = wc
		subOpacity.addItem(item)
		item = NSMenuItem(title: "30%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "")
		item.state = (30 == opacity ? NSOnState : NSOffState)
		item.target = wc
		subOpacity.addItem(item)
		item = NSMenuItem(title: "40%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "")
		item.state = (40 == opacity ? NSOnState : NSOffState)
		item.target = wc
		subOpacity.addItem(item)
		item = NSMenuItem(title: "50%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "")
		item.state = (50 == opacity ? NSOnState : NSOffState)
		item.target = wc
		subOpacity.addItem(item)
		item = NSMenuItem(title: "60%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "")
		item.state = (60 == opacity ? NSOnState : NSOffState)
		item.target = wc
		subOpacity.addItem(item)
		item = NSMenuItem(title: "70%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "")
		item.state = (70 == opacity ? NSOnState : NSOffState)
		item.target = wc
		subOpacity.addItem(item)
		item = NSMenuItem(title: "80%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "")
		item.state = (80 == opacity ? NSOnState : NSOffState)
		item.target = wc
		subOpacity.addItem(item)
		item = NSMenuItem(title: "90%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "")
		item.state = (90 == opacity ? NSOnState : NSOffState)
		item.target = wc
		subOpacity.addItem(item)
		item = NSMenuItem(title: "100%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "")
		item.state = (100 == opacity ? NSOnState : NSOffState)
		item.target = wc
		subOpacity.addItem(item)

		let translucency: HeliumPanelController.TranslucencyPreference = wc.translucencyPreference

		item = NSMenuItem(title: "Always", action: #selector(HeliumPanelController.alwaysPreferencePress(_:)), keyEquivalent: "")
		item.state = translucency == .always ? NSOnState : NSOffState
		item.target = wc
		subTranslucency.addItem(item)
		item = NSMenuItem(title: "Mouse Over", action: #selector(HeliumPanelController.overPreferencePress(_:)), keyEquivalent: "")
		item.state = translucency == .mouseOver ? NSOnState : NSOffState
		item.target = wc
		subTranslucency.addItem(item)
		item = NSMenuItem(title: "Mouse Outside", action: #selector(HeliumPanelController.outsidePreferencePress(_:)), keyEquivalent: "")
		item.state = translucency == .mouseOutside ? NSOnState : NSOffState
		item.target = wc
		subTranslucency.addItem(item)

		item = NSMenuItem(title: "Quit", action: #selector(AppDelegate.quitPress(_:)), keyEquivalent: "")
		item.target = appDelegate
		menu.addItem(item)
	}
}

class WebViewController: NSViewController, WKNavigationDelegate {

    var trackingTag: NSTrackingRectTag?

    // MARK: View lifecycle
    func fit(_ childView: NSView, parentView: NSView) {
        childView.translatesAutoresizingMaskIntoConstraints = false
        childView.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        childView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        childView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
        childView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(WebViewController.loadURLObject(_:)), name: NSNotification.Name(rawValue: "HeliumLoadURL"), object: nil)
        
        // Layout webview
        view.addSubview(webView)
        fit(webView, parentView: view)

        webView.frame = view.bounds
        webView.autoresizingMask = [NSAutoresizingMaskOptions.viewHeightSizable, NSAutoresizingMaskOptions.viewWidthSizable]
        
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
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)

        // Listen for auto hide title changes
        UserDefaults.standard.addObserver(self, forKeyPath: UserSetting.autoHideTitle.userDefaultsKey, options: NSKeyValueObservingOptions.new, context: nil)

        clear()
    }
    
    var lastStyle : Int = 0
    var lastTitle = "Helium"
	var appDelegate: AppDelegate = NSApp.delegate as! AppDelegate

    override func mouseExited(with theEvent: NSEvent) {
        if appDelegate.autoHideTitle {
            if lastStyle == 0 { lastStyle = Int((self.view.window?.styleMask)!.rawValue) }
            self.view.window!.titleVisibility = NSWindowTitleVisibility.hidden;
            self.view.window?.styleMask = NSBorderlessWindowMask
        }
    }
    override func mouseEntered(with theEvent: NSEvent) {
        if appDelegate.autoHideTitle {
            if lastStyle == 0 { lastStyle = Int((self.view.window?.styleMask)!.rawValue) }
            self.view.window!.titleVisibility = NSWindowTitleVisibility.visible;
            self.view.window?.styleMask = NSWindowStyleMask(rawValue: UInt(lastStyle))

            let notif = Notification(name: Notification.Name(rawValue: "HeliumUpdateTitle"), object: lastTitle);
            NotificationCenter.default.post(notif)
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
			webView.setMagnification((magnify > 1 ? magnify : 1), centeredAt: NSMakePoint(adjSize.width/2.0, adjSize.height/2.0))
            view.setBoundsSize(adjSize)
		}

        trackingTag = view.addTrackingRect(view.bounds, owner: self, userData: nil, assumeInside: false)
    }

    // MARK: Actions
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool{
        switch menuItem.title {
        case "Back":
            return webView.canGoBack
        case "Forward":
            return webView.canGoForward
        default:
            return true
        }
    }

	@IBAction func perferences(_ sender: AnyObject) {
		print("show preferences sheet")
	}
	
    @IBAction func backPress(_ sender: AnyObject) {
        webView.goBack()
    }
    
    @IBAction func forwardPress(_ sender: AnyObject) {
        webView.goForward()
    }
    
    fileprivate func zoomIn() {
        if !videoFileReferencedURL {
            webView.magnification += 0.1
        }
     }
    
    fileprivate func zoomOut() {
        if !videoFileReferencedURL {
            webView.magnification -= 0.1
        }
    }
    
    fileprivate func resetZoom() {
        if !videoFileReferencedURL {
            webView.magnification = 1
        }
    }

    @IBAction fileprivate func reloadPress(_ sender: AnyObject) {
        requestedReload()
    }
    
    @IBAction fileprivate func clearPress(_ sender: AnyObject) {
        clear()
    }
    
    @IBAction fileprivate func resetZoomLevel(_ sender: AnyObject) {
        resetZoom()
    }
    @IBAction fileprivate func zoomIn(_ sender: AnyObject) {
        zoomIn()
    }
    @IBAction fileprivate func zoomOut(_ sender: AnyObject) {
        zoomOut()
    }
    
    lazy var playlistViewController: PlaylistViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "PlaylistViewController")
            as! PlaylistViewController
    }()
    
    @IBAction func presentPlaylistSheet(_ sender: AnyObject) {
        self.presentViewControllerAsSheet(playlistViewController)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    internal func loadAlmostURL( _ text_in: String) {
        var text = text_in
        if !(text.lowercased().hasPrefix("http://") || text.lowercased().hasPrefix("https://") || text.lowercased().hasPrefix("file://")) {
            text = "http://" + text
        }
        
        if let url = URL(string: text) {
            loadURL(url)
        }
        
    }
    
    // MARK: Loading
    
    internal func loadURL(_ url:URL) {
        webView.load(URLRequest(url: url))
    }

    func playerDidFinishPlaying(_ note: Notification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: note.object)
        print("Video Finished")
    }

    func loadURLObject(_ urlObject : Notification) {
        if let url = urlObject.object as? URL {
            loadAlmostURL(url.absoluteString);
        }
    }
    
    fileprivate func requestedReload() {
        webView.reload()
    }
    
    // MARK: Webview functions
    func clear() {
        // Reload to home page (or default if no URL stored in UserDefaults)
        if let homePage = UserDefaults.standard.string(forKey: UserSetting.homePageURL.userDefaultsKey) {
            loadAlmostURL(homePage)
        }
        else{
            loadURL(URL(string: Constants.defaultURL)!)
        }
    }

    var webView = MyWebView()
    var webSize = CGSize(width: 0,height: 0)
    var shouldRedirect: Bool {
        get {
            return !UserDefaults.standard.bool(forKey: UserSetting.disabledMagicURLs.userDefaultsKey)
        }
    }
    
    // Redirect Hulu and YouTube to pop-out videos
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if shouldRedirect, let url = navigationAction.request.url {
            let urlString = url.absoluteString
            var modified = urlString
            modified = modified.replacePrefix("https://www.youtube.com/watch?v=", replacement: modified.contains("list") ? "https://www.youtube.com/embed/?v=" : "https://www.youtube.com/embed/")
            modified = modified.replacePrefix("https://vimeo.com/", replacement: "http://player.vimeo.com/video/")
            modified = modified.replacePrefix("http://v.youku.com/v_show/id_", replacement: "http://player.youku.com/embed/")
            modified = modified.replacePrefix("https://www.twitch.tv/", replacement: "https://player.twitch.tv?html5&channel=")
            modified = modified.replacePrefix("http://www.dailymotion.com/video/", replacement: "http://www.dailymotion.com/embed/video/")
            modified = modified.replacePrefix("http://dai.ly/", replacement: "http://www.dailymotion.com/embed/video/")
 
            if modified.contains("https://youtu.be") {
                modified = "https://www.youtube.com/embed/" + getVideoHash(urlString)
                if urlString.contains("?t=") {
                        modified += makeCustomStartTimeURL(urlString)
                }
            }
            
            if urlString != modified {
                decisionHandler(WKNavigationActionPolicy.cancel)
                loadURL(URL(string: modified)!)
                return
            }
        }
        
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        if let pageTitle = webView.title {
            var title = pageTitle;
            if title.isEmpty { title = "Helium" }
            let notif = Notification(name: Notification.Name(rawValue: "HeliumUpdateTitle"), object: title);
            NotificationCenter.default.post(notif)
            lastTitle = title
        }
    }
    
    func webView(_ webView: WKWebView, didFinishLoad navigation: WKNavigation) {
    }
    
    var videoFileReferencedURL = false
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if object as! NSObject == webView && keyPath == "estimatedProgress" {
            if let progress = change?[NSKeyValueChangeKey(rawValue: "new")] as? Float {
                let percent = progress * 100
                var title = NSString(format: "Loading... %.2f%%", percent)
                if percent == 100 {
                    videoFileReferencedURL = false
                    let url = (self.webView.url)

                    // once loaded update window title,size with video name,dimension
                    if let urlTitle = (self.webView.url?.absoluteString) {
                        title = urlTitle as NSString

                        if let track = AVURLAsset(url: url!, options: nil).tracks.first {

                            //    if it's a video file, get and set window content size to its dimentions
                            if track.mediaType == AVMediaTypeVideo {
                                title = url!.lastPathComponent as NSString
                                webSize = track.naturalSize
                                webView.window?.setContentSize(webSize)
                                webView.bounds.size = webSize
                                videoFileReferencedURL = true
                            }

                            //  Wait for URL to finish
                            let videoPlayer = AVPlayer(url: url!)
                            let item = videoPlayer.currentItem
                            NotificationCenter.default.addObserver(self, selector: #selector(WebViewController.playerDidFinishPlaying(_:)),
                                                                             name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
                        }
                    } else {
                        title = "Helium"
                    }
                    lastTitle = title as String
                }

                let notif = Notification(name: Notification.Name(rawValue: "HeliumUpdateTitle"), object: title);
                NotificationCenter.default.post(notif)
            }
        }

        if (keyPath == UserSetting.autoHideTitle.userDefaultsKey) {
            appDelegate.autoHideTitle = UserDefaults.standard.bool(forKey: keyPath!)
            if appDelegate.autoHideTitle {
                if lastStyle == 0 { lastStyle = Int((self.view.window?.styleMask)!.rawValue) }
                self.view.window!.titleVisibility = NSWindowTitleVisibility.hidden;
                self.view.window?.styleMask = NSBorderlessWindowMask
            } else {
                if lastStyle == 0 { lastStyle = Int((self.view.window?.styleMask)!.rawValue) }
                self.view.window!.titleVisibility = NSWindowTitleVisibility.visible;
                self.view.window?.styleMask = NSWindowStyleMask(rawValue: UInt(lastStyle))
            }

            let notif = Notification(name: Notification.Name(rawValue: "HeliumUpdateTitle"), object: lastTitle);
            NotificationCenter.default.post(notif)
        }
        
    }
    
    //Convert a YouTube video url that starts at a certian point to popup/embedded design
    // (i.e. ...?t=1m2s --> ?start=62)
    fileprivate func makeCustomStartTimeURL(_ url: String) -> String {
        let startTime = "?t="
        let idx = url.indexOf(startTime)
        if idx == -1 {
            return url
        } else {
            var returnURL = url
            let timing = url.substring(from: url.characters.index(url.startIndex, offsetBy: idx+3))
            let hoursDigits = timing.indexOf("h")
            var minutesDigits = timing.indexOf("m")
            let secondsDigits = timing.indexOf("s")
            
            returnURL.removeSubrange(returnURL.characters.index(returnURL.startIndex, offsetBy: idx+1) ..< returnURL.endIndex)
            returnURL = "?start="
            
            //If there are no h/m/s params and only seconds (i.e. ...?t=89)
            if (hoursDigits == -1 && minutesDigits == -1 && secondsDigits == -1) {
                let onlySeconds = url.substring(from: url.characters.index(url.startIndex, offsetBy: idx+3))
                returnURL = returnURL + onlySeconds
                return returnURL
            }
            
            //Do check to see if there is an hours parameter.
            var hours = 0
            if (hoursDigits != -1) {
                hours = Int(timing.substring(to: timing.characters.index(timing.startIndex, offsetBy: hoursDigits)))!
            }
            
            //Do check to see if there is a minutes parameter.
            var minutes = 0
            if (minutesDigits != -1) {
                minutes = Int(timing.substring(with: timing.characters.index(timing.startIndex, offsetBy: hoursDigits+1) ..< timing.characters.index(timing.startIndex, offsetBy: minutesDigits)))!
            }
            
            if minutesDigits == -1 {
                minutesDigits = hoursDigits
            }
            
            //Do check to see if there is a seconds parameter.
            var seconds = 0
            if (secondsDigits != -1) {
                seconds = Int(timing.substring(with: timing.characters.index(timing.startIndex, offsetBy: minutesDigits+1) ..< timing.characters.index(timing.startIndex, offsetBy: secondsDigits)))!
            }
            
            //Combine all to make seconds.
            let secondsFinal = 3600*hours + 60*minutes + seconds
            returnURL = returnURL + String(secondsFinal)
            
            return returnURL
        }
    }
    
    //Helper function to return the hash of the video for encoding a popout video that has a start time code.
    fileprivate func getVideoHash(_ url: String) -> String {
        let startOfHash = url.indexOf(".be/")
        let endOfHash = url.indexOf("?t")
        let hash = url.substring(with: url.characters.index(url.startIndex, offsetBy: startOfHash+4) ..<
                                                        (endOfHash == -1 ? url.endIndex : url.characters.index(url.startIndex, offsetBy: endOfHash)))
        return hash
    }
}
