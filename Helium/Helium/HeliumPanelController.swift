//
//  HeliumPanelController.swift
//  Helium
//
//  Created by Jaden Geller on 4/9/15.
//  Copyright (c) 2015 Jaden Geller. All rights reserved.
//

import AppKit
import OpenCombine

class HeliumPanel: NSPanel {
    override func cancelOperation(_ sender: Any?) {
        // Override default behavior to prevent panel from closing
    }
}

class HeliumPanelController: NSWindowController, NSWindowDelegate {
    convenience init() {
        self.init(window: nil)
    }
    private override init(window: NSWindow?) {
        precondition(window == nil, "call init() with no window")
        let webController = WebViewController()
        webController.view.frame.size = .init(width: 480, height: 300)
        let panel = HeliumPanel(contentViewController: webController)
        panel.styleMask = [
            .hudWindow,
            .utilityWindow,
            .nonactivatingPanel,
            .titled,
            .resizable,
            .closable
        ]
        panel.level = .mainMenu
        panel.hidesOnDeactivate = false
        panel.hasShadow = true
        panel.isFloatingPanel = true
        panel.center()
        panel.isMovableByWindowBackground = true
        
        super.init(window: panel)

        panel.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(HeliumPanelController.didBecomeActive), name: NSApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HeliumPanelController.willResignActive), name: NSApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HeliumPanelController.didUpdateTitle(_:)), name: NSNotification.Name(rawValue: "HeliumUpdateTitle"), object: nil)
                
        cancellables.append(UserSetting.$disabledFullScreenFloat.sink { [unowned self] disabledFullScreenFloat in
            if disabledFullScreenFloat {
                self.panel.collectionBehavior.insert(.moveToActiveSpace)
                self.panel.collectionBehavior.remove(.canJoinAllSpaces)

            } else {
                self.panel.collectionBehavior.remove(.moveToActiveSpace)
                self.panel.collectionBehavior.insert(.canJoinAllSpaces)
            }
        })
        cancellables.append(UserSetting.$translucencyMode.sink { [unowned self] _ in
            self.updateTranslucency()
        })
        cancellables.append(UserSetting.$translucencyEnabled.sink { [unowned self] _ in
            self.updateTranslucency()
        })
        cancellables.append(UserSetting.$opacityPercentage.sink { [unowned self] _ in
            self.updateTranslucency()
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var webViewController: WebViewController {
        get {
            return self.window?.contentViewController as! WebViewController
        }
    }

    private var mouseOver: Bool = false
    
    var shouldBeTranslucentForMouseState: Bool {
        guard UserSetting.translucencyEnabled else { return false }
        
        switch UserSetting.translucencyMode {
        case .always:
            return true
        case .mouseOver:
            return mouseOver
        case .mouseOutside:
            return !mouseOver
        }
    }
    
    func updateTranslucency() {
        if !NSApplication.shared.isActive {
            panel.ignoresMouseEvents = shouldBeTranslucentForMouseState
        }
        if shouldBeTranslucentForMouseState {
            panel.animator().alphaValue = CGFloat(UserSetting.opacityPercentage) / 100
            panel.isOpaque = false
        }
        else {
            panel.isOpaque = true
            panel.animator().alphaValue = 1
        }
    }
    
    private var panel: NSPanel! {
        get {
            return (self.window as! NSPanel)
        }
    }
    
    
    // MARK: Window lifecycle
    
    var cancellables: [AnyCancellable] = []

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
        panel.ignoresMouseEvents = !panel.isOpaque
    }
}
