//
//  List.swift
//  Helium
//
//  Created by Jaden Geller on 5/2/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

struct List: Menu {
    var body: Menu
    
    init(@MenuBuilder _ content: () -> Menu) {
        self.body = content()
    }
}
