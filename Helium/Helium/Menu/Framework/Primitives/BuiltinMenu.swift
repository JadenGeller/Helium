//
//  BuiltinMenu.swift
//  Helium
//
//  Created by Jaden Geller on 5/12/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

struct BuiltinMenu: PrimitiveMenu {
    var keyPath: ReferenceWritableKeyPath<NSApplication, NSMenu?>
    
    var nsMenu: NSMenu {
        if let nsMenu = NSApplication.shared[keyPath: keyPath] {
            return nsMenu
        } else {
            let nsMenu = NSMenu()
            NSApplication.shared[keyPath: keyPath] = nsMenu
            return nsMenu
        }
    }
    
    func makeNSMenuItems() -> [NSMenuItem] {
        nsMenu.items
    }
    
    func update(to menu: Menu) {
        nsMenu.items = menu.makeNSMenuItems()
    }
}

extension BuiltinMenu {
    static let main = BuiltinMenu(keyPath: \.mainMenu)
    static let services = BuiltinMenu(keyPath: \.servicesMenu)
    static let windows = BuiltinMenu(keyPath: \.windowsMenu)
}
