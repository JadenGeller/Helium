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
        dispatch_async(dispatch_get_main_queue()) {
            self.window?.makeFirstResponder(self)
        }
    }
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

    
    enum TranslucencyPreference {
        case Always
        case MouseOver
        case MouseOutside
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HeliumPanelController.doPlaylistItem(_:)), name: "HeliumPlaylistItem", object: nil)

        setFloatOverFullScreenApps()
        if let alpha = NSUserDefaults.standardUserDefaults().objectForKey(UserSetting.OpacityPercentage.userDefaultsKey) {
            didUpdateAlpha(CGFloat(alpha as! Int))
        }

		//	Sync translucencyEnabled to preference; all delegate sync'd the menu state
		translucencyEnabled = NSUserDefaults.standardUserDefaults().boolForKey(UserSetting.Translucency.userDefaultsKey)
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
        if translucencyEnabled == true {
            didDisableTranslucency()
        }
        else {
             didEnableTranslucency()
        }
		//	Sync preference and internal flag and state
		sender.state = translucencyEnabled == true ? NSOnState : NSOffState
		NSUserDefaults.standardUserDefaults().setBool((translucencyEnabled), forKey: UserSetting.Translucency.userDefaultsKey)
		print("translucencyEnabled \(translucencyEnabled) state \(sender.state)")
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

    var autoHideTitle : Bool = false
    @IBAction func autoHideTitle(sender: NSMenuItem) {
        sender.state = (sender.state == NSOnState) ? NSOffState : NSOnState
        NSUserDefaults.standardUserDefaults().setBool((sender.state == NSOnState), forKey: UserSetting.AutoHideTitle.userDefaultsKey)
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
        
        let urlField = HeliumTextView.init(frame: NSMakeRect(0,0,300,28))
        let urlScroll = NSScrollView.init(frame: NSMakeRect(0,0,300,28))
        urlScroll.hasVerticalScroller = true
        urlScroll.autohidesScrollers = true
        urlField.drawsBackground = true
        urlField.editable = true

        urlScroll.documentView = urlField
        alert.accessoryView = urlScroll

        alert.addButtonWithTitle("Load")
        alert.addButtonWithTitle("Cancel")

        alert.beginSheetModalForWindow(self.window!, completionHandler: { response in
            if response == NSAlertFirstButtonReturn {
                // Load
                let view = (alert.accessoryView as! NSScrollView).documentView as! NSTextView
                let text = view.string! as String
                self.webViewController.loadAlmostURL(text)
            }
        })
    }
    
    func didRequestChangeHomepage(){
        let alert = NSAlert()
        alert.alertStyle = NSAlertStyle.InformationalAlertStyle
        alert.messageText = "Enter new Home Page URL"
        
        let urlField = HeliumTextView.init(frame: NSMakeRect(0,0,300,28))
        let urlScroll = NSScrollView.init(frame: NSMakeRect(0,0,300,28))
        let urlFont = NSFont.systemFontOfSize(NSFont.systemFontSize())
        let urlAttr = [NSFontAttributeName : urlFont]
        let urlString = NSUserDefaults.standardUserDefaults().stringForKey(UserSetting.HomePageURL.userDefaultsKey)!
        urlField.insertText(NSAttributedString.init(string: urlString, attributes: urlAttr), replacementRange: NSMakeRange(0, 0))
        urlField.drawsBackground = true
        urlField.editable = true

        urlScroll.documentView = urlField
        alert.accessoryView = urlScroll

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
                let view = (alert.accessoryView as! NSScrollView).documentView as! NSTextView
                text = view.string! as String
                break
                
            case NSAlertSecondButtonReturn:
                return

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

    @objc private func doPlaylistItem(notification: NSNotification) {
        if let playlist = notification.object {
            let playlistText = (playlist as! NSURL).absoluteString
            self.webViewController.loadAlmostURL(playlistText)
        }
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