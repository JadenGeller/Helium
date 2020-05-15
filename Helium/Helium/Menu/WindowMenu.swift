//
//  WindowsMenu.swift
//  Helium
//
//  Created by Jaden Geller on 5/12/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

struct WindowMenu: Menu {
    var body: Menu {
        List {
            Section {
                Button("Minimize", action: #selector(NSWindow.performMiniaturize(_:)))
                Button("Zoom", action: #selector(NSWindow.performZoom(_:)))
            }
            Section {
                Button("Bring All to Front", action: #selector(NSApplication.arrangeInFront(_:)))
            }
        }
    }
}
