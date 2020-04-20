//
//  HeliumPanelController.swift
//  Helium
//
//  Created by Jaden Geller on 4/9/15.
//  Copyright (c) 2015 Jaden Geller. All rights reserved.
//

import AppKit

class HeliumPanelController: NSWindowController, NSWindowDelegate {

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
    func windowDidResize(_ notification: Notification) {
        print("UPDATE")
    }
    
    override func windowDidLoad() {
        panel.isFloatingPanel = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(HeliumPanelController.didBecomeActive), name: NSApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HeliumPanelController.willResignActive), name: NSApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HeliumPanelController.didUpdateTitle(_:)), name: NSNotification.Name(rawValue: "HeliumUpdateTitle"), object: nil)
        
        setFloatOverFullScreenApps()
        didUpdateAlpha(CGFloat(UserSetting.opacityPercentage))
    }

    // MARK: Mouse events
    override func mouseEntered(with event: NSEvent) {
        mouseOver = true
        updateTranslucency()
    }
    
    override func mouseExited(with event: NSEvent) {
        mouseOver = false
        updateTranslucency()
    }
    
    // MARK: Translucency
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
        if UserSetting.disabledFullScreenFloat {
            panel.collectionBehavior.insert(.moveToActiveSpace)
            panel.collectionBehavior.remove(.canJoinAllSpaces)

        } else {
            panel.collectionBehavior.remove(.moveToActiveSpace)
            panel.collectionBehavior.insert(.canJoinAllSpaces)
        }
    }
        
    private func disabledAllMouseOverPreferences(_ allMenus: [NSMenuItem]) {
        // GROSS HARD CODED
        for x in allMenus.dropFirst(2) {
            x.state = .off
        }
    }
    
    @objc func alwaysPreferencePress(_ sender: NSMenuItem) {
        disabledAllMouseOverPreferences(sender.menu!.items)
        translucencyPreference = .Always
        sender.state = .on
    }
    
    @objc func overPreferencePress(_ sender: NSMenuItem) {
        disabledAllMouseOverPreferences(sender.menu!.items)
        translucencyPreference = .MouseOver
        sender.state = .on
    }
    @objc  
    func outsidePreferencePress(_ sender: NSMenuItem) {
        disabledAllMouseOverPreferences(sender.menu!.items)
        translucencyPreference = .MouseOutside
        sender.state = .on
    }
    
    @objc func translucencyPress(_ sender: NSMenuItem) {
        if sender.state == .on {
            sender.state = .off
            didDisableTranslucency()
        }
        else {
            sender.state = .on
            didEnableTranslucency()
        }
    }
    
    @objc func percentagePress(_ sender: NSMenuItem) {
        for button in sender.menu!.items{
            (button ).state = .off
        }
        sender.state = .on
        let title = sender.title
        if let alpha = Int(String(title.dropLast())) {
             didUpdateAlpha(CGFloat(alpha))
            UserSetting.opacityPercentage = alpha
        }
    }
    
    @objc func openLocationPress(_ sender: AnyObject) {
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
        urlField.becomeFirstResponder()
    }
    
    @objc func openFilePress(_ sender: AnyObject) {
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
    
    @objc func floatOverFullScreenAppsToggled(_ sender: NSMenuItem) {
        sender.state = (sender.state == .on) ? .off : .on
        UserSetting.disabledFullScreenFloat = sender.state == .off
        
        setFloatOverFullScreenApps()
    }

    @objc func hideTitle(_ sender: NSMenuItem) {
        if sender.state == .on {
            sender.state = .off
            panel.styleMask = .borderless
        }
        else {
            sender.state = .on
            panel.styleMask = [
                .hudWindow,
                .nonactivatingPanel,
                .utilityWindow,
                .resizable,
                .titled
            ]
        }
	}
    
    @objc func setHomePage(_ sender: AnyObject){
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
                    UserSetting.homePageURL = text
                }
                else{
                    UserSetting.homePageURL = nil
                }
            }
        })
    }
    
    //MARK: Actual functionality
    
    @objc private func didUpdateTitle(_ notification: Notification) {
        if let title = notification.object as? String {
            panel.title = title
        }
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
