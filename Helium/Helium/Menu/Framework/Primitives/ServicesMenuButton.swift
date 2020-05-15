//
//  BuiltinMenu.swift
//  Helium
//
//  Created by Jaden Geller on 5/12/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

struct ServicesMenuButton: PrimitiveMenu {
    func makeNSMenuItems() -> [NSMenuItem] {
        let menuItem = NSMenuItem(title: "Services", action: nil, keyEquivalent: "")
        menuItem.submenu = NSMenu()
        NSApplication.shared.servicesMenu = menuItem.submenu
        return [menuItem]
    }
}
