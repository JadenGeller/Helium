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

    //Necessary to retain all of the information in each window
    var windowStack : Array<HeliumPanelController> = []
    
    @IBOutlet weak var magicURLMenu: NSMenuItem!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        self.popNewWindow(aNotification)
        
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
    
    
    @IBAction func popNewWindow(sender: AnyObject){
        var nextWindowController : HeliumPanelController = NSStoryboard(name: "Main", bundle: nil)?.instantiateControllerWithIdentifier("HeliumController") as! HeliumPanelController
        
        nextWindowController.showWindow(sender)
        
        windowStack.append(nextWindowController)
    }
    
    
//MARK: - handleURLEvent
    // Called when the App opened via URL.
    func handleURLEvent(event: NSAppleEventDescriptor, withReply reply: NSAppleEventDescriptor) {
        if let urlString:String? = event.paramDescriptorForKeyword(AEKeyword(keyDirectObject))?.stringValue {
            if let url:String? = urlString?.substringFromIndex(advance(urlString!.startIndex,9)){
                var urlObject:NSURL = NSURL(string:url!)!
                //NOTE:
                let hP : HeliumPanelController = windowStack[0]
                hP.webViewController.loadURL(urlObject)
            }else {
                println("No valid URL to handle")
            }
            
            
        }
    }

}

