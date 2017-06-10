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
	var autoHideTitle : Bool = NSUserDefaults.standardUserDefaults().boolForKey(UserSetting.AutoHideTitle.userDefaultsKey)

	@IBOutlet weak var translucencyMenu: NSMenuItem!
	@IBOutlet var window: NSWindow!
	@IBOutlet weak var appMenu: NSMenu!
	@IBOutlet weak var appItem: NSMenuItem!
	let appStatusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
	
	internal func menuClicked(sender: AnyObject) {
		if let menuItem = sender as? NSMenuItem {
			Swift.print("Menu '\(menuItem.title)' clicked")
		}
	}
	@IBAction func floatOverFullScreenAppsPress(sender: NSMenuItem) {
		let keyPath = UserSetting.DisabledFullScreenFloat.userDefaultsKey
		sender.state = (sender.state == NSOnState) ? NSOffState : NSOnState
		NSUserDefaults.standardUserDefaults().setBool((sender.state == NSOffState), forKey: keyPath)
		NSNotificationCenter.defaultCenter().postNotificationName(keyPath, object: nil)
	}
	
	@IBAction func homePagePress(sender: AnyObject) {
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
			if !(text.lowercaseString.hasPrefix("http://") || text.lowercaseString.hasPrefix("https://")) {
				text = "http://" + text
			}
			
			// Save to defaults if valid. Else, use Helium default page
			if text.isValidURL() {
				NSUserDefaults.standardUserDefaults().setObject(text, forKey: UserSetting.HomePageURL.userDefaultsKey)
			} else {
				NSUserDefaults.standardUserDefaults().setObject(Constants.defaultURL, forKey: UserSetting.HomePageURL.userDefaultsKey)
			}
		}
	}
	@IBAction func autoHideTitle(sender: NSMenuItem) {
		sender.state = (sender.state == NSOnState) ? NSOffState : NSOnState
		NSUserDefaults.standardUserDefaults().setBool((sender.state == NSOnState), forKey: UserSetting.AutoHideTitle.userDefaultsKey)
	}

	override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
		switch menuItem.title {
		case "Preferences":
			break
		case "Auto-hide Title Bar":
			menuItem.state = NSUserDefaults.standardUserDefaults().boolForKey(UserSetting.AutoHideTitle.userDefaultsKey) ? NSOnState : NSOffState
			break
		case "Enabled": //Transluceny Menu
			menuItem.state = NSUserDefaults.standardUserDefaults().boolForKey(UserSetting.Translucency.userDefaultsKey) ? NSOnState : NSOffState
			break
		case "Float Above All Spaces":
			menuItem.state = NSUserDefaults.standardUserDefaults().boolForKey(UserSetting.DisabledFullScreenFloat.userDefaultsKey) ? NSOffState : NSOnState
			break;
		case "Home Page":
			break
		case "Magic URL Redirects":
			menuItem.state = NSUserDefaults.standardUserDefaults().boolForKey(UserSetting.DisabledMagicURLs.userDefaultsKey) ? NSOffState : NSOnState
			break
		case "Quit":
			break

		default:
			break
		}
		Swift.print("item \(menuItem) is \(menuItem.state)")

/*
			// Switch to a submenu if we can
			if let wc : HeliumPanelController = NSApp.keyWindow?.windowController as? HeliumPanelController {
				if let webViewController : WebViewController = wc.webViewController {
					if let webView: MyWebView = webViewController.view.subviews[0] as? MyWebView {
						let subMenu: NSMenu = NSMenu()
						//	Publish a custom menu
						webView.publishApplicationMenu(subMenu)
						Swift.print(subMenu)
						menuItem.submenu = subMenu
					}
				}
			}
*/
		return true;
	}
	@IBAction func appPress(sender: NSMenuItem) {
		Swift.print("Menu '\(sender.title)' clicked")
	}
/*		if let wc : HeliumPanelController = NSApp.keyWindow?.windowController as? HeliumPanelController {
			if let webViewController : WebViewController = wc.webViewController {
				if let webView: MyWebView = webViewController.view.subviews[0] as? MyWebView {
					let event: NSEvent = NSApp.currentEvent!
					NSMenu.popUpContextMenu(sender.submenu!, withEvent: event, forView: webView)
				}
			}
		}
	}
*/
	@IBAction func quitPress(sender: AnyObject) {
		NSApplication.sharedApplication().terminate(self)
	}

	override class func initialize() {
		let toHMS = hmsTransformer()
		NSValueTransformer.setValueTransformer(toHMS, forName: "hmsTransformer")
	}

	func applicationWillFinishLaunching(notification: NSNotification) {
        NSAppleEventManager.sharedAppleEventManager().setEventHandler(
            self,
            andSelector: #selector(AppDelegate.handleURLEvent(_:withReply:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )

		//	So they can interact everywhere with us without focus
		appStatusItem.image = NSImage.init(named: "statusIcon")
		appStatusItem.menu = appMenu
	}

	var mdQuery = NSMetadataQuery()
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        magicURLMenu.state = NSUserDefaults.standardUserDefaults().boolForKey(UserSetting.DisabledMagicURLs.userDefaultsKey) ? NSOffState : NSOnState
        
        fullScreenFloatMenu.state = NSUserDefaults.standardUserDefaults().boolForKey(UserSetting.DisabledFullScreenFloat.userDefaultsKey) ? NSOffState : NSOnState
      
        if let alpha = NSUserDefaults.standardUserDefaults().objectForKey(UserSetting.OpacityPercentage.userDefaultsKey) {
            let offset = (alpha as! Int)/10 - 1
            for (index, button) in percentageMenu.submenu!.itemArray.enumerate() {
                (button ).state = (offset == index) ? NSOnState : NSOffState
            }
        }

		//	Our status item needs this
		window = NSApp.windows.first

        autoHideTitleMenu.state = NSUserDefaults.standardUserDefaults().boolForKey(UserSetting.AutoHideTitle.userDefaultsKey) ? NSOnState : NSOffState
		translucencyMenu.state = NSUserDefaults.standardUserDefaults().boolForKey(UserSetting.Translucency.userDefaultsKey) ? NSOnState : NSOffState
   }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func magicURLRedirectToggled(sender: NSMenuItem) {
        sender.state = (sender.state == NSOnState) ? NSOffState : NSOnState
        NSUserDefaults.standardUserDefaults().setBool((sender.state == NSOffState), forKey: UserSetting.DisabledMagicURLs.userDefaultsKey)
    }

    //MARK: - handleURLEvent
    // Called when the App opened via URL.
    @objc func handleURLEvent(event: NSAppleEventDescriptor, withReply reply: NSAppleEventDescriptor) {
        
        guard let keyDirectObject = event.paramDescriptorForKeyword(AEKeyword(keyDirectObject)), let urlString = keyDirectObject.stringValue,
            let url : String = urlString.substringFromIndex(urlString.startIndex.advancedBy(9)),
            let urlObject = NSURL(string:url) else {
            
                return print("No valid URL to handle")
                
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("HeliumLoadURL", object: urlObject)
    }
}

