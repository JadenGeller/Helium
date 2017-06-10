//
//  HeliumPanelController.swift
//  Helium
//
//  Created by Jaden Geller on 4/9/15.
//  Copyright (c) 2015 Jaden Geller. All rights reserved.
//

import AppKit

let optionKeyCode: UInt16 = 58

struct Constants {
    static let defaultURL = "https://cdn.rawgit.com/JadenGeller/Helium/master/helium_start.html"
    static let PlayList = "PlayList"
    static let PlayItem = "PlayItem"
}

class HeliumTextView : NSTextView {
    override func viewWillDraw() {
        DispatchQueue.main.async {
            self.window?.makeFirstResponder(self)
        }
    }
}

class HeliumPanelController : NSWindowController {

    var webViewController: WebViewController {
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
    
    var translucencyPreference: TranslucencyPreference = .always {
        didSet {
            updateTranslucency()
        }
    }
    
    var translucencyEnabled: Bool = false {
        didSet {
            updateTranslucency()
        }
    }

    
    enum TranslucencyPreference {
        case always
        case mouseOver
        case mouseOutside
    }
    
    var currentlyTranslucent: Bool = false {
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
        NotificationCenter.default.addObserver(self, selector: #selector(HeliumPanelController.doPlaylistItem(_:)), name: NSNotification.Name(rawValue: "HeliumPlaylistItem"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(HeliumPanelController.setFloatOverFullScreenApps), name: NSNotification.Name(rawValue: UserSetting.disabledFullScreenFloat.userDefaultsKey), object:nil)

        setFloatOverFullScreenApps()
        if let alpha = UserDefaults.standard.object(forKey: UserSetting.opacityPercentage.userDefaultsKey) {
            didUpdateAlpha(CGFloat(alpha as! Int))
        }

		//	Sync translucencyEnabled to preference; all delegate sync'd the menu state
		translucencyEnabled = UserDefaults.standard.bool(forKey: UserSetting.translucency.userDefaultsKey)
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
	
    //MARK: IBActions
    
    fileprivate func disabledAllMouseOverPreferences(_ allMenus: [NSMenuItem]) {
        // GROSS HARD CODED
        for x in allMenus.dropFirst(2) {
            x.state = NSOffState
        }
    }
    
    @IBAction func alwaysPreferencePress(_ sender: NSMenuItem) {
        disabledAllMouseOverPreferences(sender.menu!.items)
        translucencyPreference = .always
        sender.state = NSOnState
    }
    
    @IBAction func overPreferencePress(_ sender: NSMenuItem) {
        disabledAllMouseOverPreferences(sender.menu!.items)
        translucencyPreference = .mouseOver
        sender.state = NSOnState
    }
    
    @IBAction func outsidePreferencePress(_ sender: NSMenuItem) {
        disabledAllMouseOverPreferences(sender.menu!.items)
        translucencyPreference = .mouseOutside
        sender.state = NSOnState
    }
    
    @IBAction func translucencyPress(_ sender: NSMenuItem) {
        if translucencyEnabled == true {
            didDisableTranslucency()
        }
        else {
            didEnableTranslucency()
        }
		//	Sync preference and internal flag and state
//		sender.state = translucencyEnabled == true ? NSOnState : NSOffState
		UserDefaults.standard.set((translucencyEnabled), forKey: UserSetting.translucency.userDefaultsKey)
    }
    
    @IBAction func percentagePress(_ sender: NSMenuItem) {
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
			menuItem.state = UserDefaults.standard.bool(forKey: UserSetting.disabledFullScreenFloat.userDefaultsKey) ? NSOffState : NSOnState
			break;
		case "Magic URL Redirects":
			menuItem.state = UserDefaults.standard.bool(forKey: UserSetting.disabledMagicURLs.userDefaultsKey) ? NSOffState : NSOnState
			break
		case "Auto-hide Title Bar":
			menuItem.state = UserDefaults.standard.bool(forKey: UserSetting.autoHideTitle.userDefaultsKey) ? NSOnState : NSOffState
			break
		case "Enabled": //Transluceny Menu
			menuItem.state = UserDefaults.standard.bool(forKey: UserSetting.translucency.userDefaultsKey) ? NSOnState : NSOffState
			break
			
		default:
			break
		}
		Swift.print("wc.item \(menuItem) is \(menuItem.state)")
		return true
	}

	//MARK: Actual functionality
    
	@objc fileprivate func setFloatOverFullScreenApps() {
		if UserDefaults.standard.bool(forKey: UserSetting.disabledFullScreenFloat.userDefaultsKey) {
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
                webViewController.loadURL(url)
            }
        }
    }
    
    fileprivate func didRequestLocation() {
        let alert = NSAlert()
		var text: String = ""
        alert.alertStyle = NSAlertStyle.informational
        alert.messageText = "Enter Destination URL"
        
        let urlField = HeliumTextView.init(frame: NSMakeRect(0,0,300,28))
        let urlScroll = NSScrollView.init(frame: NSMakeRect(0,0,300,28))
        urlScroll.hasVerticalScroller = true
        urlScroll.autohidesScrollers = true
        urlField.drawsBackground = true
        urlField.isEditable = true

        urlScroll.documentView = urlField
        alert.accessoryView = urlScroll

        alert.addButton(withTitle: "Load")
        alert.addButton(withTitle: "Cancel")
		let defaultButton = alert.addButton(withTitle: "Home")
		defaultButton.toolTip = Constants.defaultURL

        alert.beginSheetModal(for: self.window!, completionHandler: { response in
			switch (response) {
			case NSAlertFirstButtonReturn:
				// Load
				let view = (alert.accessoryView as! NSScrollView).documentView as! NSTextView
				text = view.string! as String
				break
			case NSAlertThirdButtonReturn:
				text = Constants.defaultURL as String
				break
			default:
				return
			}
			self.webViewController.loadAlmostURL(text)
        })
    }

    @objc fileprivate func doPlaylistItem(_ notification: Notification) {
        if let playlist = notification.object {
            let playlistText = (playlist as! URL).absoluteString
            self.webViewController.loadAlmostURL(playlistText)
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
