//
//  Menu.swift
//  Helium
//
//  Created by Jaden Geller on 5/1/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

protocol Menu: NSMenuRepresentable {
    var body: Menu { get }
    
    typealias Item = NSMenuItemRepresentable
    var items: [Item] { get }
}

extension Menu {
    var items: [Item] {
        body.items
    }
    
    func makeNSMenu() -> NSMenu {
        NSMenu(items: items.map({ $0.makeNSMenuItem() }))
    }
}

protocol NSMenuItemRepresentable {
    func makeNSMenuItem() -> NSMenuItem
}

extension Menu where Self: NSMenuItemRepresentable {
    var items: [Item] {
        [self]
    }
    
    var body: Menu {
        fatalError("\(Self.self) is a primitive Menu")
    }
}

typealias PrimitiveMenu = Menu & NSMenuItemRepresentable

struct Flatten: Menu {
    var menus: [Menu]
        
    var items: [Item] {
        menus.flatMap({ $0.items })
    }
    
    var body: Menu {
        fatalError("Flatten is a primitive Menu")
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
