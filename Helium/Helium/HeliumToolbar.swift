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
    case hideToolbar
}

class HeliumToolbar: NSToolbar, NSToolbarDelegate {
    let handleNavigation: (ToolbarAction.NavigationDestination) -> Void
    let hideToolbar: () -> Void

    init(_ handleAction: @escaping (ToolbarAction) -> Void) {
        self.handleNavigation = { destination in handleAction(.navigate(destination)) }
        self.hideToolbar = { handleAction(.hideToolbar) }
        super.init(identifier: "HeliumToolbar")
        self.delegate = self
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .space,
            .flexibleSpace,
            .heliumSearchField,
            .heliumDirectionalNavigationButtons,
            .heliumHideToolbarButton
        ]
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .heliumDirectionalNavigationButtons,
            .flexibleSpace,
            .heliumSearchField,
            .flexibleSpace,
            .heliumHideToolbarButton
        ]
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .heliumSearchField:
            return HeliumSearchFieldToolbarItem(handleNavigation)
        case .heliumDirectionalNavigationButtons:
            return HeliumDirectionalNavigationButtonsToolbarItem(handleNavigation)
        case .heliumHideToolbarButton:
            return HeliumHideToolbarButtonToolbarItem(hideToolbar)
        default:
            fatalError("Unexpected itemIdentifier")
        }
    }
}

extension NSToolbarItem.Identifier {
    static var heliumSearchField = NSToolbarItem.Identifier("heliumSearchField")
    static var heliumDirectionalNavigationButtons = NSToolbarItem.Identifier("heliumDirectionalNavigationButtons")
    static var heliumHideToolbarButton = NSToolbarItem.Identifier("heliumHideToolbarButton")
}

class HeliumSearchFieldToolbarItem: NSToolbarItem, NSSearchFieldDelegate {
    let handleNavigation: (ToolbarAction.NavigationDestination) -> Void
    init(_ handleNavigation: @escaping (ToolbarAction.NavigationDestination) -> Void) {
        self.handleNavigation = handleNavigation
        super.init(itemIdentifier: .heliumSearchField)
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

class HeliumDirectionalNavigationButtonsToolbarItem: NSToolbarItem {
    enum Segment: Int {
        case back = 0
        case forward = 1
    }
    
    let handleNavigation: (ToolbarAction.NavigationDestination) -> Void
    init(_ handleNavigation: @escaping (ToolbarAction.NavigationDestination) -> Void) {
        self.handleNavigation = handleNavigation
        super.init(itemIdentifier: .heliumDirectionalNavigationButtons)
        let control = NSSegmentedControl()
        control.segmentStyle = .separated
        control.trackingMode = .momentary
        control.isContinuous = false
        control.segmentCount = 2
        control.target = self
        control.action = #selector(navigate)
        control.setImage(NSImage(named: NSImage.goBackTemplateName), forSegment: 0)
        control.setImage(NSImage(named: NSImage.goForwardTemplateName), forSegment: 1)
        view = control
    }
    
    @objc func navigate(_ control: NSSegmentedControl) {
        switch Segment(rawValue: control.selectedSegment)! {
        case .back:
            handleNavigation(.back)
        case .forward:
            handleNavigation(.forward)
        }
    }
}

class HeliumHideToolbarButtonToolbarItem: NSToolbarItem {
    let hideToolbar: () -> Void
    init(_ handleNavigation: @escaping () -> Void) {
        self.hideToolbar = handleNavigation
        super.init(itemIdentifier: .heliumDirectionalNavigationButtons)
        let control = NSSegmentedControl()
        control.trackingMode = .momentary
        control.isContinuous = false
        control.segmentCount = 1
        control.target = self
        control.action = #selector(hideToolbar(_:))
        view = control
    }
    
    @objc func hideToolbar(_ control: NSSegmentedControl) {
        self.hideToolbar()
    }
}
