//
//  HeliumToolbar.swift
//  Helium
//
//  Created by Jaden Geller on 4/25/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

enum ToolbarAction {
    enum NavigationDestination {
        case toLocation(String)
        case forward
        case back
    }
    case navigate(NavigationDestination)
}

class HeliumToolbar: NSToolbar, NSToolbarDelegate {
    let handleNavigation: (ToolbarAction.NavigationDestination) -> Void

    init(_ handleAction: @escaping (ToolbarAction) -> Void) {
        self.handleNavigation = { destination in handleAction(.navigate(destination)) }
        super.init(identifier: "HeliumToolbar")
        self.delegate = self
        sizeMode = .small
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .space,
            .flexibleSpace,
            .heliumSearchField,
            .heliumDirectionalNavigationButtons
        ]
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .heliumDirectionalNavigationButtons,
            .flexibleSpace,
            .heliumSearchField,
            .flexibleSpace
        ]
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .heliumSearchField:
            return HeliumSearchFieldToolbarItem(handleNavigation)
        case .heliumDirectionalNavigationButtons:
            return HeliumDirectionalNavigationButtonsToolbarItem(handleNavigation)
        default:
            fatalError("Unexpected itemIdentifier")
        }
    }
}

extension NSToolbarItem.Identifier {
    static var heliumSearchField = NSToolbarItem.Identifier("heliumSearchField")
    static var heliumDirectionalNavigationButtons = NSToolbarItem.Identifier("heliumDirectionalNavigationButtons")
}

class HeliumSearchFieldToolbarItem: NSToolbarItem, NSSearchFieldDelegate {
    let handleNavigation: (ToolbarAction.NavigationDestination) -> Void
    init(_ handleNavigation: @escaping (ToolbarAction.NavigationDestination) -> Void) {
        self.handleNavigation = handleNavigation
        super.init(itemIdentifier: .heliumSearchField)
        let searchField = NSSearchField()
        searchField.delegate = self
        searchField.target = self
        searchField.action = #selector(HeliumSearchFieldToolbarItem.navigate)
        searchField.placeholderString = "Search or enter website name"
        searchField.sendsWholeSearchString = true // Send action only on enter, not unfocus
        view = searchField
    }
    
    @objc func navigate(_ searchField: NSSearchField) {
        handleNavigation(.toLocation(searchField.stringValue))
    }
}

class HeliumDirectionalNavigationButtonsToolbarItem: NSToolbarItem {
    let handleNavigation: (ToolbarAction.NavigationDestination) -> Void
    init(_ handleNavigation: @escaping (ToolbarAction.NavigationDestination) -> Void) {
        self.handleNavigation = handleNavigation
        super.init(itemIdentifier: .heliumDirectionalNavigationButtons)
        let control = NSSegmentedControl()
        control.segmentStyle = .separated
        if #available(macOS 10.13, *) {
            // FIXME: This is super whacky in old versions of macOS
            control.trackingMode = .momentary
        }
        control.segmentCount = 2
        view = control
    }
}
