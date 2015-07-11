//
//  AppDelegate.swift
//  Helium
//
//  Created by Jaden Geller on 4/9/15.
//  Copyright (c) 2015 Jaden Geller. All rights reserved.
//

import Cocoa
import CoreGraphics

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {

    @IBOutlet weak var magicURLMenu: NSMenuItem!
    @IBOutlet weak var menuBarMenu: NSMenu!
    
    
    var statusBar = NSStatusBar.systemStatusBar()
    var statusBarItem : NSStatusItem = NSStatusItem()
    var defaultWindow:NSWindow!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        statusBarItem = statusBar.statusItemWithLength(-1)
        statusBarItem.menu = menuBarMenu
        statusBarItem.image = NSImage(named: "menuBar")
        
        // Insert code here to initialize your application
        defaultWindow = NSApplication.sharedApplication().windows.first as? NSWindow
        defaultWindow?.level = Int(CGWindowLevelForKey(Int32(kCGMainMenuWindowLevelKey-1)))
        defaultWindow.collectionBehavior = NSWindowCollectionBehavior.FullScreenAuxiliary|NSWindowCollectionBehavior.CanJoinAllSpaces|NSWindowCollectionBehavior.FullScreenAuxiliary
        
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
        if let urlString:String? = event.paramDescriptorForKeyword(AEKeyword(keyDirectObject))?.stringValue {
            if let url:String? = urlString?.substringFromIndex(advance(urlString!.startIndex,9)){
                var urlObject:NSURL = NSURL(string:url!)!
            NSNotificationCenter.defaultCenter().postNotificationName("HeliumLoadURL", object: urlObject)
                
            }else {
                println("No valid URL to handle")
            }
            
            
        }
    }
}

