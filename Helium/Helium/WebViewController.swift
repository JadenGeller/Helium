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

    var trackingTag: NSTrackingRectTag?

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

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

        if let tag = trackingTag {
            view.removeTrackingRect(tag)
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
    
    @IBAction func backPress(_ sender: AnyObject) {
        webView.goBack()
    }
    
    @IBAction func forwardPress(_ sender: AnyObject) {
        webView.goForward()
    }
    
    fileprivate func zoomIn() {
        webView.magnification += 0.1
    }
    
    fileprivate func zoomOut() {
        webView.magnification -= 0.1
    }
    
    fileprivate func resetZoom() {
        webView.magnification = 1
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
            loadURL(URL(string: "https://cdn.rawgit.com/JadenGeller/Helium/master/helium_start.html")!)
        }
    }

    var webView = WKWebView()
    var shouldRedirect: Bool {
        get {
            return !UserDefaults.standard.bool(forKey: UserSetting.disabledMagicURLs.userDefaultsKey)
        }
    }
    
    // MARK: - Redirect magic urls
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
		if shouldRedirect {
			if let url = navigationAction.request.url, let host = url.host {
				let urlString = url.absoluteString
				var modified = URLComponents()
				modified.scheme = url.scheme

				// MARK: YouTube
				if host.contains("youtu") {
					// (video id) (hours)?(minutes)?(seconds)
					let YTRegExp = try! NSRegularExpression(pattern: "(?:https?://)?(?:www\\.)?(?:youtube\\.com/watch\\?v=|youtu.be/)([\\w\\_\\-]+)(?:[&?]t=(?:(\\d+)h)?(?:(\\d+)m)?(?:(\\d+)s?))?")
					if let match = YTRegExp.firstMatch(in: urlString, range: urlString.nsrange) {
						modified.host = "youtube.com"
						modified.path = "/embed/" + urlString.substring(with: match.rangeAt(1))!

						var start = 0
						var multiplier = 60 * 60
						for idx in 2...4 {
							if let tStr = urlString.substring(with: match.rangeAt(idx)), let tInt = Int(tStr) {
								start += tInt * multiplier
							}
							multiplier /= 60
						}
						if start != 0 {
							modified.query = "start=" + String(start)
						}
					}
				} else // MARK: Twitch
					if host.contains("twitch.tv") {
					let TwitchRegExp = try! NSRegularExpression(pattern: "https?://(?:www\\.)?twitch\\.tv/([\\w\\d\\_]+)(?:/(\\d+))?");
					if let match = TwitchRegExp.firstMatch(in: urlString, range: urlString.nsrange), let channel = urlString.substring(with:match.rangeAt(1)) {
						switch(channel) {
						case "directory", "products", "p", "user":
							break
						case "videos":
							if let idString = urlString.substring(with:match.rangeAt(2)) {
								modified.host = "player.twitch.tv"
								modified.query = "html5&video=v" + idString
							}
						default:
							modified.host = "player.twitch.tv"
							modified.query = "html5&channel=" + channel
						}
					}
				} else {
					var urlStringModified = urlString

					// MARK: Vimeo, Youku, Dailymotion
					urlStringModified = urlStringModified.replacingOccurrences(of: "(?:https?://)?(?:www\\.)?vimeo\\.com/(\\d+)", with: "https://player.vimeo.com/video/$1", options: .regularExpression)

					urlStringModified = urlStringModified.replacePrefix("http://v.youku.com/v_show/id_", replacement: "http://player.youku.com/embed/")
					urlStringModified = urlStringModified.replacePrefix("http://www.dailymotion.com/video/", replacement: "http://www.dailymotion.com/embed/video/")
					urlStringModified = urlStringModified.replacePrefix("http://dai.ly/", replacement: "http://www.dailymotion.com/embed/video/")

					if urlStringModified != urlString {
						modified = URLComponents(string: urlStringModified)!
					}
				}

				if (modified.host != nil) {
					decisionHandler(WKNavigationActionPolicy.cancel)
					loadURL(modified.url!)
					return
				}
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
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if object as! NSObject == webView && keyPath == "estimatedProgress" {
            if let progress = change?[NSKeyValueChangeKey(rawValue: "new")] as? Float {
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

