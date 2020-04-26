//
//  HeliumWindowController.swift
//  Helium
//
//  Created by Jaden Geller on 4/9/15.
//  Copyright (c) 2015 Jaden Geller. All rights reserved.
//

import AppKit
import OpenCombine

class HeliumWindowController: NSWindowController, NSWindowDelegate {
    convenience init() {
        self.init(window: nil)
    }
    
    // FIXME: Don't use IUO or var here
    var toolbar: HeliumToolbar!
    private override init(window: NSWindow?) {
        precondition(window == nil, "call init() with no window")
        let webController = WebViewController()
        webController.view.frame.size = .init(width: 480, height: 300)
        let window = HeliumWindow(contentViewController: webController)
        window.bind(.title, to: webController, withKeyPath: "title", options: nil)
                
        super.init(window: window)
        window.delegate = self

        // FIXME: Are there memeory leaks here?
        toolbar = HeliumToolbar { [unowned self] action in
            switch action {
            case .navigate(.back):
                webController.webView.goBack()
            case .navigate(.forward):
                webController.webView.goForward()
            case .navigate(.toLocation(let location)):
                webController.loadAlmostURL(location)
            case .hideToolbar:
                self.toolbarVisibility = .hidden
            }
        }

        
        window.titleVisibility = .hidden
        window.toolbar = toolbar
        
        NotificationCenter.default.addObserver(self, selector: #selector(HeliumWindowController.didBecomeActive), name: NSApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HeliumWindowController.willResignActive), name: NSApplication.willResignActiveNotification, object: nil)
                
        cancellables.append(UserSetting.$disabledFullScreenFloat.sink { [unowned self] disabledFullScreenFloat in
            if disabledFullScreenFloat {
                self.window!.collectionBehavior.insert(.moveToActiveSpace)
                self.window!.collectionBehavior.remove(.canJoinAllSpaces)

            } else {
                self.window!.collectionBehavior.remove(.moveToActiveSpace)
                self.window!.collectionBehavior.insert(.canJoinAllSpaces)
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
        cancellables.append(UserSetting.$toolbarVisibility.assign(to: \.toolbarVisibility, on: self))
    }
    
    var toolbarVisibility: ToolbarVisibility = UserSetting.toolbarVisibility {
        didSet {
            switch toolbarVisibility {
            case .visible:
                window!.styleMask.insert(.titled)
                window!.toolbar = toolbar
            case .hidden:
                window!.styleMask.remove(.titled)
                window!.toolbar = nil
            }
        }
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
            window!.ignoresMouseEvents = shouldBeTranslucentForMouseState
        }
        if shouldBeTranslucentForMouseState {
            window!.animator().alphaValue = CGFloat(UserSetting.opacityPercentage) / 100
            window!.isOpaque = false
        }
        else {
            window!.isOpaque = true
            window!.animator().alphaValue = 1
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


    func validateURL(_ stringURL: String) -> Bool {
        
        let urlRegEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[urlRegEx])
        
        return predicate.evaluate(with: stringURL)
    }
        
    @objc private func didBecomeActive() {
        window!.ignoresMouseEvents = false
    }
    
    @objc private func willResignActive() {
        guard let window = window else { return }
        window.ignoresMouseEvents = !window.isOpaque
    }
}
