//
//  List.swift
//  Helium
//
//  Created by Jaden Geller on 5/2/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

struct List: PrimitiveMenu {
    var menus: [Menu]

    init(@MenuBuilder _ list: () -> List) {
        self = list()
    }
    
    fileprivate init(menus: [Menu]) {
        self.menus = menus
    }
    
    func makeNSMenuItems() -> [NSMenuItem] {
        menus.flatMap({ $0.makeNSMenuItems() })
    }
}

extension MenuBuilder {
    static func buildBlock(_ menus: Menu...) -> List {
        List(menus: menus)
    }
}
