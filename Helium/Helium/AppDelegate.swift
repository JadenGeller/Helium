//
//  AppDelegate.swift
//  Helium
//
//  Created by Jaden Geller on 4/9/15.
//  Copyright (c) 2015 Jaden Geller. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {

    @IBOutlet weak var magicURLMenu: NSMenuItem!
    @IBOutlet weak var percentageMenu: NSMenuItem!
    @IBOutlet weak var fullScreenFloatMenu: NSMenuItem!

	@IBOutlet weak var autoHideTitleMenu: NSMenuItem!
	var autoHideTitle : Bool = UserDefaults.standard.bool(forKey: UserSetting.autoHideTitle.userDefaultsKey)

	@IBOutlet weak var translucencyMenu: NSMenuItem!
	@IBOutlet var window: NSWindow!
	@IBOutlet weak var appMenu: NSMenu!
	@IBOutlet weak var appItem: NSMenuItem!
	let appStatusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
	
	internal func menuClicked(_ sender: AnyObject) {
		if let menuItem = sender as? NSMenuItem {
			Swift.print("Menu '\(menuItem.title)' clicked")
		}
	}
	@IBAction func floatOverFullScreenAppsPress(_ sender: NSMenuItem) {
		let keyPath = UserSetting.disabledFullScreenFloat.userDefaultsKey
		sender.state = (sender.state == NSOnState) ? NSOffState : NSOnState
		UserDefaults.standard.set((sender.state == NSOffState), forKey: keyPath)
		NotificationCenter.default.post(name: Notification.Name(rawValue: keyPath), object: nil)
	}
	
	@IBAction func homePagePress(_ sender: AnyObject) {
		let alert = NSAlert()
		alert.alertStyle = NSAlertStyle.informational
		alert.messageText = "Enter new Home Page URL"
		
		let urlField = HeliumTextView.init(frame: NSMakeRect(0,0,300,28))
		let urlScroll = NSScrollView.init(frame: NSMakeRect(0,0,300,28))
		let urlFont = NSFont.systemFont(ofSize: NSFont.systemFontSize())
		let urlAttr = [NSFontAttributeName : urlFont]
		let urlString = UserDefaults.standard.string(forKey: UserSetting.homePageURL.userDefaultsKey)!
		urlField.insertText(NSAttributedString.init(string: urlString, attributes: urlAttr), replacementRange: NSMakeRange(0, 0))
		urlField.drawsBackground = true
		urlField.isEditable = true
		
		urlScroll.documentView = urlField
		alert.accessoryView = urlScroll
		
		alert.addButton(withTitle: "Set")
		alert.addButton(withTitle: "Cancel")
		let defaultButton = alert.addButton(withTitle: "Default")
		defaultButton.toolTip = Constants.defaultURL
	
		//	Run alert modally allowing non-active usage
		var text : String
		switch alert.runModal() {
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
			if !(text.lowercased().hasPrefix("http://") || text.lowercased().hasPrefix("https://")) {
				text = "http://" + text
			}
			
			// Save to defaults if valid. Else, use Helium default page
			if text.isValidURL() {
				UserDefaults.standard.set(text, forKey: UserSetting.homePageURL.userDefaultsKey)
			} else {
				UserDefaults.standard.set(Constants.defaultURL, forKey: UserSetting.homePageURL.userDefaultsKey)
			}
		}
	}
	@IBAction func autoHideTitle(_ sender: NSMenuItem) {
		sender.state = (sender.state == NSOnState) ? NSOffState : NSOnState
		UserDefaults.standard.set((sender.state == NSOnState), forKey: UserSetting.autoHideTitle.userDefaultsKey)
	}

	override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		switch menuItem.title {
		case "Preferences":
			break
		case "Auto-hide Title Bar":
			menuItem.state = UserDefaults.standard.bool(forKey: UserSetting.autoHideTitle.userDefaultsKey) ? NSOnState : NSOffState
			break
		case "Enabled": //Transluceny Menu
			menuItem.state = UserDefaults.standard.bool(forKey: UserSetting.translucency.userDefaultsKey) ? NSOnState : NSOffState
			break
		case "Float Above All Spaces":
			menuItem.state = UserDefaults.standard.bool(forKey: UserSetting.disabledFullScreenFloat.userDefaultsKey) ? NSOffState : NSOnState
			break;
		case "Home Page":
			break
		case "Magic URL Redirects":
			menuItem.state = UserDefaults.standard.bool(forKey: UserSetting.disabledMagicURLs.userDefaultsKey) ? NSOffState : NSOnState
			break
		case "Quit":
			break

		default:
			break
		}
		Swift.print("item \(menuItem) is \(menuItem.state)")

		return true;
	}
	@IBAction func appPress(_ sender: NSMenuItem) {
		Swift.print("Menu '\(sender.title)' clicked")
	}

	@IBAction func quitPress(_ sender: AnyObject) {
		NSApplication.shared().terminate(self)
	}

    let toHMS = hmsTransformer()
	func applicationWillFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(AppDelegate.handleURLEvent(_:withReply:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )

		//	So they can interact everywhere with us without focus
		appStatusItem.image = NSImage.init(named: "statusIcon")
		appStatusItem.menu = appMenu

        //  Initialize our h:m:s transformer
         ValueTransformer.setValueTransformer(toHMS, forName: NSValueTransformerName(rawValue: "hmsTransformer"))
	}

	var mdQuery = NSMetadataQuery()
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        magicURLMenu.state = UserDefaults.standard.bool(forKey: UserSetting.disabledMagicURLs.userDefaultsKey) ? NSOffState : NSOnState
        
        fullScreenFloatMenu.state = UserDefaults.standard.bool(forKey: UserSetting.disabledFullScreenFloat.userDefaultsKey) ? NSOffState : NSOnState
      
        if let alpha = UserDefaults.standard.object(forKey: UserSetting.opacityPercentage.userDefaultsKey) {
            let offset = (alpha as! Int)/10 - 1
            for (index, button) in percentageMenu.submenu!.items.enumerated() {
                (button ).state = (offset == index) ? NSOnState : NSOffState
            }
        }

		//	Our status item needs this
		window = NSApp.windows.first

        autoHideTitleMenu.state = UserDefaults.standard.bool(forKey: UserSetting.autoHideTitle.userDefaultsKey) ? NSOnState : NSOffState
		translucencyMenu.state = UserDefaults.standard.bool(forKey: UserSetting.translucency.userDefaultsKey) ? NSOnState : NSOffState
   }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func magicURLRedirectToggled(_ sender: NSMenuItem) {
        sender.state = (sender.state == NSOnState) ? NSOffState : NSOnState
        UserDefaults.standard.set((sender.state == NSOffState), forKey: UserSetting.disabledMagicURLs.userDefaultsKey)
    }

    //MARK: - handleURLEvent
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
}

