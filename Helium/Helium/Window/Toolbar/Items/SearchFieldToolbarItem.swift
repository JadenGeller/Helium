//
//  SearchFieldToolbarItem.swift
//  Helium
//
//  Created by Jaden Geller on 5/14/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

private class SearchField: NSSearchField {
    var isBecomingFirstResponderFromMouseDown = false
    override var refusesFirstResponder: Bool {
        get { isBecomingFirstResponderFromMouseDown }
        set { isBecomingFirstResponderFromMouseDown = newValue }
    }

    override func mouseDown(with event: NSEvent) {
        isBecomingFirstResponderFromMouseDown = true
        defer { isBecomingFirstResponderFromMouseDown = false }
        window?.makeFirstResponder(self)
    }
}

class SearchFieldToolbarItem: NSToolbarItem, NSSearchFieldDelegate {
    struct Model {
        var observeLocation: (@escaping (URL?) -> Void) -> NSKeyValueObservation
        var navigateWithSearchTerm: (String) -> Void
    }
    
    var tokens: [NSKeyValueObservation] = []
    let model: Model
    init(model: Model) {
        self.model = model
        super.init(itemIdentifier: .searchField)
        let searchField = SearchField()
        searchField.delegate = self
        searchField.target = self
        searchField.action = #selector(navigate)
        searchField.placeholderString = "Search or enter website name"
        searchField.sendsWholeSearchString = true // Send action only on enter, not unfocus
        
        let searchFieldCell = searchField.cell as! NSSearchFieldCell
        searchFieldCell.cancelButtonCell = nil

        view = searchField
        
        // FIXME: Memory leaks?
        tokens.append(model.observeLocation { url in
            searchField.stringValue = url?.absoluteString ?? ""
        })
    }
    
    @objc func navigate(_ searchField: NSSearchField) {
        searchField.selectText(nil)
//        model.navigateWithSearchTerm(searchField.stringValue)
    }
    
    @objc func click(_ searchField: NSSearchField) {
        print("CLICK")
    }
}

extension NSToolbarItem.Identifier {
    static var searchField = NSToolbarItem.Identifier("searchField")
}

