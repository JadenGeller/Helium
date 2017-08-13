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

    fileprivate var webViewController: WebViewController {
        get {
            return self.window?.contentViewController as! WebViewController
        }
    }

    fileprivate var mouseOver: Bool = false
    
    fileprivate var alpha: CGFloat = 0.6 { //default
        didSet {
            updateTranslucency()
        }
    }
    
    fileprivate var translucencyPreference: TranslucencyPreference = .always {
        didSet {
            updateTranslucency()
        }
    }
    
    fileprivate var translucencyEnabled: Bool = false {
        didSet {
            updateTranslucency()
        }
    }

    
    fileprivate  enum TranslucencyPreference {
        case always
        case mouseOver
        case mouseOutside
    }
    
    fileprivate var currentlyTranslucent: Bool = false {
        didSet {
            if !NSApplication.shared().isActive {
                panel.ignoresMouseEvents = currentlyTranslucent
            }
            if currentlyTranslucent {
                panel.animator().alphaValue = alpha
                panel.isOpaque = false
            }
            else {
                panel.isOpaque = true
                panel.animator().alphaValue = 1
            }
        }
    }
    
    
    fileprivate var panel: NSPanel! {
        get {
            return (self.window as! NSPanel)
        }
    }
    
    
    // MARK: Window lifecycle
    override func windowDidLoad() {
        panel.isFloatingPanel = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(HeliumPanelController.didBecomeActive), name: NSNotification.Name.NSApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HeliumPanelController.willResignActive), name: NSNotification.Name.NSApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HeliumPanelController.didUpdateTitle(_:)), name: NSNotification.Name(rawValue: "HeliumUpdateTitle"), object: nil)
        
        setFloatOverFullScreenApps()
        if let alpha = UserDefaults.standard.object(forKey: UserSetting.opacityPercentage.userDefaultsKey) {
            didUpdateAlpha(CGFloat(alpha as! Int))
        }
    }

    // MARK : Mouse events
    override func mouseEntered(with theEvent: NSEvent) {
        mouseOver = true
        updateTranslucency()
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        mouseOver = false
        updateTranslucency()
    }
    
    // MARK : Translucency
    fileprivate func updateTranslucency() {
        currentlyTranslucent = shouldBeTranslucent()
    }
    
    fileprivate func shouldBeTranslucent() -> Bool {
        /* Implicit Arguments
         * - mouseOver
         * - translucencyPreference
         * - tranlucencyEnalbed
         */
        
        guard translucencyEnabled else { return false }
        
        switch translucencyPreference {
        case .always:
            return true
        case .mouseOver:
            return mouseOver
        case .mouseOutside:
            return !mouseOver
        }
    }
    
    
    fileprivate func setFloatOverFullScreenApps() {
        if UserDefaults.standard.bool(forKey: UserSetting.disabledFullScreenFloat.userDefaultsKey) {
            panel.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]

        } else {
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        }
    }
    
    //MARK: IBActions
    
    fileprivate func disabledAllMouseOverPreferences(_ allMenus: [NSMenuItem]) {
        // GROSS HARD CODED
        for x in allMenus.dropFirst(2) {
            x.state = NSOffState
        }
    }
    
    @IBAction fileprivate func alwaysPreferencePress(_ sender: NSMenuItem) {
        disabledAllMouseOverPreferences(sender.menu!.items)
        translucencyPreference = .always
        sender.state = NSOnState
    }
    
    @IBAction fileprivate func overPreferencePress(_ sender: NSMenuItem) {
        disabledAllMouseOverPreferences(sender.menu!.items)
        translucencyPreference = .mouseOver
        sender.state = NSOnState
    }
    
    @IBAction fileprivate func outsidePreferencePress(_ sender: NSMenuItem) {
        disabledAllMouseOverPreferences(sender.menu!.items)
        translucencyPreference = .mouseOutside
        sender.state = NSOnState
    }
    
    @IBAction fileprivate func translucencyPress(_ sender: NSMenuItem) {
        if sender.state == NSOnState {
            sender.state = NSOffState
            didDisableTranslucency()
        }
        else {
            sender.state = NSOnState
            didEnableTranslucency()
        }
    }
    
    @IBAction fileprivate func percentagePress(_ sender: NSMenuItem) {
        for button in sender.menu!.items{
            (button ).state = NSOffState
        }
        sender.state = NSOnState
        let value = sender.title.substring(to: sender.title.characters.index(sender.title.endIndex, offsetBy: -1))
        if let alpha = Int(value) {
             didUpdateAlpha(CGFloat(alpha))
             UserDefaults.standard.set(alpha, forKey: UserSetting.opacityPercentage.userDefaultsKey)
        }
    }
    
    @IBAction fileprivate func openLocationPress(_ sender: AnyObject) {
        didRequestLocation()
    }
    
    @IBAction fileprivate func openFilePress(_ sender: AnyObject) {
        didRequestFile()
    }
    
    @IBAction fileprivate func floatOverFullScreenAppsToggled(_ sender: NSMenuItem) {
        sender.state = (sender.state == NSOnState) ? NSOffState : NSOnState
        UserDefaults.standard.set((sender.state == NSOffState), forKey: UserSetting.disabledFullScreenFloat.userDefaultsKey)
        
        setFloatOverFullScreenApps()
    }

	@IBAction fileprivate func hideTitle(_ sender: NSMenuItem) {
	   if sender.state == NSOnState {
	       sender.state = NSOffState
	       panel.styleMask = NSBorderlessWindowMask
	   }
	   else {
	       sender.state = NSOnState
	       panel.styleMask = NSWindowStyleMask(rawValue: 8345)
	   }
	}
    
    @IBAction func setHomePage(_ sender: AnyObject){
        didRequestChangeHomepage()
    }
    
    //MARK: Actual functionality
    
    @objc fileprivate func didUpdateTitle(_ notification: Notification) {
        if let title = notification.object as? String {
            panel.title = title
        }
    }
    
    fileprivate func didRequestFile() {
        
        let open = NSOpenPanel()
        open.allowsMultipleSelection = false
        open.canChooseFiles = true
        open.canChooseDirectories = false
        
        if open.runModal() == NSModalResponseOK {
            if let url = open.url {
                webViewController.loadURL(url)
            }
        }
    }
    
    
    fileprivate func didRequestLocation() {
        let alert = NSAlert()
        alert.alertStyle = NSAlertStyle.informational
        alert.messageText = "Enter Destination URL"
        
        let urlField = NSTextField()
        urlField.frame = NSRect(x: 0, y: 0, width: 300, height: 20)
        urlField.lineBreakMode = NSLineBreakMode.byTruncatingHead
        urlField.usesSingleLineMode = true
        
        alert.accessoryView = urlField
        //alert.accessoryView!.becomeFirstResponder()
        alert.addButton(withTitle: "Load")
        alert.addButton(withTitle: "Cancel")
        alert.beginSheetModal(for: self.window!, completionHandler: { response in
            if response == NSAlertFirstButtonReturn {
                // Load
                let text = (alert.accessoryView as! NSTextField).stringValue
                self.webViewController.loadAlmostURL(text)
            }
        })
        urlField.becomeFirstResponder()
    }
    
    func didRequestChangeHomepage(){
        let alert = NSAlert()
        alert.alertStyle = NSAlertStyle.informational
        alert.messageText = "Enter new Home Page URL"
        
        let urlField = NSTextField()
        urlField.frame = NSRect(x: 0, y: 0, width: 300, height: 20)
        urlField.lineBreakMode = NSLineBreakMode.byTruncatingHead
        urlField.usesSingleLineMode = true
        
        alert.accessoryView = urlField
        alert.addButton(withTitle: "Set")
        alert.addButton(withTitle: "Cancel")
        alert.beginSheetModal(for: self.window!, completionHandler: { response in
            if response == NSAlertFirstButtonReturn {
                var text = (alert.accessoryView as! NSTextField).stringValue
                
                // Add prefix if necessary
                if !(text.lowercased().hasPrefix("http://") || text.lowercased().hasPrefix("https://")) {
                    text = "http://" + text
                }

                // Save to defaults if valid. Else, use Helium default page
                if self.validateURL(text) {
                    UserDefaults.standard.set(text, forKey: UserSetting.homePageURL.userDefaultsKey)
                }
                else{
                    UserDefaults.standard.set("https://cdn.rawgit.com/brorbw/Helium/master/helium_start.html", forKey: UserSetting.homePageURL.userDefaultsKey)
                }
                
                // Load new Home page
                self.webViewController.loadAlmostURL(UserDefaults.standard.string(forKey: UserSetting.homePageURL.userDefaultsKey)!)
            }
        })
    }
//
    func validateURL (_ stringURL : String) -> Bool {
        
        let urlRegEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[urlRegEx])
        
        return predicate.evaluate(with: stringURL)
    }
        
    @objc fileprivate func didBecomeActive() {
        panel.ignoresMouseEvents = false
    }
    
    @objc fileprivate func willResignActive() {
        if currentlyTranslucent {
            panel.ignoresMouseEvents = true
        }
    }
    
    fileprivate func didEnableTranslucency() {
        translucencyEnabled = true
    }
    
    fileprivate func didDisableTranslucency() {
        translucencyEnabled = false
    }
    
    fileprivate func didUpdateAlpha(_ newAlpha: CGFloat) {
        alpha = newAlpha / 100
    }
}
