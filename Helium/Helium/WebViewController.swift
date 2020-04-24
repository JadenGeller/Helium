//
//  ViewController.swift
//  Helium
//
//  Created by Jaden Geller on 4/9/15.
//  Copyright (c) 2015 Jaden Geller. All rights reserved.
//

import Cocoa
import WebKit

class HeliumWebView: WKWebView {
    override var mouseDownCanMoveWindow: Bool {
        true
    }
}

class WebViewController: NSViewController, WKNavigationDelegate, NSMenuItemValidation {

    var trackingTag: NSView.TrackingRectTag?

    override func loadView() {
      self.view = NSView()
    }
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(WebViewController.loadURLObject(_:)), name: NSNotification.Name(rawValue: "HeliumLoadURL"), object: nil)
        
        // Layout webview
        view.addSubview(webView)
        webView.frame = view.bounds
        webView.autoresizingMask = [.width, .height]
        
        // Allow plug-ins such as silverlight
        webView.configuration.preferences.plugInsEnabled = true
                
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

        if let tag = trackingTag {
            view.removeTrackingRect(tag)
        }

        trackingTag = view.addTrackingRect(view.bounds, owner: self, userData: nil, assumeInside: false)
    }

    // MARK: Actions
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem.title {
        case "Back":
            return webView.canGoBack
        case "Forward":
            return webView.canGoForward
        default:
            return true
        }
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
    
    @objc func resetZoomLevel(_ sender: AnyObject) {
        resetZoom()
         }
    @objc func zoomIn(_ sender: AnyObject) {
        zoomIn()
    }
    @objc func zoomOut(_ sender: AnyObject) {
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
    
    internal func loadURL(_ url: URL) {
        webView.load(URLRequest(url: url))
    }
    
    @objc func loadURLObject(_ urlObject: Notification) {
        if let url = urlObject.object as? URL {
            loadAlmostURL(url.absoluteString);
        }
    }
    
    // MARK: Webview functions
    func clear() {
        // Reload to home page (or default if no URL stored in UserDefaults)
        if let homePage = UserSetting.homePageURL {
            loadAlmostURL(homePage)
        }
        else{
            loadURL(URL(string: "https://cdn.rawgit.com/JadenGeller/Helium/master/helium_start.html")!)
        }
    }

    var webView = HeliumWebView()
    
    // Redirect Hulu and YouTube to pop-out videos
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        
        if !UserSetting.disabledMagicURLs {
            print("Magic URL functionality not implemented")
        }
        
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        if let pageTitle = webView.title {
            var title = pageTitle;
            if title.isEmpty { title = "Helium" }
            let notif = Notification(name: Notification.Name(rawValue: "HeliumUpdateTitle"), object: title);
            NotificationCenter.default.post(notif)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as! NSObject == webView && keyPath == "estimatedProgress" {
            if let progress = change?[NSKeyValueChangeKey.newKey] as? Float {
                let percent = progress * 100
                var title = NSString(format: "Loading... %.2f%%", percent)
                if percent == 100 {
                    title = "Helium"
                }
                
                let notif = Notification(name: Notification.Name(rawValue: "HeliumUpdateTitle"), object: title);
                NotificationCenter.default.post(notif)
            }
        }
    }
    }

