//
//  NSHostingController.swift
//  Helium
//
//  Created by Jaden Geller on 5/2/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa
import OpenCombine

class HostingMenu: NSMenu {
    let rootMenu: () -> Menu
    
    init(rootMenu: @escaping () -> Menu) {
        self.rootMenu = rootMenu
        super.init(title: "")
        update()
    }
    
    override func update() {
        items = rootMenu().makeNSMenuItems()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
