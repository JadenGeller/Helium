//
//  MenuHelpers.swift
//  Helium
//
//  Created by Jaden Geller on 4/20/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa
import OpenCombine

extension Bundle {
    var name: String {
        infoDictionary![kCFBundleNameKey as String] as! String
    }
}

extension NSMenu {
    convenience init(title: String? = nil, items: [NSMenuItem]) {
        if let title = title {
            self.init(title: title)
        } else {
            self.init()
        }
        items.forEach(addItem(_:))
    }
}

extension NSMenuItem {
    convenience init(title: String) {
        self.init(title: title, action: nil, keyEquivalent: "")
    }
}
