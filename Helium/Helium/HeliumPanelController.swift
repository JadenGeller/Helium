//
//  HeliumPanelController.swift
//  Helium
//
//  Created by Jaden Geller on 4/9/15.
//  Copyright (c) 2015 Jaden Geller. All rights reserved.
//

import AppKit

class HeliumPanelController : NSWindowController {

    private var webViewController: WebViewController {
        get {
            return self.window?.contentViewController as! WebViewController
        }
    }

    private var mouseOver: Bool = false
    
    private var alpha: CGFloat = 0.6 { //default
        didSet {
            updateTranslucency()
        }
    }
    
    private var translucencyPreference: TranslucencyPreference = .Always {
        didSet {
            updateTranslucency()
        }
    }
    
    private var translucencyEnabled: Bool = false {
        didSet {
            updateTranslucency()
        }
    }

    
    private  enum TranslucencyPreference {
        case Always
        case MouseOver
        case MouseOutside
    }
    
    private var currentlyTranslucent: Bool = false {
        didSet {
            if !NSApplication.shared.isActive {
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
    
    
    private var panel: NSPanel! {
        get {
            return (self.window as! NSPanel)
        }
    }
    
    
    // MARK: Window lifecycle
    override func windowDidLoad() {
        panel.isFloatingPanel = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(HeliumPanelController.didBecomeActive), name: NSApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HeliumPanelController.willResignActive), name: NSApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HeliumPanelController.didUpdateTitle(_:)), name: NSNotification.Name(rawValue: "HeliumUpdateTitle"), object: nil)
        
        setFloatOverFullScreenApps()
        if let alpha = UserDefaults.standard.object(forKey: UserSetting.OpacityPercentage.userDefaultsKey) {
            didUpdateAlpha(CGFloat(alpha as! Int))
        }
    }

    // MARK : Mouse events
    override func mouseEntered(with event: NSEvent) {
        mouseOver = true
        updateTranslucency()
    }
    
    override func mouseExited(with event: NSEvent) {
        mouseOver = false
        updateTranslucency()
    }
    
    // MARK : Translucency
    private func updateTranslucency() {
        currentlyTranslucent = shouldBeTranslucent()
    }
    
    private func shouldBeTranslucent() -> Bool {
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
    
    
    private func setFloatOverFullScreenApps() {
        if UserDefaults.standard.bool(forKey: UserSetting.DisabledFullScreenFloat.userDefaultsKey) {
            panel.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]

        } else {
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        }
    }
    
    //MARK: IBActions
    
    private func disabledAllMouseOverPreferences(_ allMenus: [NSMenuItem]) {
        // GROSS HARD CODED
        for x in allMenus.dropFirst(2) {
            x.state = .off
        }
    }
    
    @IBAction private func alwaysPreferencePress(_ sender: NSMenuItem) {
        disabledAllMouseOverPreferences(sender.menu!.items)
        translucencyPreference = .Always
        sender.state = .on
    }
    
    @IBAction private func overPreferencePress(_ sender: NSMenuItem) {
        disabledAllMouseOverPreferences(sender.menu!.items)
        translucencyPreference = .MouseOver
        sender.state = .on
    }
    
    @IBAction private func outsidePreferencePress(_ sender: NSMenuItem) {
        disabledAllMouseOverPreferences(sender.menu!.items)
        translucencyPreference = .MouseOutside
        sender.state = .on
    }
    
    @IBAction private func translucencyPress(_ sender: NSMenuItem) {
        if sender.state == .on {
            sender.state = .off
            didDisableTranslucency()
        }
        else {
            sender.state = .on
            didEnableTranslucency()
        }
    }
    
    @IBAction private func percentagePress(_ sender: NSMenuItem) {
        for button in sender.menu!.items{
            (button ).state = .off
        }
        sender.state = .on
        let title = sender.title
        if let alpha = Int(String(title.dropLast())) {
             didUpdateAlpha(CGFloat(alpha))
            UserDefaults.standard.set(alpha, forKey: UserSetting.OpacityPercentage.userDefaultsKey)
        }
    }
    
    @IBAction private func openLocationPress(_ sender: AnyObject) {
        didRequestLocation()
    }
    
