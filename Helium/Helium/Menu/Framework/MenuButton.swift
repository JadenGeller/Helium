//
//  MenuButton.swift
//  Helium
//
//  Created by Jaden Geller on 5/1/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

struct MenuButton: PrimitiveMenu, NSMenuItemRepresentable, NSMenuRepresentable {
    var title: String
    var submenu: Menu
    
    init(_ title: String, @MenuBuilder submenu: () -> Menu) {
        self.title = title
        self.submenu = submenu()
    }
    
    func makeNSMenu() -> NSMenu {
        let menu = submenu.makeNSMenu()
        menu.title = title
        return menu
    }

    func makeNSMenuItem() -> NSMenuItem {
        let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        menuItem.submenu = makeNSMenu()
        return menuItem
    }
}
