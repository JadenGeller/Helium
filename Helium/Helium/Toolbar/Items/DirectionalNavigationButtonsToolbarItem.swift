//
//  DirectionalNavigationButtonsToolbarItem.swift
//  Helium
//
//  Created by Jaden Geller on 5/14/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

class DirectionalNavigationButtonsToolbarItem: NSToolbarItem {
    enum Segment: Int {
        case back = 0
        case forward = 1
    }
    
    let handleNavigation: (ToolbarAction.NavigationDestination) -> Void
    init(_ handleNavigation: @escaping (ToolbarAction.NavigationDestination) -> Void) {
        self.handleNavigation = handleNavigation
        super.init(itemIdentifier: .directionalNavigationButtons)
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

extension NSToolbarItem.Identifier {
    static var directionalNavigationButtons = NSToolbarItem.Identifier("directionalNavigationButtons")
}
