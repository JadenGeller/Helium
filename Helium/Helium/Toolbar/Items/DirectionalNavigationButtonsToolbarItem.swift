//
//  DirectionalNavigationButtonsToolbarItem.swift
//  Helium
//
//  Created by Jaden Geller on 5/14/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa
import OpenCombine
import OpenCombineFoundation
import WebKit

class DirectionalNavigationButtonsToolbarItem: NSToolbarItem {
    struct Model {
        var observeCanGoBack: (@escaping (Bool) -> Void) -> NSKeyValueObservation
        var observeCanGoForward: (@escaping (Bool) -> Void) -> NSKeyValueObservation
        var backForwardList: WKBackForwardList
        var navigateToBackForwardListItem: (WKBackForwardListItem) -> Void
    }
    
    enum Segment: Int {
        case back = 0
        case forward = 1
    }
    
    let model: Model
    var tokens: [NSKeyValueObservation] = []
    init(model: Model) {
        self.model = model
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
        
        // FIXME: Memory leaks?
        tokens.append(model.observeCanGoBack { canGoBack in
            control.setEnabled(canGoBack, forSegment: Segment.back.rawValue)
            control.setMenu(HostingMenu(rootMenu: {
                ForEach(self.model.backForwardList.backList.reversed()) { backItem in
                    // FIXME: Add icons to buttons
                    Button(backItem.title ?? backItem.url.absoluteString, action: {
                        self.model.navigateToBackForwardListItem(backItem)
                    })
                }
            }), forSegment: Segment.back.rawValue)
        })
        tokens.append(model.observeCanGoForward { canGoForward in
            control.setEnabled(canGoForward, forSegment: Segment.forward.rawValue)
            control.setMenu(HostingMenu(rootMenu: {
                ForEach(self.model.backForwardList.forwardList) { forwardItem in
                    Button(forwardItem.title ?? forwardItem.url.absoluteString, action: {
                        self.model.navigateToBackForwardListItem(forwardItem)
                    })
                }
            }), forSegment: Segment.forward.rawValue)
        })
    }
    
    var control: NSSegmentedControl {
        view as! NSSegmentedControl
    }

    @objc func navigate(_ control: NSSegmentedControl) {
        switch Segment(rawValue: control.selectedSegment)! {
        case .back:
            model.navigateToBackForwardListItem(model.backForwardList.backItem!)
        case .forward:
            model.navigateToBackForwardListItem(model.backForwardList.forwardItem!)
        }
    }
}

extension NSToolbarItem.Identifier {
    static var directionalNavigationButtons = NSToolbarItem.Identifier("directionalNavigationButtons")
}
