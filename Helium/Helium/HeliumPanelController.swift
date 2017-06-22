//
//  HeliumPanelController.swift
//  Helium
//
//  Created by Jaden Geller on 4/9/15.
//  Copyright (c) 2015 Jaden Geller. All rights reserved.
//

import AppKit

class HeliumPanelController : NSWindowController {

    var webViewController: WebViewController {
        get {
            return self.window?.contentViewController as! WebViewController
        }
    }

    fileprivate var panel: HeliumPanel! {
        get {
            return (self.window as! HeliumPanel)
        }
    }
    
    
    // MARK: Window lifecycle
    fileprivate var lastStyle : Int = 0
    override func windowDidLoad() {
        panel.isFloatingPanel = true
        lastStyle = Int(panel.styleMask.rawValue)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(HeliumPanelController.didBecomeActive),
            name: NSNotification.Name.NSApplicationDidBecomeActive,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(HeliumPanelController.willResignActive),
            name: NSNotification.Name.NSApplicationWillResignActive,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(HeliumPanelController.didUpdateTitle(_:)),
            name: NSNotification.Name(rawValue: "HeliumUpdateTitle"),
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(HeliumPanelController.doPlaylistItem(_:)),
            name: NSNotification.Name(rawValue: "HeliumPlaylistItem"),
            object: nil)

