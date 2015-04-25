//
//  ViewController.swift
//  Helium
//
//  Created by Jaden Geller on 4/9/15.
//  Copyright (c) 2015 Jaden Geller. All rights reserved.
//

import Cocoa
import WebKit

class WebViewController: NSViewController, WKNavigationDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadURLObject:", name: "HeliumLoadURL", object: nil)
        
        // Layout webview
        view.addSubview(webView)
        webView.frame = view.bounds
        webView.autoresizingMask = NSAutoresizingMaskOptions.ViewHeightSizable | NSAutoresizingMaskOptions.ViewWidthSizable
        
        // Allow plug-ins such as silverlight
        webView.configuration.preferences.plugInsEnabled = true
        
        // Netflix support via Silverlight (HTML5 Netflix doesn't work for some unknown reason)
        webView._customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_0) AppleWebKit/600.5.17 (KHTML, like Gecko) Version/7.1.5 Safari/537.85.14"
        
        // Setup magic URLs
        webView.navigationDelegate = self
        
        // Allow zooming
        webView.allowsMagnification = true
        
        // Listen for load progress
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.New, context: nil)
        
        clear()
    }
    
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
    
    @IBAction func backPress(sender: AnyObject) {
        webView.goBack()
    }
    
    @IBAction func forwardPress(sender: AnyObject) {
        webView.goForward()
    }
    
    func zoomIn() {
        webView.magnification += 0.1
    }
    
    func zoomOut() {
        webView.magnification -= 0.1
    }
    
    func resetZoom() {
        webView.magnification = 1
    }
    
    @IBAction func reloadPress(sender: AnyObject) {
        requestedReload()
    }
    
    @IBAction func clearPress(sender: AnyObject) {
        clear()
    }
    
    @IBAction func resetZoomLevel(sender: AnyObject) {
        resetZoom()
    }
    @IBAction func zoomIn(sender: AnyObject) {
        zoomIn()
    }
    @IBAction func zoomOut(sender: AnyObject) {
        zoomOut()
    }


    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func loadURL(url:NSURL) {
        webView.loadRequest(NSURLRequest(URL: url))
    }
    
//MARK: - loadURLObject
    func loadURLObject(urlObject : NSNotification) {
        if let url = urlObject.object as? NSURL {
            loadURL(url);
        }
    }
    
    func requestedReload() {
        webView.reload()
    }
    func clear() {
        loadURL(NSURL(string: "https://cdn.rawgit.com/JadenGeller/Helium/master/helium_start.html")!)
    }

    var webView = WKWebView()
    var shouldRedirect: Bool {
        get {
            return !NSUserDefaults.standardUserDefaults().boolForKey("disabledMagicURLs")
        }
    }
    
    // Redirect Hulu and YouTube to pop-out videos
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        
        if shouldRedirect, let url = navigationAction.request.URL, let urlString = url.absoluteString {
            var modified = urlString
            modified = modified.replacePrefix("https://www.youtube.com/watch?", replacement: "https://www.youtube.com/watch_popup?")
            modified = modified.replacePrefix("https://vimeo.com/", replacement: "http://player.vimeo.com/video/")
            
            modified = modified.replacePrefix("http://v.youku.com/v_show/id_", replacement: "http://player.youku.com/embed/")

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
        }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if object as! NSObject == webView && keyPath == "estimatedProgress" {
            if let progress = change["new"] as? Float {
                let percent = progress * 100
                var title = NSString(format: "Loading... %.2f%%", percent)
                if percent == 100 {
                    title = "Helium"
                }
                
                let notif = NSNotification(name: "HeliumUpdateTitle", object: title);
                NSNotificationCenter.defaultCenter().postNotification(notif)
            }
        }
        
        
    }
}

extension String {
    func replacePrefix(prefix: String, replacement: String) -> String {
        if hasPrefix(prefix) {
            return replacement + substringFromIndex(prefix.endIndex)
        }
        else {
            return self
        }
    
    }
}
