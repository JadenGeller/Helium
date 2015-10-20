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

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        magicURLMenu.state = NSUserDefaults.standardUserDefaults().boolForKey("disabledMagicURLs") ? NSOffState : NSOnState
        NSAppleEventManager.sharedAppleEventManager().setEventHandler(
            self,
            andSelector: "handleURLEvent:withReply:",
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    @IBAction func magicURLRedirectToggled(sender: NSMenuItem) {
        sender.state = (sender.state == NSOnState) ? NSOffState : NSOnState
        NSUserDefaults.standardUserDefaults().setBool((sender.state == NSOffState), forKey: "disabledMagicURLs")
    }

    //MARK: - handleURLEvent
    // Called when the App opened via URL.
    func handleURLEvent(event: NSAppleEventDescriptor, withReply reply: NSAppleEventDescriptor) {
        let prefixLength = "helium://".lengthOfBytesUsingEncoding(NSASCIIStringEncoding)
        if let urlString:String? = event.paramDescriptorForKeyword(AEKeyword(keyDirectObject))?.stringValue {
            if let url:String? = urlString?.substringFromIndex(urlString!.startIndex.advancedBy(prefixLength)) {
                let urlObject:NSURL = NSURL(string:url!)!
                NSLog("Loading %@", url!)
                NSNotificationCenter.defaultCenter().postNotificationName("HeliumLoadURL", object: urlObject)
            } else {
                NSLog("No valid URL to handle")
            }
        }
    }
}

