//
//  ForEach.swift
//  Helium
//
//  Created by Jaden Geller on 5/1/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

struct ForEach<Data>: Menu where Data: Sequence {
    let body: Menu
    
    init(_ data: Data, @MenuBuilder content: @escaping (Data.Element) -> Menu) {
        self.body = Flatten(menus: data.map(content))
    }
}
