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
        magicURLMenu.state = UserDefaults.standard.bool(forKey: UserSetting.disabledMagicURLs.userDefaultsKey) ? NSOffState : NSOnState
        
        fullScreenFloatMenu.state = UserDefaults.standard.bool(forKey: UserSetting.disabledFullScreenFloat.userDefaultsKey) ? NSOffState : NSOnState
      
        if let alpha = UserDefaults.standard.object(forKey: UserSetting.opacityPercentage.userDefaultsKey) {
            let offset = (alpha as! Int)/10 - 1
            for (index, button) in percentageMenu.submenu!.items.enumerated() {
                (button ).state = (offset == index) ? NSOnState : NSOffState
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
    @IBAction func magicURLRedirectToggled(_ sender: NSMenuItem) {
        sender.state = (sender.state == NSOnState) ? NSOffState : NSOnState
        UserDefaults.standard.set((sender.state == NSOffState), forKey: UserSetting.disabledMagicURLs.userDefaultsKey)
    }
    
    
    //MARK: - handleURLEvent
    // Called when the App opened via URL.
    @objc func handleURLEvent(_ event: NSAppleEventDescriptor, withReply reply: NSAppleEventDescriptor) {

        guard let keyDirectObject = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject)),
            let urlString = keyDirectObject.stringValue else {
                return print("Can't get URL from event")
        }

        // skip 'helium://'
        let index = urlString.index(urlString.startIndex, offsetBy: 9)
        let url = urlString.substring(from: index)

        guard let urlObject = URL(string: url) else {
            return print("No valid URL to handle")
        }

        NotificationCenter.default.post(name: Notification.Name(rawValue: "HeliumLoadURL"), object: urlObject)
    }
}