    @IBAction private func openFilePress(_ sender: AnyObject) {
        didRequestFile()
    }
    
    @IBAction private func floatOverFullScreenAppsToggled(_ sender: NSMenuItem) {
        sender.state = (sender.state == .on) ? .off : .on
        UserDefaults.standard.set((sender.state == .off), forKey: UserSetting.DisabledFullScreenFloat.userDefaultsKey)
        
        setFloatOverFullScreenApps()
    }

	@IBAction private func hideTitle(_ sender: NSMenuItem) {
        if sender.state == .on {
            sender.state = .off
            panel.styleMask = .borderless
        }
        else {
            sender.state = .on
            panel.styleMask = NSWindow.StyleMask(rawValue: 8345)
        }
	}
    
    @IBAction func setHomePage(_ sender: AnyObject){
        didRequestChangeHomepage()
    }
    
    //MARK: Actual functionality
    
    @objc private func didUpdateTitle(_ notification: Notification) {
        if let title = notification.object as? String {
            panel.title = title
        }
    }
    
    private func didRequestFile() {
        
        let open = NSOpenPanel()
        open.allowsMultipleSelection = false
        open.canChooseFiles = true
        open.canChooseDirectories = false
        
        if open.runModal() == .OK {
            if let url = open.url {
                webViewController.loadURL(url)
            }
        }
    }
    
    
    private func didRequestLocation() {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = "Enter Destination URL"
        
        let urlField = NSTextField()
        urlField.frame = NSRect(x: 0, y: 0, width: 300, height: 20)
        urlField.lineBreakMode = .byTruncatingHead
        urlField.usesSingleLineMode = true
        
        alert.accessoryView = urlField
        alert.accessoryView!.becomeFirstResponder()
        alert.addButton(withTitle: "Load")
        alert.addButton(withTitle: "Cancel")
        alert.beginSheetModal(for: self.window!, completionHandler: { response in
            if response == .alertFirstButtonReturn {
                // Load
                let text = (alert.accessoryView as! NSTextField).stringValue
                self.webViewController.loadAlmostURL(text)
            }
        })
    }
    
    func didRequestChangeHomepage() {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = "Enter new Home Page URL"
        
        let urlField = NSTextField()
        urlField.frame = NSRect(x: 0, y: 0, width: 300, height: 20)
        urlField.lineBreakMode = .byTruncatingHead
        urlField.usesSingleLineMode = true
        
        alert.accessoryView = urlField
        alert.addButton(withTitle: "Set")
        alert.addButton(withTitle: "Cancel")
        alert.beginSheetModal(for: self.window!, completionHandler: { response in
            if response == .alertFirstButtonReturn {
                var text = (alert.accessoryView as! NSTextField).stringValue
                
                // Add prefix if necessary
                if !(text.lowercased().hasPrefix("http://") || text.lowercased().hasPrefix("https://")) {
                    text = "http://" + text
                }

                // Save to defaults if valid. Else, use Helium default page
                if self.validateURL(text) {
                    UserDefaults.standard.set(text, forKey: UserSetting.HomePageURL.userDefaultsKey)
                }
                else{
                    UserDefaults.standard.set("https://cdn.rawgit.com/JadenGeller/Helium/master/helium_start.html", forKey: UserSetting.HomePageURL.userDefaultsKey)
                }
                
                // Load new Home page
                self.webViewController.loadAlmostURL(UserDefaults.standard.string(forKey: UserSetting.HomePageURL.userDefaultsKey)!)
            }
        })
    }
    
    func validateURL(_ stringURL: String) -> Bool {
        
        let urlRegEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[urlRegEx])
        
        return predicate.evaluate(with: stringURL)
    }
        
    @objc private func didBecomeActive() {
        panel.ignoresMouseEvents = false
    }
    
    @objc private func willResignActive() {
        if currentlyTranslucent {
            panel.ignoresMouseEvents = true
        }
    }
    
    private func didEnableTranslucency() {
        translucencyEnabled = true
    }
    
    private func didDisableTranslucency() {
        translucencyEnabled = false
    }
    
    private func didUpdateAlpha(_ newAlpha: CGFloat) {
        alpha = newAlpha / 100
    }
}
