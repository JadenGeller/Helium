//
//  MenuBar.swift
//  Helium
//
//  Created by Jaden Geller on 5/12/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa
import WebKit

// FIXME: Refresh state when inputs change!
struct MenuBar: Menu {
    let shouldMagicallyRedirect = Binding(get: { !UserSetting.disabledMagicURLs }, set: { UserSetting.disabledMagicURLs = !$0 })
    let shouldFloatAboveAllSpaces = Binding(get: { !UserSetting.disabledFullScreenFloat }, set: { UserSetting.disabledFullScreenFloat = !$0 })
    let isToolbarVisible = Binding(get: { UserSetting.toolbarVisibility == .visible }, set: { UserSetting.toolbarVisibility = $0 ? .visible : .hidden })
    let isTranslucencyEnabled = Binding(get: { UserSetting.translucencyEnabled }, set: { UserSetting.translucencyEnabled = $0 })
    let translucencyMode = Binding(get: { UserSetting.translucencyMode }, set: { UserSetting.translucencyMode = $0 })
    let opacityPercentage = Binding(get: { UserSetting.opacityPercentage }, set: { UserSetting.opacityPercentage = $0 })
    
    var body: Menu {
        List {
            MenuButton("\(Bundle.main.name)") {
                Section {
                    Button("About \(Bundle.main.name)", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)))
                    MenuButton("Preferences...") {
                        Button("Set Homepage", action: #selector(HeliumWindowController.setHomePage(_:)))
                        Toggle("Magic URL Redirects", isOn: shouldMagicallyRedirect)
                        Toggle("Float Above All Spaces", isOn: shouldFloatAboveAllSpaces)
                    }
                }
                Section {
                    MenuButton("Services") {
                        BuiltinMenu.services
                    }
                }
                Section {
                    Button("Hide \(Bundle.main.name)", action: #selector(NSApplication.hide(_:)))
                        .keyboardShortcut(.command, "h")
                    Button("Hide \(Bundle.main.name)", action: #selector(NSApplication.hide(_:)))
                        .keyboardShortcut(.command, "h")
                    Button("Hide Others", action: #selector(NSApplication.hideOtherApplications(_:)))
                        .keyboardShortcut([.command, .option], "h")
                    Button("Show All", action: #selector(NSApplication.unhideAllApplications(_:)))
                }
                Section {
                    Button("Quit \(Bundle.main.name)", action: #selector(NSApplication.terminate(_:)))
                        .keyboardShortcut(.command, "q")
                }
            }
            MenuButton("File") {
                Section {
                    Button("New Window", action: #selector(AppDelegate.showNewWindow(_:)))
                        .keyboardShortcut(.command, "n")
                    Button("Open File", action: #selector(HeliumWindowController.openFilePress(_:)))
                        .keyboardShortcut(.command, "f")
                    Button("Open Location", action: #selector(HeliumWindowController.openLocationPress(_:)))
                        .keyboardShortcut(.command, "l")
                }
                Section {
                    Button("Close Window", action: #selector(NSWindow.performClose(_:)))
                        .keyboardShortcut(.command, "w")
                    Button("Close All Windows", action: #selector(NSApplication.closeAllWindows(_:)))
                        .keyboardShortcut([.command, .option], "w")
                }
            }
            MenuButton("Edit") {
                Section {
                    // FIXME: Undo/redo doesn't work!
                    Button("Undo", action: #selector(UndoManager.undo))
                        .keyboardShortcut(.command, "z")
                    Button("Redo", action: #selector(UndoManager.redo))
                        .keyboardShortcut([.command, .shift], "z")
                }
                Section {
                    Button("Cut", action: #selector(NSText.cut(_:)))
                        .keyboardShortcut(.command, "x")
                    Button("Copy", action: #selector(NSText.copy(_:)))
                        .keyboardShortcut(.command, "c")
                    Button("Paste", action: #selector(NSText.paste(_:)))
                        .keyboardShortcut(.command, "v")
                    Button("Delete", action: #selector(NSText.delete(_:)))
                    Button("Select All", action: #selector(NSText.selectAll(_:)))
                        .keyboardShortcut(.command, "a")
                }
            }
            MenuButton("View") {
                Section {
                    // FIXME: Switch is cleaner?
                    Toggle("Toolbar", isOn: isToolbarVisible)
                        .toggleStyle(TitleToggleStyle.showHide)
                        // FIXME: This keyboard shortcut is ignored!
                        .keyboardShortcut(.command, "b")
                    MenuButton("Translucency") {
                        Toggle("Enabled", isOn: isTranslucencyEnabled)
                            .keyboardShortcut(.command, "t")
                        MenuButton("Opacity") {
                            Picker(selection: opacityPercentage, stride(from: 0, to: 100, by: 10).map({ percentage in
                                (percentage, "\(percentage)%")
                            }))
                            // FIXME: Support keyboardShortcut for Picker
                            // .keyEquivalent(String(digit == 10 ? 0 : digit), with: .command)
                        }
                        Picker(selection: translucencyMode, [
                            .always: "Always",
                            .mouseOver: "Mouse Over",
                            .mouseOutside: "Mouse Outside"
                        ])
                    }
                }
                Section {
                    Button("Stop", action: #selector(WKWebView.stopLoading(_:)))
                        .keyboardShortcut(.command, ".")
                    Button("Reload Page", action: #selector(WKWebView.reload(_:)))
                        .keyboardShortcut(.command, "r")
                }
                Section {
                    Button("Actual Size", action: #selector(WebViewController.resetZoomLevel(_:)))
                        .keyboardShortcut(.command, "0")
                    Button("Zoom In", action: #selector(WebViewController.zoomIn(_:)))
                        .keyboardShortcut(.command, "+")
                    Button("Zoom Out", action: #selector(WebViewController.zoomOut(_:)))
                        .keyboardShortcut(.command, "-")
                }
            }
            MenuButton("History") {
                Button("Back", action: #selector(WebView.goBack(_:)))
                    .keyboardShortcut(.command, "[")
                Button("Forward", action: #selector(WebView.goForward(_:)))
                    .keyboardShortcut(.command, "]")
                //            Button("Home", action: ???)
                //                .keyboardShortcut([.command, .shift], "h")
            }
            MenuButton("Window") {
                BuiltinMenu.windows
            }
            MenuButton("Help") {
                Button("\(Bundle.main.name) Help", action: #selector(NSApplication.showHelp(_:)))
            }
        }
    }
}

extension NSApplication {
    // FIXME: Should not respond to selector if all windows are closed
    @objc func closeAllWindows(_ sender: Any?) {
        for window in windows {
            window.performClose(sender)
        }
    }
}
