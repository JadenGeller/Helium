//
//  Menu.swift
//  Helium
//
//  Created by Jaden Geller on 5/1/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

protocol NSMenuItemRepresentable {
    func makeNSMenuItem() -> NSMenuItem
}

protocol NSMenuItemListRepresentable {
    typealias Item = NSMenuItemRepresentable
    var items: [Item] { get }
}

protocol Menu {
    var body: Menu { get }
}

extension Menu {
    fileprivate var items: [NSMenuItemRepresentable] {
        guard let items = (self as? NSMenuItemListRepresentable)?.items else {
            return body.items
        }
        return items
    }
    
    func makeNSMenu() -> NSMenu {
        NSMenu(items: items.map({ $0.makeNSMenuItem() }))
    }
}

typealias PrimitiveMenu = Menu & NSMenuItemListRepresentable

extension Menu where Self: PrimitiveMenu {
    var body: Menu {
        fatalError("\(Self.self) is a primitive Menu")
    }
}
extension NSMenuItemListRepresentable where Self: NSMenuItemRepresentable {
    var items: [Item] {
        [self]
    }
}

struct Flatten: PrimitiveMenu {
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
