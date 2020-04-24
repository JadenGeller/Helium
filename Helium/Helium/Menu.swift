//
//  MainMenu.swift
//  Helium
//
//  Created by Jaden Geller on 4/18/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa
import WebKit

extension NSApplication {
    // FIXME: Should not respond to selector if all windows are closed
    @objc func closeAllWindows(_ sender: Any?) {
        for window in windows {
            window.performClose(sender)
        }
    }
}

func buildMenus() -> (servicesMenu: NSMenu, windowsMenu: NSMenu, mainMenu: NSMenu) {
    let servicesMenu = NSMenu()
    let windowsMenu = NSMenu(title: "Window", items: [
        NSMenuItem(title: "Minimize")
            .action(#selector(NSWindow.performMiniaturize(_:))),
        NSMenuItem(title: "Zoom")
            .action(#selector(NSWindow.performZoom(_:))),
        
        NSMenuItem.separator(),
        
        NSMenuItem(title: "Bring All to Front")
            .action(#selector(NSApplication.arrangeInFront(_:)))
    ])
    let mainMenu = NSMenu(items: [
        NSMenuItem(title: "\(Bundle.main.name)")
            .submenu([
                NSMenuItem(title: "About \(Bundle.main.name)")
                    .action(#selector(NSApplication.orderFrontStandardAboutPanel(_:))),
                NSMenuItem(title: "Preferences...")
                    .submenu([
                        NSMenuItem(title: "Set Homepage")
                            .action(#selector(HeliumPanelController.setHomePage(_:))),
                        NSMenuItem(title: "Magic URL Redirects")
                            .state(UserSetting.$disabledMagicURLs.map({ $0 ? .off : .on }))
                            .action({ UserSetting.disabledMagicURLs.toggle() }),
                        NSMenuItem(title: "Float Above All Spaces")
                            .state(UserSetting.$disabledFullScreenFloat.map({ $0 ? .off : .on }))
                            .action({ UserSetting.disabledFullScreenFloat.toggle() })
                    ]),

                NSMenuItem.separator(),

                NSMenuItem(title: "Services")
                    .submenu(servicesMenu),
                NSMenuItem(title: "Hide \(Bundle.main.name)")
                    .action(#selector(NSApplication.hide(_:)))
                    .keyEquivalent("h", with: .command),
                NSMenuItem(title: "Hide Others")
                    .action(#selector(NSApplication.hideOtherApplications(_:)))
                    .keyEquivalent("h", with: [.command, .option]),
                NSMenuItem(title: "Show All")
                    .action(#selector(NSApplication.unhideAllApplications(_:))),

                NSMenuItem.separator(),

                NSMenuItem(title: "Quit \(Bundle.main.name)")
                    .action(#selector(NSApplication.terminate(_:)))
                    .keyEquivalent("q", with: .command)
            ]),
        
        NSMenuItem(title: "File").submenu([
            NSMenuItem(title: "New Window")
                .action({ HeliumPanelController.makeController().showWindow($0) })
                .keyEquivalent("n", with: .command),
            NSMenuItem(title: "Open File...")
                .action(#selector(HeliumPanelController.openFilePress(_:)))
                .keyEquivalent("f", with: .command),
            NSMenuItem(title: "Open Location...")
                .action(#selector(HeliumPanelController.openLocationPress(_:)))
                .keyEquivalent("l", with: .command),
            
            NSMenuItem.separator(),

            NSMenuItem(title: "Close Window")
                .action(#selector(NSWindow.performClose(_:)))
                .keyEquivalent("w", with: .command),
            NSMenuItem(title: "Close All Windows")
                .action(#selector(NSApplication.closeAllWindows(_:)))
                .keyEquivalent("w", with: [.command, .option]),
        ]),

        NSMenuItem(title: "Edit").submenu([
             // FIXME: Undo/redo doesn't work!
             NSMenuItem(title: "Undo").action(#selector(UndoManager.undo))
                 .keyEquivalent("z", with: .command),
             NSMenuItem(title: "Redo")
                 .action(#selector(UndoManager.redo))
                 .keyEquivalent("z", with: [.command, .shift]),

             NSMenuItem.separator(),

             NSMenuItem(title: "Cut")
                 .action(#selector(NSText.cut(_:)))
                 .keyEquivalent("x", with: .command),
             NSMenuItem(title: "Copy")
                 .action(#selector(NSText.copy(_:)))
                 .keyEquivalent("c", with: .command),
             NSMenuItem(title: "Paste")
                 .action(#selector(NSText.paste(_:)))
                 .keyEquivalent("v", with: .command),
             NSMenuItem(title: "Delete")
                 .action(#selector(NSText.delete(_:))),
             NSMenuItem(title: "Select All")
                 .action(#selector(NSText.selectAll(_:)))
                 .keyEquivalent("a", with: .command),
        ]),
        
        NSMenuItem(title: "View").submenu([
            NSMenuItem(title: "Title Bar")
                .action(#selector(HeliumPanelController.hideTitle(_:)))
                .keyEquivalent("b", with: .command),
            
            NSMenuItem(title: "Translucency")
                .submenu([
                    NSMenuItem(title: "Enabled")
                        .state(UserSetting.$translucencyEnabled.map({ $0 ? .on : .off }))
                        .action({ UserSetting.translucencyEnabled.toggle() })
                        .keyEquivalent("t", with: .command),
                    NSMenuItem(title: "Opacity")
                        .submenu((1...10).map({ (digit: Int) -> NSMenuItem in
                            NSMenuItem(title: "\(digit * 10)%")
                                .state(UserSetting.$opacityPercentage.map({ $0 / 10 == digit ? .on : .off }))
                                .action({ UserSetting.opacityPercentage = digit * 10 })
                                .keyEquivalent(String(digit == 10 ? 0 : digit), with: .command)
                        })),
                    
                    NSMenuItem.separator(),
                    
                    NSMenuItem(title: "Always")
                        .state(UserSetting.$translucencyMode.map({ $0 == .always ? .on : .off }))
                        .action({ UserSetting.translucencyMode = .always }),
                    NSMenuItem(title: "Mouse Over")
                        .state(UserSetting.$translucencyMode.map({ $0 == .mouseOver ? .on : .off }))
                        .action({ UserSetting.translucencyMode = .mouseOver }),
                    NSMenuItem(title: "Mouse Outside")
                        .state(UserSetting.$translucencyMode.map({ $0 == .mouseOutside ? .on : .off }))
                        .action({ UserSetting.translucencyMode = .mouseOutside }),
                ]),
            
            NSMenuItem.separator(),
                
            NSMenuItem(title: "Stop")
                .action(#selector(WKWebView.stopLoading(_:)))
                .keyEquivalent(".", with: .command),
            NSMenuItem(title: "Reload Page")
                .action(#selector(WebView.reload(_:)))
                .keyEquivalent("r", with: .command),
            
            NSMenuItem.separator(),

            NSMenuItem(title: "Actual Size")
                .action(#selector(WebViewController.resetZoomLevel(_:)))
                .keyEquivalent("0", with: .command),
            NSMenuItem(title: "Zoom In")
                .action(#selector(WebViewController.zoomIn(_:)))
                .keyEquivalent("+", with: .command),
            NSMenuItem(title: "Zoom Out")
                .action(#selector(WebViewController.zoomOut(_:)))
                .keyEquivalent("-", with: .command)
        ]),
        
        NSMenuItem(title: "History")
            .submenu([
                NSMenuItem(title: "Back")
                    .action(#selector(WebView.goBack(_:)))
                    .keyEquivalent("[", with: .command),
                NSMenuItem(title: "Forward")
                    .action(#selector(WebView.goForward(_:)))
                    .keyEquivalent("]", with: .command)
//                NSMenuItem(title: "Home")
//                    .action(???)
//                    .keyEquivalent("h", with: [.command, .shift])
            ]),
        
        NSMenuItem(title: "Window")
            .submenu(windowsMenu),
        
        NSMenuItem(title: "Help")
            .submenu([
                NSMenuItem(title: "\(Bundle.main.name) Help")
                    .action(#selector(NSApplication.showHelp(_:)))
            ])
    ])
    return (servicesMenu, windowsMenu, mainMenu)
}
