//
//  ViewController.swift
//  Helium
//
//  Created by Jaden Geller on 4/9/15.
//  Copyright (c) 2015 Jaden Geller. All rights reserved.
//

import Cocoa
import WebKit

class WebViewController: NSViewController, WKNavigationDelegate, WKUIDelegate, HeliumPanelDelegate {
    var paneShouldInterruptScroll: Bool = false
    var videotagExists = false

    var trackingTag: NSTrackingRectTag?

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addTrackingRect(view.bounds, owner: self, userData: nil, assumeInside: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(WebViewController.loadURLObject(_:)), name: NSNotification.Name(rawValue: "HeliumLoadURL"), object: nil)
        
        // Layout webview
        view.addSubview(webView)
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


        clear()
    }

    override func viewDidLayout() {
        super.viewDidLayout()
        if let window = self.view.window as? HeliumPanel {
            window.heliumDelegate = self
        } else {
            print("Failed to set delegate!")
        }

        if let tag = trackingTag {
            view.removeTrackingRect(tag)
        }

        trackingTag = view.addTrackingRect(view.bounds, owner: self, userData: nil, assumeInside: false)
    }

    func paneShouldFireEvent(_ event: HeliumPanel.ControlEventType) -> Bool {
        if self.videotagExists {
            switch event {
            case .left:
                let _ = self.webView.callJavascriptFunction("__Helium.seekBackward")
            case .right:
                let _ = self.webView.callJavascriptFunction("__Helium.seekForward")
            case .up:
                let _ = self.webView.callJavascriptFunction("__Helium.volumeUp")
            case .down:
                let _ = self.webView.callJavascriptFunction("__Helium.volumeDown")
            }

            return false;
        } else {
            return true
        }
    }

    // MARK: Actions
    func validate(_ menuItem: NSMenuItem) -> Bool{
        switch menuItem.title {
        case "Back":
            return webView.canGoBack
        case "Forward":
            return webView.canGoForward
        default:
            return true
        }
    }
    
    @IBAction func backPress(_ sender: AnyObject) {
        webView.goBack()
    }
    
    @IBAction func forwardPress(_ sender: AnyObject) {
        webView.goForward()
    }
    
    private func zoomIn() {
        webView.magnification += 0.1
    }
    
    private func zoomOut() {
        webView.magnification -= 0.1
    }
    
    private func resetZoom() {
        webView.magnification = 1
    }
    
    @IBAction private func reloadPress(_ sender: AnyObject) {
        requestedReload()
    }
    
    @IBAction private func clearPress(_ sender: AnyObject) {
        clear()
    }
    
    @IBAction private func resetZoomLevel(_ sender: AnyObject) {
        resetZoom()
    }
    @IBAction private func zoomIn(_ sender: AnyObject) {
        zoomIn()
    }
    @IBAction private func zoomOut(_ sender: AnyObject) {
        zoomOut()
    }

    internal func loadAlmostURL(_ text: String) {
        var text = text
        if !(text.lowercased().hasPrefix("http://") || text.lowercased().hasPrefix("https://")) {
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
    
    func loadURLObject(_ urlObject : Notification) {
        if let url = urlObject.object as? URL {
            loadAlmostURL(url.absoluteString);
        }
    }
    
    private func requestedReload() {
        webView.reload()
    }
    
    // MARK: Webview functions
    func clear() {
        // Reload to home page (or default if no URL stored in UserDefaults)
        if let homePage = UserDefaults.standard.string(forKey: UserSetting.homePageURL.userDefaultsKey) {
            loadAlmostURL(homePage)
        }
        else{
            loadURL(URL(string: "https://cdn.rawgit.com/JadenGeller/Helium/master/helium_start.html")!)
        }
    }

    var webView = WKWebView()
    var shouldRedirect: Bool {
        get {
            return !UserDefaults.standard.bool(forKey: UserSetting.disabledMagicURLs.userDefaultsKey)
        }
    }
    
    // Redirect Hulu and YouTube to pop-out videos
    private func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        
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
            let notif = Notification(name: NSNotification.Name(rawValue: "HeliumUpdateTitle"), object: title);
            NotificationCenter.default.post(notif)
        }

        let _ = self.webView.embedUserJS(Bundle.main.url(forResource: "Helium.user", withExtension: "js")!)

        if let height = self.webView.evaluateJavascript("document.height") as? NSNumber {
            self.paneShouldInterruptScroll =  Int(height) <= Int(self.webView.frame.height)
        }

        self.videotagExists = self.webView.callJavascriptFunction("__Helium.hasVideotag")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as! NSObject == webView && keyPath == "estimatedProgress" {
            if let progress = change?[NSKeyValueChangeKey(rawValue: "new")] as? Float {
                let percent = progress * 100
                var title = NSString(format: "Loading... %.2f%%", percent)
                if percent == 100 {
                    title = "Helium"
                }
                
                let notif = Notification(name: NSNotification.Name(rawValue: "HeliumUpdateTitle"), object: title);
                NotificationCenter.default.post(notif)
            }
        }
    }

    //Convert a YouTube video url that starts at a certian point to popup/embedded design
    // (i.e. ...?t=1m2s --> ?start=62)
    private func makeCustomStartTimeURL(_ url: String) -> String {
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

            //returnURL.removeSubrange(returnURL.indices.suffix(from: returnURL.index(returnURL.startIndex, offsetBy: idx+1)))
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
    private func getVideoHash(_ url: String) -> String {
        let startOfHash = url.indexOf(".be/")
        let endOfHash = url.indexOf("?t")
        let hash = url.substring(with: url.characters.index(url.startIndex, offsetBy: startOfHash+4) ..<
                                                        (endOfHash == -1 ? url.endIndex : url.characters.index(url.startIndex, offsetBy: endOfHash)))
        return hash
    }
}

