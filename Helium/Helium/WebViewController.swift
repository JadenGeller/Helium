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
        
        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "requestedReload", name: "HeliumReload", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "clear", name: "HeliumClear", object: nil)
        
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
        
        clear()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func loadURL(url:NSURL) {
        webView.loadRequest(NSURLRequest(URL: url))
    }
    
    func requestedReload() {
        webView.reload()
    }
    func clear() {
        loadURL(NSURL(string: "https://rawgit.com/JadenGeller/4bb77b2fac2f57b29c91/raw/d6d82ba87db3058b3059fbc64d85ab5c7568baf5/helium_start.html")!)
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
            
            if urlString != modified {
                decisionHandler(WKNavigationActionPolicy.Cancel)
                loadURL(NSURL(string: modified)!)
                return

            }
        }
        
        decisionHandler(WKNavigationActionPolicy.Allow)
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
