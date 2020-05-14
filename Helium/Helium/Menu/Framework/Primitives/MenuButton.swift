//
//  MenuButton.swift
//  Helium
//
//  Created by Jaden Geller on 5/1/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

struct MenuButton: PrimitiveMenu {
    var title: String
    var submenu: Menu
    
    init(_ title: String, @MenuBuilder submenu: () -> Menu) {
        self.title = title
        self.submenu = submenu()
    }

    func makeNSMenuItems() -> [NSMenuItem] {
        let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        if let builtinMenu = submenu as? BuiltinMenu {
            let menu = builtinMenu.nsMenu
            // FIXME: This is janky!!
            if let supermenu = menu.supermenu {
                supermenu.removeItem(at: supermenu.indexOfItem(withSubmenu: menu))
            }
            menuItem.submenu = menu
        } else {
            let menu = NSMenu(title: title)
            menu.items = submenu.makeNSMenuItems()
            menuItem.submenu = menu
        }
        menuItem.submenu!.title = title
        return [menuItem]
    }
}
