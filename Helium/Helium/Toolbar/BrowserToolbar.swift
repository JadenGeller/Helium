//
//  BrowserToolbar.swift
//  Helium
//
//  Created by Jaden Geller on 5/14/20.
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
    case hideToolbar
}

class BrowserToolbar: NSToolbar, NSToolbarDelegate {
    let handleNavigation: (ToolbarAction.NavigationDestination) -> Void
    let hideToolbar: () -> Void

    init(_ handleAction: @escaping (ToolbarAction) -> Void) {
        self.handleNavigation = { destination in handleAction(.navigate(destination)) }
        self.hideToolbar = { handleAction(.hideToolbar) }
        super.init(identifier: "BrowserToolbar")
        self.delegate = self
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .space,
            .flexibleSpace,
            .searchField,
            .directionalNavigationButtons,
            .hideToolbarButton
        ]
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .directionalNavigationButtons,
            .flexibleSpace,
            .searchField,
            .flexibleSpace,
            .hideToolbarButton
        ]
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .searchField:
            return SearchFieldToolbarItem(handleNavigation)
        case .directionalNavigationButtons:
            return DirectionalNavigationButtonsToolbarItem(handleNavigation)
        case .hideToolbarButton:
            return HideToolbarButtonToolbarItem(hideToolbar)
        default:
            fatalError("Unexpected itemIdentifier")
        }
    }
}
