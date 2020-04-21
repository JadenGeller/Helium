//
//  MainMenu.swift
//  Helium
//
//  Created by Jaden Geller on 4/18/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa
import WebKit

func mainMenu() -> NSMenu {
    NSMenu(items: [
        NSMenuItem(title: "\(Bundle.main.name)")
            .submenu([
                NSMenuItem(title: "About \(Bundle.main.name)")
                    .action(#selector(NSApplication.orderFrontStandardAboutPanel(_:))),
                NSMenuItem(title: "Preferences...")
                    .submenu([
                        NSMenuItem(title: "Set Homepage")
                            .action(#selector(HeliumPanelController.setHomePage(_:))),
                        NSMenuItem(title: "Magic URL Redirects")
                            .action(#selector(AppDelegate.magicURLRedirectToggled(_:)))
                            .state(UserSetting.$disabledMagicURLs.map({ $0 ? .off : .on })),
                        NSMenuItem(title: "Float Above All Spaces")
                            .action(#selector(HeliumPanelController.floatOverFullScreenAppsToggled(_:)))
                            .state(UserSetting.$disabledFullScreenFloat.map({ $0 ? .off : .on }))
                    ]),
                
                NSMenuItem.separator(),
                
                NSMenuItem(title: "Services")
                    .submenu(NSApplication.shared.servicesMenu!),
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
            NSMenuItem(title: "Open File...")
                .action(#selector(HeliumPanelController.openFilePress(_:)))
                .keyEquivalent("f", with: .command),
            NSMenuItem(title: "Open Location...")
                .action(#selector(HeliumPanelController.openLocationPress(_:)))
                .keyEquivalent("l", with: .command)
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
                        .action(#selector(HeliumPanelController.translucencyPress(_:)))
                        .keyEquivalent("t", with: .command)
                        .state(UserSetting.$translucencyEnabled.map({ $0 ? .on : .off })),
                    NSMenuItem(title: "Opacity")
                        .submenu((1...10).map({ (digit: Int) -> NSMenuItem in
                            NSMenuItem(title: "\(digit * 10)%")
                                .action(#selector(HeliumPanelController.percentagePress(_:)))
                                .keyEquivalent(String(digit == 10 ? 0 : digit), with: .command)
                                .state(UserSetting.$opacityPercentage.map({ value in
                                    value / 10 == digit ? .on : .off
                                }))
                        })),
                    
                    NSMenuItem.separator(),
                    
                    NSMenuItem(title: "Always")
                        .action(#selector(HeliumPanelController.alwaysPreferencePress(_:)))
                        .state(UserSetting.$translucencyMode.map({ $0 == .always ? .on : .off })),
                    NSMenuItem(title: "Mouse Over")
                        .action(#selector(HeliumPanelController.overPreferencePress(_:)))
                        .state(UserSetting.$translucencyMode.map({ $0 == .mouseOver ? .on : .off })),
                    NSMenuItem(title: "Mouse Outside")
                        .action(#selector(HeliumPanelController.outsidePreferencePress(_:)))
                        .state(UserSetting.$translucencyMode.map({ $0 == .mouseOutside ? .on : .off })),
                ]),
            
            NSMenuItem.separator(),
                
//            NSMenuItem(title: "Stop")
//                .action(???)
//                .keyEquivalent(".", with: .command)
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
        
        NSMenuItem(title: "Help")
            .submenu([
                NSMenuItem(title: "\(Bundle.main.name) Help")
                    .action(#selector(NSApplication.showHelp(_:)))
            ])
    ])
}