        // MARK: Load settings from UserSettings

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(HeliumPanelController.setFloatOverFullScreenApps),
            name: NSNotification.Name(rawValue: UserSettings.disabledFullScreenFloat.keyPath),
            object:nil)
        setFloatOverFullScreenApps()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(HeliumPanelController.willUpdateTitleBar),
            name: NSNotification.Name(rawValue: UserSettings.autoHideTitle.keyPath),
            object:nil)
        willUpdateTitleBar()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(HeliumPanelController.willUpdateTranslucency),
            name: NSNotification.Name(rawValue: UserSettings.translucencyPreference.keyPath),
            object:nil)
        willUpdateTranslucency()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(HeliumPanelController.willUpdateAlpha),
            name: NSNotification.Name(rawValue: UserSettings.opacityPercentage.keyPath),
            object:nil)
       willUpdateAlpha()

    }

    // MARK:- Mouse events
    override func mouseEntered(with theEvent: NSEvent) {
        mouseOver = true
        updateTranslucency()

        if UserSettings.autoHideTitle.value == true {
            panel.titleVisibility = NSWindowTitleVisibility.visible;
            panel.styleMask = NSWindowStyleMask(rawValue: UInt(lastStyle))
            
            let notif = Notification(name: Notification.Name(rawValue: "HeliumUpdateTitle"),
                                     object: UserSettings.windowTitle.value);
            NotificationCenter.default.post(notif)
        }
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        mouseOver = false
        updateTranslucency()

        if UserSettings.autoHideTitle.value == true {
            panel.titleVisibility = NSWindowTitleVisibility.hidden;
            panel.styleMask = NSWindowStyleMask.borderless
        }
    }
    
    // MARK:- Translucency
    fileprivate var mouseOver: Bool = false
    
    fileprivate var alpha: CGFloat = 0.6 { //default
        didSet {
            updateTranslucency()
        }
    }
    
    var translucencyPreference: TranslucencyPreference = .never {
        didSet {
             updateTranslucency()
        }
    }
    
    enum TranslucencyPreference: Int {
        case never = 0
        case always = 1
        case mouseOver = 2
        case mouseOutside = 3
    }

    @objc fileprivate func updateTranslucency() {
        currentlyTranslucent = shouldBeTranslucent()
    }
    
    fileprivate var currentlyTranslucent: Bool = false {
        didSet {
            if !NSApplication.shared().isActive {
                panel.ignoresMouseEvents = currentlyTranslucent
            }
            if currentlyTranslucent {
                panel.animator().alphaValue = alpha
                panel.isOpaque = false
            } else {
                panel.isOpaque = true
                panel.animator().alphaValue = 1
            }
        }
    }

    fileprivate func shouldBeTranslucent() -> Bool {
        /* Implicit Arguments
         * - mouseOver
         * - translucencyPreference
         */
        
        switch translucencyPreference {
        case .never:
            return false
        case .always:
            return true
        case .mouseOver:
            return mouseOver
        case .mouseOutside:
            return !mouseOver
        }
    }
	
    //MARK:- IBActions
    
    fileprivate func disabledAllMouseOverPreferences(_ allMenus: [NSMenuItem]) {
        // GROSS HARD CODED
        for x in allMenus.dropFirst(2) {
            x.state = NSOffState
        }
    }
    
    @IBAction func openLocationPress(_ sender: AnyObject) {
        didRequestLocation()
    }
    
    @IBAction func openFilePress(_ sender: AnyObject) {
        didRequestFile()
    }
    
	override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		switch menuItem.title {
		case "Preferences":
			break
		case "Float Above All Spaces":
			menuItem.state = UserSettings.disabledFullScreenFloat.value ? NSOffState : NSOnState
			break;
		case "Magic URL Redirects":
			menuItem.state = UserSettings.disabledMagicURLs.value ? NSOffState : NSOnState
			break
		case "Auto-hide Title Bar":
			menuItem.state = UserSettings.autoHideTitle.value ? NSOnState : NSOffState
			break
        case "Never": //Transluceny Menu
            menuItem.state = menuItem.tag == HeliumPanelController.TranslucencyPreference.never.rawValue ? NSOnState : NSOffState
            break
        case "Always": //Transluceny Menu
            menuItem.state = menuItem.tag == HeliumPanelController.TranslucencyPreference.always.rawValue ? NSOnState : NSOffState
            break
        case "Mouse Over": //Transluceny Menu
            menuItem.state = menuItem.tag == HeliumPanelController.TranslucencyPreference.mouseOver.rawValue ? NSOnState : NSOffState
            break
		case "Mouse Outside": //Transluceny Menu
			menuItem.state = menuItem.tag == HeliumPanelController.TranslucencyPreference.mouseOutside.rawValue ? NSOnState : NSOffState
			break
			
		default:
			break
		}
		return true
	}

    //MARK:- Notifications
    @objc fileprivate func willUpdateAlpha() {
        let alpha = UserSettings.opacityPercentage.value
        didUpdateAlpha(CGFloat(alpha))
    }
    @objc fileprivate func willUpdateTranslucency() {
        switch (UserSettings.translucencyPreference.value) {
        case 0:
            translucencyPreference = .never
            break
        case 1:
            translucencyPreference = .always
            break
        case 2:
            translucencyPreference = .mouseOver
            break
        case 3:
            translucencyPreference = .mouseOutside
            break
        default:
            break
        }
       updateTranslucency()
    }

    
    @objc func willUpdateTitleBar() {
        if UserSettings.autoHideTitle.value == true {
            panel.titleVisibility = NSWindowTitleVisibility.hidden;
            panel.styleMask = NSWindowStyleMask.borderless
        } else {
            panel.titleVisibility = NSWindowTitleVisibility.visible;
            panel.styleMask = NSWindowStyleMask(rawValue: UInt(lastStyle))
        }
        
        let notif = Notification(name: Notification.Name(rawValue: "HeliumUpdateTitle"),
                                 object: UserSettings.windowTitle.value);
        NotificationCenter.default.post(notif)
    }
    
    //MARK:- Actual functionality
    
	@objc fileprivate func setFloatOverFullScreenApps() {
		if UserSettings.disabledFullScreenFloat.value {
			panel.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
		} else {
			panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
		}
	}

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
                webViewController.loadURL(url:url)
            }
        }
    }
    
    fileprivate func didRequestLocation() {
        let appDelegate: AppDelegate = NSApp.delegate as! AppDelegate
        
        appDelegate.didRequestUserUrl(RequestUserUrlStrings (
            currentURL: self.webViewController.currentURL,
            alertMessageText: "Enter new home Page URL",
            alertButton1stText: "Load",     alertButton1stInfo: nil,
            alertButton2ndText: "Cancel",   alertButton2ndInfo: nil,
            alertButton3rdText: "Home",     alertButton3rdInfo: UserSettings.homePageURL.value),
                          onWindow: self.window as? HeliumPanel,
                          acceptHandler: { (newUrl: String) in
                            self.webViewController.loadURL(text: newUrl)
        }
        )
    }

    @objc fileprivate func doPlaylistItem(_ notification: Notification) {
        if let playlist = notification.object {
            let playlistURL = playlist as! URL
            self.webViewController.loadURL(url: playlistURL)
        }
    }

    @objc fileprivate func didBecomeActive() {
        panel.ignoresMouseEvents = false
    }
    
    @objc fileprivate func willResignActive() {
        if currentlyTranslucent {
            panel.ignoresMouseEvents = true
        }
    }
    
    fileprivate func didUpdateAlpha(_ newAlpha: CGFloat) {
        alpha = newAlpha / 100
    }
}
