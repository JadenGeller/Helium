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
    @IBOutlet weak var activateByWindowMenu: NSMenuItem!
    @IBOutlet weak var hideTitleBarMenu: NSMenuItem!

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
        activateByWindowMenu.state = UserDefaults.standard.bool(forKey: UserSetting.activateByWindow.userDefaultsKey) ? NSOnState : NSOffState
        hideTitleBarMenu.state = UserDefaults.standard.bool(forKey: UserSetting.hideTitle.userDefaultsKey) ? NSOnState : NSOffState
      
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
        
        guard let keyDirectObject = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject)), let urlString = keyDirectObject.stringValue,
            let url : String = urlString.substring(from: urlString.characters.index(urlString.startIndex, offsetBy: 9)),
            let urlObject = URL(string:url) else {
            
                return print("No valid URL to handle")
                
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "HeliumLoadURL"), object: urlObject)
        
    }
}

