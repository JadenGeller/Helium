//
//  NSRepresentable.swift
//  Helium
//
//  Created by Jaden Geller on 5/2/20.
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
