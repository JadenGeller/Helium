//
//  AppDelegate.swift
//  Helium
//
//  Created by Jaden Geller on 4/9/15.
//  Copyright (c) 2015 Jaden Geller. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application

    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func reloadPress(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("HeliumReload", object: nil)

    }
    
    @IBAction func clearPress(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("HeliumClear", object: nil)
    }
    
    @IBAction func translucencyPress(sender: NSMenuItem) {
        if sender.state == NSOnState {
            sender.state = NSOffState
            NSNotificationCenter.defaultCenter().postNotificationName("HeliumTranslucencyDisabled", object: nil)
        }
        else {
            sender.state = NSOnState
            NSNotificationCenter.defaultCenter().postNotificationName("HeliumTranslucencyEnabled", object: nil)
        }
    }
    @IBOutlet weak var allTranslucencyValues: NSMenu!
    
    @IBAction func percentagePress(sender: NSMenuItem) {
        for button in allTranslucencyValues.itemArray {
            (button as! NSMenuItem).state = NSOffState
        }
        sender.state = NSOnState
        let value = sender.title.substringToIndex(advance(sender.title.endIndex, -1))
        if let alpha = value.toInt() {
            NSNotificationCenter.defaultCenter().postNotificationName("HeliumUpdateAlpha", object: NSNumber(integer: alpha))
        }
    }
    @IBAction func openLocationPress(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("HeliumRequestLocation", object: nil)

    }
}

