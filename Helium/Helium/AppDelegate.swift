//
//  AppDelegate.swift
//  Helium
//
//  Created by Jaden Geller on 4/9/15.
//  Copyright (c) 2015 Jaden Geller. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {

    @IBOutlet weak var magicURLMenu: NSMenuItem!
    @IBOutlet weak var percentageMenu: NSMenuItem!
    @IBOutlet weak var fullScreenFloatMenu: NSMenuItem!

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(AppDelegate.handleURLEvent(_:withReply:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        magicURLMenu.state = UserDefaults.standard.bool(forKey: UserSetting.DisabledMagicURLs.userDefaultsKey) ? .off : .on

        fullScreenFloatMenu.state = UserDefaults.standard.bool(forKey: UserSetting.DisabledFullScreenFloat.userDefaultsKey) ? .off : .on

        if let alpha = UserDefaults.standard.object(forKey: UserSetting.OpacityPercentage.userDefaultsKey) {
            let offset = (alpha as! Int)/10 - 1
            for (index, button) in percentageMenu.submenu!.items.enumerated() {
                (button ).state = (offset == index) ? .on : .off
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
    @IBAction func magicURLRedirectToggled(_ sender: NSMenuItem) {
        sender.state = (sender.state == .on) ? .off : .on
        UserDefaults.standard.set((sender.state == .off), forKey: UserSetting.DisabledMagicURLs.userDefaultsKey)
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

