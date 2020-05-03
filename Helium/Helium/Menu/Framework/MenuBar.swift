//
//  MenuBar.swift
//  Helium
//
//  Created by Jaden Geller on 5/1/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

struct MenuBar {
    var menus: [MenuButton]
    
    func makeNSMenu() -> NSMenu {
        NSMenu(items: menus.map({ menu in
            let submenu = menu.makeNSMenu()
            let menuItem = NSMenuItem(title: submenu.title)
            menuItem.submenu = submenu
            return menuItem
        }))
    }
}

@_functionBuilder
struct MenuBarBuilder {
    static func buildBlock(_ menus: MenuButton...) -> MenuBar {
        MenuBar(menus: menus)
    }
}

extension MenuBar {
    init(@MenuBarBuilder _ menuBar: () -> MenuBar) {
        self = menuBar()
    }
}
