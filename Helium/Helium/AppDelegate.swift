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
	@IBOutlet weak var autoHideTitleMenu: NSMenuItem!

    func applicationWillFinishLaunching(notification: NSNotification) {
        NSAppleEventManager.sharedAppleEventManager().setEventHandler(
            self,
            andSelector: #selector(AppDelegate.handleURLEvent(_:withReply:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        magicURLMenu.state = NSUserDefaults.standardUserDefaults().boolForKey(UserSetting.DisabledMagicURLs.userDefaultsKey) ? NSOffState : NSOnState
        
        fullScreenFloatMenu.state = NSUserDefaults.standardUserDefaults().boolForKey(UserSetting.DisabledFullScreenFloat.userDefaultsKey) ? NSOffState : NSOnState
      
        if let alpha = NSUserDefaults.standardUserDefaults().objectForKey(UserSetting.OpacityPercentage.userDefaultsKey) {
            let offset = (alpha as! Int)/10 - 1
            for (index, button) in percentageMenu.submenu!.itemArray.enumerate() {
                (button ).state = (offset == index) ? NSOnState : NSOffState
            }
        }
		autoHideTitleMenu.state = NSUserDefaults.standardUserDefaults().boolForKey(UserSetting.AutoHideTitle.userDefaultsKey) ? NSOnState : NSOffState
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    
    @IBAction func magicURLRedirectToggled(sender: NSMenuItem) {
        sender.state = (sender.state == NSOnState) ? NSOffState : NSOnState
        NSUserDefaults.standardUserDefaults().setBool((sender.state == NSOffState), forKey: UserSetting.DisabledMagicURLs.userDefaultsKey)
    }
    
    
    //MARK: - handleURLEvent
    // Called when the App opened via URL.
    @objc func handleURLEvent(event: NSAppleEventDescriptor, withReply reply: NSAppleEventDescriptor) {
        
        guard let keyDirectObject = event.paramDescriptorForKeyword(AEKeyword(keyDirectObject)), let urlString = keyDirectObject.stringValue,
            let url : String = urlString.substringFromIndex(urlString.startIndex.advancedBy(9)),
            let urlObject = NSURL(string:url) else {
            
                return print("No valid URL to handle")
                
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("HeliumLoadURL", object: urlObject)
        
    }
}

