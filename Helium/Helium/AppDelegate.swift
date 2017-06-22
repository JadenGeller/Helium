//
//  AppDelegate.swift
//  Helium
//
//  Created by Jaden Geller on 4/9/15.
//  Copyright (c) 2015 Jaden Geller. All rights reserved.
//
//  We have user IBAction centrally here, share by panel and webView controllers
//  The design is to centrally house the preferences and notify these interested
//  parties via notification.  In this way all menu state can be consistency for
//  statusItem, main menu, and webView contextual menu.
//
import Cocoa

struct RequestUserUrlStrings {
    let currentURL: String?
    let alertMessageText: String
    let alertButton1stText: String
    let alertButton1stInfo: String?
    let alertButton2ndText: String
    let alertButton2ndInfo: String?
    let alertButton3rdText: String?
    let alertButton3rdInfo: String?
}

fileprivate class URLField: NSTextField {
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        if let textEditor = currentEditor() {
            textEditor.selectAll(self)
        }
    }
    
    convenience init(withValue: String?) {
        self.init()
        
        if let string = withValue {
            self.stringValue = string
        }
        self.lineBreakMode = NSLineBreakMode.byTruncatingHead
        self.usesSingleLineMode = true
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {

    @IBOutlet weak var magicURLMenu: NSMenuItem!
    @IBOutlet weak var percentageMenu: NSMenuItem!
    @IBOutlet weak var fullScreenFloatMenu: NSMenuItem!
    @IBOutlet weak var autoHideTitleMenu: NSMenuItem!

    fileprivate var alpha: CGFloat = 60 {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(rawValue: UserSettings.opacityPercentage.keyPath), object: nil)
        }
    }
    
    fileprivate func didUpdateAlpha(_ newAlpha: CGFloat) {
        alpha = newAlpha / 100
    }
    
    fileprivate func disabledAllMouseOverPreferences(_ allMenus: [NSMenuItem]) {
        // GROSS HARD CODED
        for x in allMenus.dropFirst(2) {
            x.state = NSOffState
        }
    }
    
    @IBOutlet weak var translucencyMenu: NSMenuItem!
    fileprivate var translucencyPreference: TranslucencyPreference = .never {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(rawValue: UserSettings.translucencyPreference.keyPath), object: nil)
        }
    }
    
    enum TranslucencyPreference: Int {
        case never = 0
        case always = 1
        case mouseOver = 2
        case mouseOutside = 3
    }
    
    //  MARK:- Global IBAction
    @IBOutlet weak var appMenu: NSMenu!
    @IBOutlet weak var appItem: NSMenuItem!
    let appStatusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    internal func menuClicked(_ sender: AnyObject) {
        if let menuItem = sender as? NSMenuItem {
            Swift.print("Menu '\(menuItem.title)' clicked")
        }
    }
    @IBAction func autoHideTitlePress(_ sender: NSMenuItem) {
        let keyPath = UserSettings.autoHideTitle.keyPath
        UserSettings.autoHideTitle.value = (sender.state == NSOffState)
        NotificationCenter.default.post(name: Notification.Name(rawValue: keyPath), object: nil)
    }
    @IBAction func floatOverFullScreenAppsPress(_ sender: NSMenuItem) {
        let keyPath = UserSettings.disabledFullScreenFloat.keyPath
        UserSettings.disabledFullScreenFloat.value = (sender.state == NSOnState)
        NotificationCenter.default.post(name: Notification.Name(rawValue: keyPath), object: nil)
    }
    @IBAction func homePagePress(_ sender: AnyObject) {
        didRequestUserUrl(RequestUserUrlStrings (
            currentURL: UserSettings.homePageURL.value,
            alertMessageText: "Enter new home Page URL",
            alertButton1stText: "Set",      alertButton1stInfo: nil,
            alertButton2ndText: "Cancel",   alertButton2ndInfo: nil,
            alertButton3rdText: "Default",  alertButton3rdInfo: UserSettings.homePageURL.default),
                          onWindow: NSApp.keyWindow as? HeliumPanel,
                          acceptHandler: { (newUrl: String) in
                            UserSettings.homePageURL.value = newUrl
        }
        )
    }

    @IBAction func magicURLRedirectPress(_ sender: NSMenuItem) {
        let keyPath = UserSettings.disabledMagicURLs.keyPath
        UserSettings.disabledMagicURLs.value = (sender.state == NSOnState)
        NotificationCenter.default.post(name: Notification.Name(rawValue: keyPath), object: nil)
    }
    
    @IBAction func openLocationPress(_ sender: AnyObject) {
        didRequestUserUrl(RequestUserUrlStrings (
            currentURL: UserSettings.homePageURL.value,
            alertMessageText: "Enter Destination URL",
            alertButton1stText: "Load",     alertButton1stInfo: nil,
            alertButton2ndText: "Cancel",   alertButton2ndInfo: nil,
            alertButton3rdText: "Home",     alertButton3rdInfo: UserSettings.homePageURL.value),
                          onWindow: NSApp.keyWindow as? HeliumPanel,
                          acceptHandler: { (newUrl: String) in
                            UserSettings.homePageURL.value = newUrl
        }
        )
    }
    
    @IBAction func percentagePress(_ sender: NSMenuItem) {
        UserSettings.opacityPercentage.value = sender.tag
        NotificationCenter.default.post(name: Notification.Name(rawValue: UserSettings.opacityPercentage.keyPath), object: nil)
    }
    
    @IBAction func translucencyPress(_ sender: NSMenuItem) {
        disabledAllMouseOverPreferences(sender.menu!.items)
        UserSettings.translucencyPreference.value = AppDelegate.TranslucencyPreference(rawValue: sender.tag)!.rawValue
        translucencyPreference = AppDelegate.TranslucencyPreference(rawValue: UserSettings.translucencyPreference.value)! 
        NotificationCenter.default.post(name: Notification.Name(rawValue: UserSettings.translucencyPreference.keyPath), object: nil)
    }

    @IBAction func quitPress(_ sender: AnyObject) {
        NSApplication.shared().terminate(self)
    }

    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem.title {
        case "Preferences":
            break
        case "Auto-hide Title Bar":
            menuItem.state = UserSettings.autoHideTitle.value ? NSOnState : NSOffState
            break
        //Transluceny Menu
        case "Never":
            menuItem.state = translucencyPreference == .never ? NSOnState : NSOffState
            break
        case "Always":
            menuItem.state = translucencyPreference == .always ? NSOnState : NSOffState
            break
        case "Mouse Over":
            menuItem.state = translucencyPreference == .mouseOver ? NSOnState : NSOffState
            break
        case "Mouse Outside":
            menuItem.state = translucencyPreference == .mouseOutside ? NSOnState : NSOffState
            break
        case "Float Above All Spaces":
            menuItem.state = UserSettings.disabledFullScreenFloat.value ? NSOffState : NSOnState
            break;
        case "Home Page":
            break
        case "Magic URL Redirects":
            menuItem.state = UserSettings.disabledMagicURLs.value ? NSOffState : NSOnState
            break
        case "Quit":
            break

        default:
            // Opacity menu item have opacity as tag value
            if menuItem.tag >= 10 {
                menuItem.state = (menuItem.tag == UserSettings.opacityPercentage.value ? NSOnState : NSOffState)
            }
            break
        }

        return true;
    }

    //  MARK:- Lifecyle

    let toHMS = hmsTransformer()
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(AppDelegate.handleURLEvent(_:withReply:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )

        //    So they can interact everywhere with us without focus
        appStatusItem.image = NSImage.init(named: "statusIcon")
        appStatusItem.menu = appMenu

        //  Initialize our h:m:s transformer
        ValueTransformer.setValueTransformer(toHMS, forName: NSValueTransformerName(rawValue: "hmsTransformer"))
        
        // Maintain a history of titles
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(AppDelegate.didUpdateTitle(_:)),
            name: NSNotification.Name(rawValue: "HeliumNewURL"),
            object: nil)
    }

    var histories = Array<PlayItem>()
    var defaults = UserDefaults.standard

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        let alpha = UserSettings.opacityPercentage.value
        let offset = alpha/10 - 1
        for (index, button) in percentageMenu.submenu!.items.enumerated() {
            (button).state = (offset == index) ? NSOnState : NSOffState
        }

        translucencyPreference = AppDelegate.TranslucencyPreference(rawValue: UserSettings.translucencyPreference.value)!

        // Load histories from defaults
        if let items = defaults.array(forKey: UserSettings.Histories.keyPath) {
            for playitem in items {
                let item = playitem as! Dictionary <String,AnyObject>
                let name = item[k.name] as! String
                let path = item[k.link] as! String
                let time = item[k.time] as? TimeInterval
                let link = URL.init(string: path)
                let rank = item[k.rank] as! Int
                let temp = PlayItem(name:name, link:link!, time:time!, rank:rank)
                histories.append(temp)
            }
        }
   }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application

        // Save histories to defaults
        var temp = Array<AnyObject>()
        for item in histories {
            let item : [String:AnyObject] = [k.name:item.name as AnyObject, k.link:item.link.absoluteString as AnyObject, k.time:item.time as AnyObject, k.rank:item.rank as AnyObject]
            temp.append(item as AnyObject)
        }
        defaults.set(temp, forKey: UserSettings.Histories.keyPath)
        defaults.synchronize()
    }

    //MARK: - handleURLEvent(s)

    func metadataDictionaryForFileAt(_ fileName: String) -> Dictionary<NSObject,AnyObject>? {
        
        let item = MDItemCreate(kCFAllocatorDefault, fileName as CFString)
        if ( item == nil) { return nil };
        
        let list = MDItemCopyAttributeNames(item)
        let resDict = MDItemCopyAttributes(item,list) as Dictionary
        return resDict
    }

    @objc fileprivate func didUpdateTitle(_ notification: Notification) {
        if let itemURL = notification.object as? URL {
            let item: PlayItem = PlayItem.init()

            if (itemURL as AnyObject).isFileReferenceURL() {
                let fileURL : URL? = (itemURL as AnyObject).filePathURL
                let path = fileURL!.absoluteString//.stringByRemovingPercentEncoding
                let attr = metadataDictionaryForFileAt((fileURL?.path)!)
                let fuzz = (itemURL as AnyObject).deletingPathExtension!!.lastPathComponent as NSString
                item.name = fuzz.removingPercentEncoding!
                item.link = URL.init(string: path)!
                item.time = attr?[kMDItemDurationSeconds] as! TimeInterval
                item.rank = histories.count + 1
                histories.append(item)
            }
            else
            {
                let fuzz = (itemURL as AnyObject).deletingPathExtension!!.lastPathComponent as NSString
                let name = fuzz.removingPercentEncoding

                item.name = name!
                item.link = itemURL
                item.time = 0
                item.rank = histories.count + 1
            }
            print("\(histories.count) -> \(String(describing: histories.last?.name))")
            histories.append(item)
        }
    }
    
    /// Shows alert asking user to input URL on their window or floating.
    /// Process response locally, validate, dispatch via supplied handler
    func didRequestUserUrl(_ strings: RequestUserUrlStrings,
                           onWindow: HeliumPanel?,
                           acceptHandler: @escaping (String) -> Void) {
        
        // Create alert
        let alert = NSAlert()
        alert.alertStyle = NSAlertStyle.informational
        alert.messageText = strings.alertMessageText
        
        // Create urlField
        let urlField = URLField(withValue: strings.currentURL)
        urlField.frame = NSRect(x: 0, y: 0, width: 300, height: 20)
        
        // Add urlField and buttons to alert
        alert.accessoryView = urlField
        let alert1stButton = alert.addButton(withTitle: strings.alertButton1stText)
        if let alert1stToolTip = strings.alertButton1stInfo {
            alert1stButton.toolTip = alert1stToolTip
        }
        let alert2ndButton = alert.addButton(withTitle: strings.alertButton2ndText)
        if let alert2ndtToolTip = strings.alertButton2ndInfo {
            alert2ndButton.toolTip = alert2ndtToolTip
        }
        if let alert3rdText = strings.alertButton3rdText {
            let alert3rdButton = alert.addButton(withTitle: alert3rdText)
            if let alert3rdtToolTip = strings.alertButton3rdInfo {
                alert3rdButton.toolTip = alert3rdtToolTip
            }
        }

        if let urlWindow = onWindow {
            alert.beginSheetModal(for: urlWindow, completionHandler: { response in
                // buttons are accept, cancel, default
                if response == NSAlertThirdButtonReturn {
                    var newUrl = (alert.buttons[2] as NSButton).toolTip
                    newUrl = UrlHelpers.ensureScheme(newUrl!)
                    if UrlHelpers.isValid(urlString: newUrl!) {
                        acceptHandler(newUrl!)
                    }
                }
                else
                if response == NSAlertFirstButtonReturn {
                    // swiftlint:disable:next force_cast
                    var newUrl = (alert.accessoryView as! NSTextField).stringValue
                    newUrl = UrlHelpers.ensureScheme(newUrl)
                    if UrlHelpers.isValid(urlString: newUrl) {
                        acceptHandler(newUrl)
                    }
                }
            })
        }
        else {
            switch alert.runModal() {
            case NSAlertThirdButtonReturn:
                var newUrl = (alert.buttons[2] as NSButton).toolTip
                newUrl = UrlHelpers.ensureScheme(newUrl!)
                if UrlHelpers.isValid(urlString: newUrl!) {
                    acceptHandler(newUrl!)
                }

                break
                
            case NSAlertFirstButtonReturn:
                var newUrl = (alert.accessoryView as! NSTextField).stringValue
                newUrl = UrlHelpers.ensureScheme(newUrl)
                if UrlHelpers.isValid(urlString: newUrl) {
                    acceptHandler(newUrl)
                }

            default:// NSAlertSecondButtonReturn:
                return
            }
        }
        
        // Set focus on urlField
        alert.accessoryView!.becomeFirstResponder()
    }

    
    // Called when the App opened via URL.
    @objc func handleURLEvent(_ event: NSAppleEventDescriptor, withReply reply: NSAppleEventDescriptor) {
        
        guard let keyDirectObject = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject)),
            let urlString = keyDirectObject.stringValue else {
                return print("No valid URL to handle")
        }

        //  strip helium://
        let index = urlString.index(urlString.startIndex, offsetBy: 9)
        let url = urlString.substring(from: index)

        NotificationCenter.default.post(name: Notification.Name(rawValue: "HeliumLoadURL"), object: url)
    }

    @objc func handleURLPboard(_ pboard: NSPasteboard, userData: NSString, error: NSErrorPointer) {
        if let selection = pboard.string(forType: NSPasteboardTypeString) {
            // Notice: string will contain whole selection, not just the urls
            // So this may (and will) fail. It should instead find url in whole
            // Text somehow
            NotificationCenter.default.post(name: Notification.Name(rawValue: "HeliumLoadURL"), object: selection)
        }
    }
}

