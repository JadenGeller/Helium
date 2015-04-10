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
        webView.mainFrame.loadHTMLString("<!DOCTYPE html><html><head><style>body{background-color:#101010}</style></head></html>", baseURL: nil)
    }

    @IBOutlet weak var webView: WebView!
    
}

