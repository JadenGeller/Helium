//
//  FileMenu.swift
//  Helium
//
//  Created by Jaden Geller on 5/14/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

struct FileMenu: Menu {
    var body: Menu {
        List {
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
