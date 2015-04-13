//
//  ViewController.swift
//  Helium
//
//  Created by Jaden Geller on 4/9/15.
//  Copyright (c) 2015 Jaden Geller. All rights reserved.
//

import Cocoa
import WebKit

class WebViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "requestedReload", name: "HeliumReload", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "clear", name: "HeliumClear", object: nil)
        
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_0) AppleWebKit/600.5.17 (KHTML, like Gecko) Version/7.1.5 Safari/537.85.14"

        clear()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func loadURL(url:NSURL) {
        webView.mainFrame.loadRequest(NSURLRequest(URL: url))
    }
    func requestedReload() {
        webView.mainFrame.reload()
    }
    func clear() {
        let url = NSURL(string: "https://rawgit.com/JadenGeller/4bb77b2fac2f57b29c91/raw/d6d82ba87db3058b3059fbc64d85ab5c7568baf5/helium_start.html")
        let request = NSURLRequest(URL: url!)
        webView.mainFrame.loadRequest(request)
    }

    @IBOutlet weak var webView: WebView!
    
}

