//
//  HelpMenu.swift
//  Helium
//
//  Created by Jaden Geller on 5/14/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

struct HelpMenu: Menu {
    var body: Menu {
        Button("\(Bundle.main.name) Help", action: #selector(NSApplication.showHelp(_:)))
    }
}
