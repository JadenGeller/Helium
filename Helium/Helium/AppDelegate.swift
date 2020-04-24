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
    
    let windowControllerManager = WindowControllerManager()
    @objc func showNewWindow(_ sender: Any?) {
        windowControllerManager.newWindow().showWindow(self)
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
    
    func applicationOpenUntitledFile(_ sender: NSApplication) -> Bool {
        showNewWindow(self)
        return true
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        return sender.windows.isEmpty
    }
}

