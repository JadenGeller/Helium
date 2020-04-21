//
//  AppDelegate.swift
//  Helium
//
//  Created by Jaden Geller on 4/9/15.
//  Copyright (c) 2015 Jaden Geller. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(AppDelegate.handleURLEvent(_:withReply:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
    }
    
    var panelController: HeliumPanelController!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let webController = WebViewController()
        webController.view.frame.size = .init(width: 480, height: 300)
        let panel = NSPanel(contentViewController: webController)
        panel.styleMask = [
            .hudWindow,
            .utilityWindow,
            .nonactivatingPanel,
            .titled,
            .resizable
        ]
        panel.hasShadow = true
        panel.center()
        panelController = HeliumPanelController(window: panel)
        panel.delegate = panelController
        panelController.showWindow(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    //MARK: - handleURLEvent
    // Called when the App opened via URL.
    @objc func handleURLEvent(_ event: NSAppleEventDescriptor, withReply reply: NSAppleEventDescriptor) {
        
        guard let keyDirectObject = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject)),
            let urlString = keyDirectObject.stringValue,
            let urlObject = URL(string: String(urlString[urlString.index(urlString.startIndex, offsetBy: 9)..<urlString.endIndex])) else {
            
                return print("No valid URL to handle")
                
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "HeliumLoadURL"), object: urlObject)
        
    }
}

