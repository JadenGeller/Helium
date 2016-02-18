//
//  HeliumPanelController.swift
//  Helium
//
//  Created by Jaden Geller on 4/9/15.
//  Copyright (c) 2015 Jaden Geller. All rights reserved.
//

import AppKit

let optionKeyCode: UInt16 = 58

class HeliumPanelController : NSWindowController {

    var mouseOver: Bool = false
    override func mouseEntered(theEvent: NSEvent) {
        mouseOver = true
        updateTranslucency()
    }
    
    override func mouseExited(theEvent: NSEvent) {
        mouseOver = false
        updateTranslucency()
    }
    
    var alpha: CGFloat = 0.6 { //default
        didSet {
            updateTranslucency()
        }
    }
    
    func updateTranslucency() {
        currentlyTranslucent = shouldBeTranslucent()
    }
    
    func shouldBeTranslucent() -> Bool {
        /* Implicit Arguments
         * - mouseOver
         * - translucencyPreference
         * - tranlucencyEnalbed
         */
        
        guard translucencyEnabled else { return false }
        
        switch translucencyPreference {
        case .Always:
            return true
        case .MouseOver:
            return mouseOver
        case .MouseOutside:
            return !mouseOver
        }
    }
    
    enum TranslucencyPreference {
        case Always
        case MouseOver
        case MouseOutside
    }
    
    var translucencyPreference: TranslucencyPreference = .Always {
        didSet {
            updateTranslucency()
        }
    }
    
    var translucencyEnabled: Bool = false {
        didSet {
            updateTranslucency()
        }
    }
    
    var currentlyTranslucent: Bool = false {
        didSet {
            if !NSApplication.sharedApplication().active {
                panel.ignoresMouseEvents = currentlyTranslucent
            }
            if currentlyTranslucent {
                panel.animator().alphaValue = alpha
                panel.opaque = false
            }
            else {
                panel.opaque = true
                panel.animator().alphaValue = 1
            }
        }
    }
    
    
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
    

    override func windowDidLoad() {
        panel.floatingPanel = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didBecomeActive", name: NSApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willResignActive", name: NSApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdateTitle:", name: "HeliumUpdateTitle", object: nil)
        
        setFloatOverFullScreenApps()
        if let alpha = NSUserDefaults.standardUserDefaults().objectForKey(UserSetting.OpacityPercentage.userDefaultsKey) {
            didUpdateAlpha(CGFloat(alpha as! Int))
        }
    }
    
    func setFloatOverFullScreenApps() {
        if NSUserDefaults.standardUserDefaults().boolForKey(UserSetting.DisabledFullScreenFloat.userDefaultsKey) {
            panel.collectionBehavior = [.MoveToActiveSpace, .FullScreenAuxiliary]

        } else {
            panel.collectionBehavior = [.CanJoinAllSpaces, .FullScreenAuxiliary]
        }
    }
    
    //MARK: IBActions
    
    func disabledAllMouseOverPreferences(allMenus: [NSMenuItem]) {
        // GROSS HARD CODED
        for x in allMenus.dropFirst(2) {
            x.state = NSOffState
        }
    }
    
    @IBAction func alwaysPreferencePress(sender: NSMenuItem) {
        disabledAllMouseOverPreferences(sender.menu!.itemArray)
        translucencyPreference = .Always
        sender.state = NSOnState
    }
    @IBAction func overPreferencePress(sender: NSMenuItem) {
        disabledAllMouseOverPreferences(sender.menu!.itemArray)
        translucencyPreference = .MouseOver
        sender.state = NSOnState
    }
    @IBAction func outsidePreferencePress(sender: NSMenuItem) {
        disabledAllMouseOverPreferences(sender.menu!.itemArray)
        translucencyPreference = .MouseOutside
        sender.state = NSOnState
    }
    
    @IBAction func translucencyPress(sender: NSMenuItem) {
        if sender.state == NSOnState {
            sender.state = NSOffState
            didDisableTranslucency()
        }
        else {
            sender.state = NSOnState
            didEnableTranslucency()
        }
    }
    
    @IBAction func percentagePress(sender: NSMenuItem) {
        for button in sender.menu!.itemArray{
            (button ).state = NSOffState
        }
        sender.state = NSOnState
        let value = sender.title.substringToIndex(sender.title.endIndex.advancedBy(-1))
        if let alpha = Int(value) {
             didUpdateAlpha(CGFloat(alpha))
             NSUserDefaults.standardUserDefaults().setInteger(alpha, forKey: UserSetting.OpacityPercentage.userDefaultsKey)
        }
    }
    
    @IBAction func openLocationPress(sender: AnyObject) {
        didRequestLocation()
    }
    
    @IBAction func openFilePress(sender: AnyObject) {
        didRequestFile()
    }
    
    @IBAction func floatOverFullScreenAppsToggled(sender: NSMenuItem) {
        sender.state = (sender.state == NSOnState) ? NSOffState : NSOnState
        NSUserDefaults.standardUserDefaults().setBool((sender.state == NSOffState), forKey: UserSetting.DisabledFullScreenFloat.userDefaultsKey)
        
        setFloatOverFullScreenApps()
    }
    
    //MARK: Actual functionality
    
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
        urlField.lineBreakMode = NSLineBreakMode.ByTruncatingHead
        urlField.usesSingleLineMode = true
        
        alert.accessoryView = urlField
        alert.addButtonWithTitle("Load")
        alert.addButtonWithTitle("Cancel")
        alert.beginSheetModalForWindow(self.window!, completionHandler: { response in
            if response == NSAlertFirstButtonReturn {
                // Load
                let text = (alert.accessoryView as! NSTextField).stringValue
                self.webViewController.loadAlmostURL(text)
            }
        })
    }
    
    func didBecomeActive() {
        panel.ignoresMouseEvents = false
    }
    
    func willResignActive() {
        if currentlyTranslucent {
            panel.ignoresMouseEvents = true
        }
    }
    
    func didEnableTranslucency() {
        translucencyEnabled = true
    }
    
    func didDisableTranslucency() {
        translucencyEnabled = false
    }
    
    func didUpdateAlpha(newAlpha: CGFloat) {
        alpha = newAlpha / 100
    }
}