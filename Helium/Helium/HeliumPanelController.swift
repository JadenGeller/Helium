//
//  HeliumPanelController.swift
//  Helium
//
//  Created by Jaden Geller on 4/9/15.
//  Copyright (c) 2015 Jaden Geller. All rights reserved.
//

import AppKit

class HeliumPanelController : NSWindowController {

    //MARK: Initial Properties/Methods
    
    var webView: WebViewController!
    var opacityMenu: NSMenuItem!
    
    var panel: NSPanel! {
        get {
            return (self.window as! NSPanel)
        }
    }

    
    var webViewController: WebViewController {
        get {
            return self.window?.contentViewController as! WebViewController
        }
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
    
    
    override func windowDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didBecomeActive", name: NSApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willResignActive", name: NSApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdateTitle:", name: "HeliumUpdateTitle", object: nil)
        
        webView = panel.contentViewController as! WebViewController
        panel.floatingPanel = true
        
        //Location Item
        
        let locTitlesAndKeys : Array<(String,String)> = [("Open Web URL...", "l"), ("Open File...", "o"), ("Reload", "r"), ("Clear", "\u{08}")]
        
        var locationItem : NSMenuItem = makeMenuWithItems("Location", mainActionTitle: "locationActions:", titlesAndKeys: locTitlesAndKeys)
        
        NSApp.menu!?.insertItem(locationItem, atIndex:1)
        
        //Appearance Item
        
        let appTitlesAndKeys : Array<(String,String)> = [("Translucent", "t")]
        
        var appItem : NSMenuItem = makeMenuWithItems("Appearance", mainActionTitle: "appearanceActions:", titlesAndKeys: appTitlesAndKeys)
        
        var titles : Array<String> = []
        var keys : Array<String> = []
        
        //Opacity sub-item
        
        var opTitlesAndKeys : Array<(String,String)> = []
        
        for i in 1...10
        {
            let title = "\(i)0%"
            let key = "\(i%10)"
            opTitlesAndKeys += [(title, key)]
        }
        
        opacityMenu = makeMenuWithItems("Opacity", mainActionTitle: "changeOpacity:", titlesAndKeys: opTitlesAndKeys)
        
        appItem.submenu?.addItem(opacityMenu)
        
        //Zoom sub-item
        
        let zoomTitlesAndKeys : Array<(String,String)> = [("Zoom In", "+"), ("Zoom Out", "-"), ("Reset Zoom Level", "")]
        
        var zoomItem : NSMenuItem = makeMenuWithItems("Zoom", mainActionTitle: "zoomActions:", titlesAndKeys: zoomTitlesAndKeys)
        
        appItem.submenu?.addItem(zoomItem)
        
        
        NSApp.menu!?.insertItem(appItem, atIndex:1)
    
    }
    
    /**
     ** Returns a menu item with the given title, selector (where all of the events for this menu get sent to),
     ** and submenu titles/keybindings - I used an array of tuples because it was the easiest way to pass
     ** this information while preserving the order.
     **/
    func makeMenuWithItems(title: String, mainActionTitle: String, titlesAndKeys: Array<(String, String)>) -> NSMenuItem{
        var newItem : NSMenuItem = NSMenuItem(title: title, action: Selector(mainActionTitle), keyEquivalent: "")
        var newMenu : NSMenu = NSMenu(title: title)
        for (subTitle, key) in titlesAndKeys {
            var subItem : NSMenuItem = NSMenuItem(title: subTitle, action: Selector(mainActionTitle), keyEquivalent: key)
            newMenu.addItem(subItem)
            
        }
        newItem.submenu = newMenu
        return newItem
    }
    
    //MARK: Menu Item Actions
    
    /**
     ** All of the actions directly under the 'Location' menu
     **/
    func locationActions(sender: AnyObject){
        
        var menu : NSMenuItem = sender as! NSMenuItem
        let name = menu.title
        switch name {
        case "Open Web URL...":
            didRequestLocation()
        case "Open File...":
            didRequestFile()
        case "Reload":
            webView.requestedReload()
        case "Clear":
            webView.clear()
        default:
            NSLog("Error: Unknown sender \(name)")
        }
        
    }
    
    /**
     ** All of the actions directly under the 'Appearance' menu
     **/
    func appearanceActions(sender: AnyObject){
        var menu : NSMenuItem = sender as! NSMenuItem
        let name = menu.title
        switch name {
        case "Translucent":
            if menu.state == NSOnState {
                menu.state = NSOffState
                didDisableTranslucency()
            }
            else {
                menu.state = NSOnState
                didEnableTranslucency()
            }
        default:
            NSLog("Error: Unknown sender \(name)")
        }
    }
    
    /**
     ** All of the actions directly under the 'Opacity' submenu
     **/
    func changeOpacity(sender: AnyObject){
        for it in opacityMenu.submenu!.itemArray{
            let mItem = it as! NSMenuItem;
            mItem.state = NSOffState
        }
        var menu : NSMenuItem = sender as! NSMenuItem
        menu.state = NSOnState
        let name = menu.title
        let num = name[name.startIndex..<(name.endIndex.predecessor())].toInt()
        didUpdateAlpha(num!)
    }
    
    /**
     ** All of the actions directly under the 'Zoom' submenu
     **/
    func zoomActions(sender: AnyObject){
        var menu : NSMenuItem = sender as! NSMenuItem
        let name = menu.title
        switch name {
        case "Zoom In":
            webView.zoomIn()
        case "Zoom Out":
            webView.zoomOut()
        case "Reset Zoom":
            webView.resetZoom()
        default:
            NSLog("Error: Unknown sender \(name)")
        }
    }

    //MARK: Control Actions
    
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
    
    func didUpdateAlpha(newAlpha : Int) {
        alpha = CGFloat(newAlpha) / CGFloat(100.0)
    }
}