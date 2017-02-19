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
    
    
    private var panel: NSPanel! {
        get {
            return (self.window as! NSPanel)
        }
    }
    
    
    // MARK: Window lifecycle
    override func windowDidLoad() {
        panel.floatingPanel = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HeliumPanelController.didBecomeActive), name: NSApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HeliumPanelController.willResignActive), name: NSApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HeliumPanelController.didUpdateTitle(_:)), name: "HeliumUpdateTitle", object: nil)
        
        setFloatOverFullScreenApps()
        if let alpha = NSUserDefaults.standardUserDefaults().objectForKey(UserSetting.OpacityPercentage.userDefaultsKey) {
            didUpdateAlpha(CGFloat(alpha as! Int))
        }
    }

    // MARK : Mouse events
    override func mouseEntered(theEvent: NSEvent) {
        mouseOver = true
        updateTranslucency()
    }
    
    override func mouseExited(theEvent: NSEvent) {
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
        if NSUserDefaults.standardUserDefaults().boolForKey(UserSetting.DisabledFullScreenFloat.userDefaultsKey) {
            panel.collectionBehavior = [.MoveToActiveSpace, .FullScreenAuxiliary]

        } else {
            panel.collectionBehavior = [.CanJoinAllSpaces, .FullScreenAuxiliary]
        }
    }
    
    //MARK: IBActions
    
    private func disabledAllMouseOverPreferences(allMenus: [NSMenuItem]) {
        // GROSS HARD CODED
        for x in allMenus.dropFirst(2) {
            x.state = NSOffState
        }
    }
    
    @IBAction private func alwaysPreferencePress(sender: NSMenuItem) {
        disabledAllMouseOverPreferences(sender.menu!.itemArray)
        translucencyPreference = .Always
        sender.state = NSOnState
    }
    
    @IBAction private func overPreferencePress(sender: NSMenuItem) {
        disabledAllMouseOverPreferences(sender.menu!.itemArray)
        translucencyPreference = .MouseOver
        sender.state = NSOnState
    }
    
    @IBAction private func outsidePreferencePress(sender: NSMenuItem) {
        disabledAllMouseOverPreferences(sender.menu!.itemArray)
        translucencyPreference = .MouseOutside
        sender.state = NSOnState
    }
    
    @IBAction private func translucencyPress(sender: NSMenuItem) {
        if sender.state == NSOnState {
            sender.state = NSOffState
            didDisableTranslucency()
        }
        else {
            sender.state = NSOnState
            didEnableTranslucency()
        }
    }
    
    @IBAction private func percentagePress(sender: NSMenuItem) {
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
    
    @IBAction private func openLocationPress(sender: AnyObject) {
        didRequestLocation()
    }
    
    @IBAction private func openFilePress(sender: AnyObject) {
        didRequestFile()
    }
    
    @IBAction private func floatOverFullScreenAppsToggled(sender: NSMenuItem) {
        sender.state = (sender.state == NSOnState) ? NSOffState : NSOnState
        NSUserDefaults.standardUserDefaults().setBool((sender.state == NSOffState), forKey: UserSetting.DisabledFullScreenFloat.userDefaultsKey)
        
        setFloatOverFullScreenApps()
    }

    var autoHideTitle : Bool = false
    @IBAction private func autoHideTitle(sender: NSMenuItem) {
        sender.state = (sender.state == NSOnState) ? NSOffState : NSOnState
        NSUserDefaults.standardUserDefaults().setBool((sender.state == NSOffState), forKey: UserSetting.AutoHideTitle.userDefaultsKey)
    }
    
    @IBAction func setHomePage(sender: AnyObject){
        didRequestChangeHomepage()
    }

	//MARK: Actual functionality
	
    @objc private func didUpdateTitle(notification: NSNotification) {
        if let title = notification.object as? String {
            panel.title = title
        }
    }
    
    private func didRequestFile() {
        
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
	
    private func didRequestLocation() {
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
    
    func didRequestChangeHomepage(){
        let alert = NSAlert()
        alert.alertStyle = NSAlertStyle.InformationalAlertStyle
        alert.messageText = "Enter new Home Page URL"
        
        let urlField = NSTextField()
		urlField.stringValue = NSUserDefaults.standardUserDefaults().stringForKey(UserSetting.HomePageURL.userDefaultsKey)!
        urlField.frame = NSRect(x: 0, y: 0, width: 300, height: 20)
        urlField.lineBreakMode = NSLineBreakMode.ByTruncatingHead
        urlField.usesSingleLineMode = true
        
        alert.accessoryView = urlField
        alert.addButtonWithTitle("Set")
        alert.addButtonWithTitle("Cancel")
		let defaultButton = alert.addButtonWithTitle("Default")
		defaultButton.toolTip = Constants.defaultURL
        alert.beginSheetModalForWindow(self.window!, completionHandler: { response in
			var text : String
			switch response {
			case NSAlertThirdButtonReturn:
				text = Constants.defaultURL
				break

			case NSAlertFirstButtonReturn:
				text = (alert.accessoryView as! NSTextField).stringValue
				break
				
			case NSAlertSecondButtonReturn:
				text = NSUserDefaults.standardUserDefaults().stringForKey(UserSetting.HomePageURL.userDefaultsKey)!
				break

			default:
				text = ""
			}

			if !text.isEmpty {
				
				// Add prefix if necessary
				if !(text.lowercaseString.hasPrefix("http://") || text.lowercaseString.hasPrefix("https://")) {
					text = "http://" + text
				}

				// Save to defaults if valid. Else, use Helium default page
				if self.validateURL(text) {
					NSUserDefaults.standardUserDefaults().setObject(text, forKey: UserSetting.HomePageURL.userDefaultsKey)
				} else {
					NSUserDefaults.standardUserDefaults().setObject(Constants.defaultURL, forKey: UserSetting.HomePageURL.userDefaultsKey)
				}
				
                // Load new Home page
                self.webViewController.loadAlmostURL(NSUserDefaults.standardUserDefaults().stringForKey(UserSetting.HomePageURL.userDefaultsKey)!)
			}
        })
    }
	
	func validateURL (stringURL : String) -> Bool {
        
        let urlRegEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[urlRegEx])
        
        return predicate.evaluateWithObject(stringURL)
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
    
    private func didUpdateAlpha(newAlpha: CGFloat) {
        alpha = newAlpha / 100
    }
}