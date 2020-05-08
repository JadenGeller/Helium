//
//  ForEach.swift
//  Helium
//
//  Created by Jaden Geller on 5/1/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

struct ForEach<Data>: PrimitiveMenu where Data: Sequence {
    var menus: [Menu]

    init(_ data: Data, @MenuBuilder content: (Data.Element) -> Menu) {
        self.menus = data.map(content)
    }
    
    func makeNSMenuItems() -> [NSMenuItem] {
        menus.flatMap({ $0.makeNSMenuItems() })
    }
}
