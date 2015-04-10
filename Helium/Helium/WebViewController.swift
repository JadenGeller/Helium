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
        webView.mainFrame.loadHTMLString("<!DOCTYPE html><html><head><style>body{background-color:#3399FF; color:white; font-family: 'Helvetica Neue'}</style></head><body><center>Navigate to a webpage using the <b>Location</b> menu in the menubar.<br><br><img src='http://jadengeller.github.io/Helium/helium_icon.png' style='width:45%'></center></body></html>", baseURL: nil)
    }

    @IBOutlet weak var webView: WebView!
    
}

