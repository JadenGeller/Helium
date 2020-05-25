//
//  BrowserToolbar.swift
//  Helium
//
//  Created by Jaden Geller on 5/14/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

class BrowserToolbar: NSToolbar, NSToolbarDelegate {
    struct Model {
        var directionalNagivationButtonsModel: DirectionalNavigationButtonsToolbarItem.Model
        var searchFieldModel: SearchFieldToolbarItem.Model
        var zoomVideoToolbarButtonModel: ZoomVideoButtonToolbarItem.Model
        var hideToolbarButtonModel: HideToolbarButtonToolbarItem.Model
    }
    
    let model: Model
    init(model: Model) {
        self.model = model
        super.init(identifier: "BrowserToolbar")
        self.delegate = self
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .space,
            .flexibleSpace,
            .searchField,
            .directionalNavigationButtons,
            .zoomVideoToolbarButton,
            .hideToolbarButton
        ]
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .directionalNavigationButtons,
            .flexibleSpace,
            .searchField,
            .flexibleSpace,
            .zoomVideoToolbarButton,
            .hideToolbarButton
        ]
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .directionalNavigationButtons:
            return DirectionalNavigationButtonsToolbarItem(model: model.directionalNagivationButtonsModel)
        case .searchField:
            return SearchFieldToolbarItem(model: model.searchFieldModel)
        case .hideToolbarButton:
            return HideToolbarButtonToolbarItem(model: model.hideToolbarButtonModel)
        case .zoomVideoToolbarButton:
            return ZoomVideoButtonToolbarItem(model: model.zoomVideoToolbarButtonModel)
        default:
            fatalError("Unexpected itemIdentifier")
        }
    }
}
