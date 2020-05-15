//
//  MenuBar.swift
//  Helium
//
//  Created by Jaden Geller on 5/12/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

// FIXME: Refresh state when inputs change!
struct MenuBar: Menu {
    var body: Menu {
        List {
            MenuButton("\(Bundle.main.name)") {
                ApplicationMenu()
            }
            MenuButton("File") {
                FileMenu()
            }
            MenuButton("Edit") {
                EditMenu()
            }
            MenuButton("View") {
                ViewMenu()
            }
            MenuButton("History") {
                HistoryMenu()
            }
            MenuButton("Window") {
                WindowMenu()
            }
            MenuButton("Help") {
                HelpMenu()
            }
        }
    }
}

extension Bundle {
    var name: String {
        infoDictionary![kCFBundleNameKey as String] as! String
    }
}
