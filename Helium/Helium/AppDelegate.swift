//
//  AppDelegate.swift
//  Helium
//
//  Created by Jaden Geller on 4/9/15.
//  Copyright (c) 2015 Jaden Geller. All rights reserved.
//

import Cocoa
//import Squirrel

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var magicURLMenu: NSMenuItem!
    
//    var updater: SQRLUpdater!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        magicURLMenu.state = NSUserDefaults.standardUserDefaults().boolForKey("disabledMagicURLs") ? NSOffState : NSOnState
        
        // Autoupdate code
        
//        let components = NSURLComponents()
//        components.scheme = "https";
//        components.host = "gist.githubusercontent.com";
//        components.path = "/JadenGeller/321e2319e288e17f59aa/raw/10c22987095377f35f55824e7a5de2cc596db665/helum_update";
//        
//        let bundleVersion = NSBundle.mainBundle().sqrl_bundleVersion
//        components.query = "version=\(bundleVersion)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())
//        
//        updater = SQRLUpdater(updateRequest: NSURLRequest(URL: components.URL!))
//        
//        // Check for updates every 4 hours.
//        self.updater.startAutomaticChecksWithInterval(60 * 60 * 4)
//        
//        self.updater.updates.subscribeNext {
//            let downloadedUpdate = $0 as! SQRLDownloadedUpdate
//            println(downloadedUpdate)
//        }

    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func reloadPress(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("HeliumReload", object: nil)

    }
    @IBAction func magicURLRedirectToggled(sender: NSMenuItem) {
        sender.state = (sender.state == NSOnState) ? NSOffState : NSOnState
        NSUserDefaults.standardUserDefaults().setBool((sender.state == NSOffState), forKey: "disabledMagicURLs")
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

