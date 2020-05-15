//
//  HeliumMenu.swift
//  Helium
//
//  Created by Jaden Geller on 5/14/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

struct ApplicationMenu: Menu {
    let shouldMagicallyRedirect = Binding(get: { !UserSetting.disabledMagicURLs }, set: { UserSetting.disabledMagicURLs = !$0 })
    let shouldFloatAboveAllSpaces = Binding(get: { !UserSetting.disabledFullScreenFloat }, set: { UserSetting.disabledFullScreenFloat = !$0 })

    var body: Menu {
        List {
            Section {
                Button("About \(Bundle.main.name)", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)))
                MenuButton("Preferences...") {
                    Button("Set Homepage", action: #selector(HeliumWindowController.setHomePage(_:)))
                    Toggle("Magic URL Redirects", isOn: shouldMagicallyRedirect)
                    Toggle("Float Above All Spaces", isOn: shouldFloatAboveAllSpaces)
                }
            }
            Section {
                ServicesMenuButton()
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
    }
}
