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

    let appDefaultLastLocation = "lastOpenedLocation"
    
    var lastKnownLocation: NSURL?
    
    func applicationWillFinishLaunching(notification: NSNotification) {
        NSAppleEventManager.sharedAppleEventManager().setEventHandler(
            self,
            andSelector: "handleURLEvent:withReply:",
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
        
        lastKnownLocation = NSUserDefaults.standardUserDefaults().URLForKey(appDefaultLastLocation)
        
        if (lastKnownLocation != nil) {
            NSNotificationCenter.defaultCenter().postNotificationName("HeliumLoadURL", object:lastKnownLocation)
        }
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        magicURLMenu.state = NSUserDefaults.standardUserDefaults().boolForKey("disabledMagicURLs") ? NSOffState : NSOnState
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        NSUserDefaults.standardUserDefaults().setURL(lastKnownLocation, forKey:appDefaultLastLocation)
    }
    
    
    @IBAction func magicURLRedirectToggled(sender: NSMenuItem) {
        sender.state = (sender.state == NSOnState) ? NSOffState : NSOnState
        NSUserDefaults.standardUserDefaults().setBool((sender.state == NSOffState), forKey: "disabledMagicURLs")
    }
    
    
//MARK: - handleURLEvent
    // Called when the App opened via URL.
    func handleURLEvent(event: NSAppleEventDescriptor, withReply reply: NSAppleEventDescriptor) {
        if let urlString:String? = event.paramDescriptorForKeyword(AEKeyword(keyDirectObject))?.stringValue {
            if let url:String? = urlString?.substringFromIndex(urlString!.startIndex.advancedBy(9)){
                let urlObject:NSURL = NSURL(string:url!)!
            NSNotificationCenter.defaultCenter().postNotificationName("HeliumLoadURL", object: urlObject)
                
            }else {
                print("No valid URL to handle")
            }
            
            
        }
    }
}

