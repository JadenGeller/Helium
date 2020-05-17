//
//  SearchFieldToolbarItem.swift
//  Helium
//
//  Created by Jaden Geller on 5/14/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

class SearchFieldToolbarItem: NSToolbarItem, NSSearchFieldDelegate {
    struct Model {
        var navigateWithSearchTerm: (String) -> Void
    }
    
    let model: Model
    init(model: Model) {
        self.model = model
        super.init(itemIdentifier: .searchField)
        let searchField = NSSearchField()
        searchField.delegate = self
        searchField.target = self
        searchField.action = #selector(navigate)
        searchField.placeholderString = "Search or enter website name"
        searchField.sendsWholeSearchString = true // Send action only on enter, not unfocus
        
        let searchFieldCell = searchField.cell as! NSSearchFieldCell
        searchFieldCell.cancelButtonCell = nil
        
        view = searchField
    }
    
    @objc func navigate(_ searchField: NSSearchField) {
        model.navigateWithSearchTerm(searchField.stringValue)
    }
}

extension NSToolbarItem.Identifier {
    static var searchField = NSToolbarItem.Identifier("searchField")
}

