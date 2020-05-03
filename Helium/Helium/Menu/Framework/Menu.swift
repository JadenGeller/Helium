//
//  Menu.swift
//  Helium
//
//  Created by Jaden Geller on 5/1/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

protocol Menu {
    var body: Menu { get }
}

protocol NSMenuItemsRepresentable {
    func makeNSMenuItems() -> [NSMenuItem]
}

typealias PrimitiveMenu = Menu & NSMenuItemsRepresentable

extension Menu {
    fileprivate func makeNSMenuItems() -> [NSMenuItem] {
        guard let items = (self as? PrimitiveMenu)?.makeNSMenuItems() else {
            return body.makeNSMenuItems()
        }
        return items
    }
    
    func makeNSMenu() -> NSMenu {
        NSMenu(items: makeNSMenuItems())
    }
}

extension Menu where Self: PrimitiveMenu {
    var body: Menu {
        fatalError("\(Self.self) is a primitive Menu")
    }
}

struct Flatten: PrimitiveMenu {
    var menus: [Menu]
  
    func makeNSMenuItems() -> [NSMenuItem] {
        menus.flatMap({ $0.makeNSMenuItems() })
    }

}

@_functionBuilder
struct MenuBuilder {
    static func buildBlock(_ menu: Menu) -> Menu {
        menu
    }
    
    static func buildBlock(_ menus: Menu...) -> Menu {
        Flatten(menus: menus)
    }
}

struct EmptyMenu: Menu {
    var body: Menu {
        Flatten(menus: [])
    }
}
