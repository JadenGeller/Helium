//
//  MenuButton.swift
//  Helium
//
//  Created by Jaden Geller on 5/1/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

struct MenuButton: NSMenuRepresentable, PrimitiveMenu {
    var title: String
    var submenu: Menu
    
    func makeNSMenu() -> NSMenu {
        NSMenu(title: title, items: submenu.items.map({ $0.makeNSMenuItem() }))
    }

    func makeNSMenuItem() -> NSMenuItem {
        let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        menuItem.submenu = makeNSMenu()
        return menuItem
    }
    
    init(_ title: String, @MenuBuilder submenu: () -> Menu) {
        self.title = title
        self.submenu = submenu()
    }
}
