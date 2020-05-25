//
//  ZoomVideoButtonToolbarItem.swift
//  Helium
//
//  Created by Jaden Geller on 5/23/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

class ZoomVideoButtonToolbarItem: NSToolbarItem {
    struct Model {
        var zoomVideo: () -> Void
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
        control.action = #selector(zoomVideo(_:))
        control.setImage(NSImage(named: NSImage.exitFullScreenTemplateName), forSegment: 0)
        view = control
    }
    
    @objc func zoomVideo(_ control: NSSegmentedControl) {
        model.zoomVideo()
    }
}

extension NSToolbarItem.Identifier {
    static var zoomVideoToolbarButton = NSToolbarItem.Identifier("zoomVideoToolbarButton")
}
