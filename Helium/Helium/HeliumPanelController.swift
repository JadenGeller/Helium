//
//  HeliumPanelController.swift
//  Helium
//
//  Created by Jaden Geller on 4/9/15.
//  Copyright (c) 2015 Jaden Geller. All rights reserved.
//

import AppKit

class HeliumPanelController : NSWindowController {

    var panel: NSPanel! {
        get {
            return (self.window as! NSPanel)
        }
    }
    
    override func windowDidLoad() {
        panel.floatingPanel = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didBecomeActive", name: NSApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willResignActive", name: NSApplicationWillResignActiveNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEnableTranslucency", name: "HeliumTranslucencyEnabled", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDisableTranslucency", name: "HeliumTranslucencyDisabled", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdateAlpha:", name: "HeliumUpdateAlpha", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRequestLocation", name: "HeliumRequestLocation", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRequestFile", name: "HeliumRequestFile", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdateTitle:", name: "HeliumUpdateTitle", object: nil)

    }
    
    func didUpdateTitle(notification: NSNotification) {
        if let title = notification.object as? String {
            panel.title = title
        }
    }
    
    func didRequestFile() {
        
        let open = NSOpenPanel()
        open.allowsMultipleSelection = false
        open.canChooseFiles = true
        open.canChooseDirectories = false
        
        if open.runModal() == NSModalResponseOK {
            if let url = open.URL {
                webViewController.loadURL(url)
            }
        }
    }
    
    var webViewController: WebViewController {
        get {
            return self.window?.contentViewController as! WebViewController
        }
    }
    
    func didRequestLocation() {
        let alert = NSAlert()
        alert.alertStyle = NSAlertStyle.InformationalAlertStyle
        alert.messageText = "Enter Destination URL"
        
        let urlField = NSTextField()
        urlField.frame = NSRect(x: 0, y: 0, width: 300, height: 20)
        
        alert.accessoryView = urlField
        alert.addButtonWithTitle("Load")
        alert.addButtonWithTitle("Cancel")
        alert.beginSheetModalForWindow(self.window!, completionHandler: { response in
            if response == NSAlertFirstButtonReturn {
                // Load
                var text = (alert.accessoryView as! NSTextField).stringValue
                
                if !(text.lowercaseString.hasPrefix("http://") || text.lowercaseString.hasPrefix("https://")) {
                    text = "http://" + text
                }
                
                if let url = NSURL(string: text) {
                    self.webViewController.loadURL(url)
                }
            }
        })
    }
    
    var alpha: CGFloat = 0.6 { //default
        didSet {
            if translucent {
                panel.alphaValue = alpha
            }
        }
    }

    var translucent: Bool = false {
        didSet {
            if !NSApplication.sharedApplication().active {
                panel.ignoresMouseEvents = translucent
            }
            if translucent {
                panel.opaque = false
                panel.alphaValue = alpha
            }
            else {
                panel.opaque = true
                panel.alphaValue = 1.0
            }
        }
    }
    
    func didBecomeActive() {
        panel.ignoresMouseEvents = false
    }
    
    func willResignActive() {
        if translucent {
            panel.ignoresMouseEvents = true
        }
    }
    
    func didEnableTranslucency() {
        translucent = true
    }
    
    func didDisableTranslucency() {
        translucent = false
    }
    
    func didUpdateAlpha(notifcation: NSNotification) {
        let newAlpha = notifcation.object as! NSNumber
        alpha = CGFloat(newAlpha.doubleValue) / CGFloat(100.0)
    }
}