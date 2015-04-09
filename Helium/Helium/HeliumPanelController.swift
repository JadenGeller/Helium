//
//  HeliumPanelController.swift
//  Helium
//
//  Created by Jaden Geller on 4/9/15.
//  Copyright (c) 2015 Jaden Geller. All rights reserved.
//

import AppKit

class HeliumPanelController : NSWindowController {

    var panel: NSPanel! {
        get {
            return (self.window as! NSPanel)
        }
    }
    
    override func windowDidLoad() {
        self.panel.floatingPanel = true
    }
    
}