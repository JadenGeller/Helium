//
//  MainMenu.swift
//  Helium
//
//  Created by Jaden Geller on 4/18/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa
import WebKit

extension Bundle {
    var name: String {
        infoDictionary![kCFBundleNameKey as String] as! String
    }
}

extension NSMenu {
    @discardableResult
    func addItem(withTitle string: String, action selector: Selector?, keyEquivalent charCode: String, with modifierMask: NSEvent.ModifierFlags) -> NSMenuItem {
        let item = self.addItem(withTitle: string, action: selector, keyEquivalent: charCode)
        item.keyEquivalentModifierMask = modifierMask
        return item
    }
}

func preferencesMenu() -> NSMenu {
    let menu = NSMenu(title: "Preferences...")

    menu.addItem(withTitle: "Set Homepage", action: #selector(HeliumPanelController.setHomePage(_:)), keyEquivalent: "")
    let magicUrlRedirects = menu.addItem(withTitle: "Magic URL Redirects", action: #selector(AppDelegate.magicURLRedirectToggled(_:)), keyEquivalent: "")
    let floatAboveAllSpaces = menu.addItem(withTitle: "Float Above All Spaces", action: #selector(HeliumPanelController.floatOverFullScreenAppsToggled(_:)), keyEquivalent: "")
    
    magicUrlRedirects.state = UserDefaults.standard.bool(forKey: UserSetting.DisabledMagicURLs.userDefaultsKey) ? .off : .on
    floatAboveAllSpaces.state = UserDefaults.standard.bool(forKey: UserSetting.DisabledFullScreenFloat.userDefaultsKey) ? .off : .on
    
    return menu
}

func applicationMenu() -> NSMenu {
    let menu = NSMenu()

    menu.addItem(withTitle: "About \(Bundle.main.name)", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
    menu.addItem(.separator())
    
    menu.addItem(withTitle: "Preferences...", action: nil, keyEquivalent: ",").submenu = preferencesMenu()
    menu.addItem(.separator())
    
    menu.addItem(withTitle: "Services", action: nil, keyEquivalent: "").submenu = NSApplication.shared.servicesMenu
    menu.addItem(.separator())
    
    menu.addItem(withTitle: "Hide \(Bundle.main.name)", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
    menu.addItem(withTitle: "Hide Others", action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h", with: [.command, .option])
    menu.addItem(withTitle: "Show All", action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: "")
    menu.addItem(.separator())
    
    menu.addItem(withTitle: "Quit Me", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    
    return menu
}

func fileMenu() -> NSMenu {
    let menu = NSMenu(title: "File")
    
    menu.addItem(withTitle: "Open File...", action: #selector(HeliumPanelController.openFilePress(_:)), keyEquivalent: "f")
    menu.addItem(withTitle: "Open Location...", action: #selector(HeliumPanelController.openLocationPress(_:)), keyEquivalent: "l")

    return menu
}

func editMenu() -> NSMenu {
    let menu = NSMenu(title: "Edit")
    
    // FIXME: Undo/redo doesn't work!
    menu.addItem(withTitle: "Undo", action: #selector(UndoManager.undo), keyEquivalent: "z")
    menu.addItem(withTitle: "Redo", action: #selector(UndoManager.redo), keyEquivalent: "z", with: [.command, .shift])
    menu.addItem(.separator())

    menu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
    menu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
    menu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
    menu.addItem(withTitle: "Delete", action: #selector(NSText.delete(_:)), keyEquivalent: "")
    menu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")

    return menu
}

func opacityMenu() -> NSMenu {
    let menu = NSMenu(title: "Opacity")

    menu.addItem(withTitle: "10%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "1")
    menu.addItem(withTitle: "20%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "2")
    menu.addItem(withTitle: "30%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "3")
    menu.addItem(withTitle: "40%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "4")
    menu.addItem(withTitle: "50%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "5")
    menu.addItem(withTitle: "60%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "6")
    menu.addItem(withTitle: "70%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "7")
    menu.addItem(withTitle: "80%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "8")
    menu.addItem(withTitle: "90%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "9")
    menu.addItem(withTitle: "100%", action: #selector(HeliumPanelController.percentagePress(_:)), keyEquivalent: "0")

    if let alpha = UserDefaults.standard.object(forKey: UserSetting.OpacityPercentage.userDefaultsKey) {
        let offset = (alpha as! Int)/10 - 1
        for (index, button) in menu.items.enumerated() {
            (button ).state = (offset == index) ? .on : .off
        }
    }
    
    return menu
}

func translucencyMenu() -> NSMenu {
    let menu = NSMenu(title: "Translucency")
    
    menu.addItem(withTitle: "Enabled", action: #selector(HeliumPanelController.translucencyPress(_:)), keyEquivalent: "t")
    menu.addItem(withTitle: "Opacity", action: nil, keyEquivalent: "").submenu = opacityMenu()
    menu.addItem(.separator())
    
    menu.addItem(withTitle: "Always", action: #selector(HeliumPanelController.alwaysPreferencePress(_:)), keyEquivalent: "")
    menu.addItem(withTitle: "Mouse Over", action: #selector(HeliumPanelController.overPreferencePress(_:)), keyEquivalent: "")
    menu.addItem(withTitle: "Mouse Outside", action: #selector(HeliumPanelController.outsidePreferencePress(_:)), keyEquivalent: "")
    
    return menu
}

func viewMenu() -> NSMenu {
    let menu = NSMenu(title: "View")

    menu.addItem(withTitle: "Title Bar", action: #selector(HeliumPanelController.hideTitle(_:)), keyEquivalent: "b")
    menu.addItem(withTitle: "Translucency", action: nil, keyEquivalent: "").submenu = translucencyMenu()
    menu.addItem(.separator())
        
    // FIXME: Add stop functionality
//    menu.addItem(withTitle: "Stop", action: nil, keyEquivalent: ".")
    menu.addItem(withTitle: "Reload Page", action: #selector(WebView.reload(_:)), keyEquivalent: "r")
    menu.addItem(.separator())

    menu.addItem(withTitle: "Actual Size", action: #selector(WebViewController.resetZoomLevel(_:)), keyEquivalent: "0")
    menu.addItem(withTitle: "Zoom In", action: #selector(WebViewController.zoomIn(_:)), keyEquivalent: "+")
    menu.addItem(withTitle: "Zoom Out", action: #selector(WebViewController.zoomOut(_:)), keyEquivalent: "-")

    return menu
}

func historyMenu() -> NSMenu {
    let menu = NSMenu(title: "History")
    
    menu.addItem(withTitle: "Back", action: #selector(WebView.goBack(_:)), keyEquivalent: "[")
    menu.addItem(withTitle: "Forward", action: #selector(WebView.goForward(_:)), keyEquivalent: "]")
//    menu.addItem(withTitle: "Home", action: nil, keyEquivalent: "h", with: [.command, .shift])

    return menu
}

func helpMenu() -> NSMenu {
    let menu = NSMenu(title: "Help")
    
    menu.addItem(withTitle: "\(Bundle.main.name) Help", action:#selector(NSApplication.showHelp(_:)), keyEquivalent: "")
    
    return menu
}

func mainMenu() -> NSMenu {
    let menu = NSMenu()
    
    menu.addItem(withTitle: "\(Bundle.main.name)", action: nil, keyEquivalent: "").submenu = applicationMenu()
    menu.addItem(withTitle: "File", action: nil, keyEquivalent: "").submenu = fileMenu()
    menu.addItem(withTitle: "Edit", action: nil, keyEquivalent: "").submenu = editMenu()
    menu.addItem(withTitle: "View", action: nil, keyEquivalent: "").submenu = viewMenu()
    menu.addItem(withTitle: "History", action: nil, keyEquivalent: "").submenu = historyMenu()
    menu.addItem(withTitle: "Help", action: nil, keyEquivalent: "").submenu = helpMenu()

    return menu
}
