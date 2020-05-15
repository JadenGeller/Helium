//
//  BrowserToolbar.swift
//  Helium
//
//  Created by Jaden Geller on 4/25/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

class HideToolbarButtonToolbarItem: NSToolbarItem {
    struct Model {
        var hideToolbar: () -> Void
    }
    
    let model: Model
    init(model: Model) {
        self.model = model
        super.init(itemIdentifier: .directionalNavigationButtons)
        let control = NSSegmentedControl() // FIXME: Why is this segmented?
        control.trackingMode = .momentary
        control.isContinuous = false
        control.segmentCount = 1
        control.target = self
        control.action = #selector(hideToolbar(_:))
        control.setImage(NSImage(named: NSImage.exitFullScreenTemplateName), forSegment: 0)
        view = control
    }
    
    @objc func hideToolbar(_ control: NSSegmentedControl) {
        model.hideToolbar()
    }
}

extension NSToolbarItem.Identifier {
    static var hideToolbarButton = NSToolbarItem.Identifier("hideToolbarButton")
}
