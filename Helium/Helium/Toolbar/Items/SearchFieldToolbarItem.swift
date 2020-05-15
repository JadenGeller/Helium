//
//  SearchFieldToolbarItem.swift
//  Helium
//
//  Created by Jaden Geller on 5/14/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

class SearchFieldToolbarItem: NSToolbarItem, NSSearchFieldDelegate {
    let handleNavigation: (ToolbarAction.NavigationDestination) -> Void
    init(_ handleNavigation: @escaping (ToolbarAction.NavigationDestination) -> Void) {
        self.handleNavigation = handleNavigation
        super.init(itemIdentifier: .searchField)
        let searchField = NSSearchField()
        searchField.delegate = self
        searchField.target = self
        searchField.action = #selector(navigate)
        searchField.placeholderString = "Search or enter website name"
        searchField.sendsWholeSearchString = true // Send action only on enter, not unfocus
        view = searchField
    }
    
    @objc func navigate(_ searchField: NSSearchField) {
        handleNavigation(.toLocation(searchField.stringValue))
    }
}

extension NSToolbarItem.Identifier {
    static var searchField = NSToolbarItem.Identifier("searchField")
}

