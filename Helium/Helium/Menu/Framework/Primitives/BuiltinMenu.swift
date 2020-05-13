//
//  BuiltinMenu.swift
//  Helium
//
//  Created by Jaden Geller on 5/12/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

enum BuiltinMenu: PrimitiveMenu {
    case main
    case services
    case windows
    
    var keyPath: ReferenceWritableKeyPath<NSApplication, NSMenu?> {
        switch self {
        case .main: return \.mainMenu
        case .services: return \.servicesMenu
        case .windows: return \.windowsMenu
        }
    }
    
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
