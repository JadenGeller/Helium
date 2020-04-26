//
//  HeliumWindow.swift
//  Helium
//
//  Created by Jaden Geller on 4/26/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

class HeliumWindow: NSPanel {
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        level = .mainMenu
        hidesOnDeactivate = false
        hasShadow = true
        center()
        isMovableByWindowBackground = true
        isExcludedFromWindowsMenu = false
        styleMask.insert(.nonactivatingPanel)
        collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
        ]
    }
 
    override var canBecomeMain: Bool {
        true
    }
    
    override var isReleasedWhenClosed: Bool {
        get {
            true
        }
        @available(*, unavailable)
        set {
            // Ignore AppKit's attempts to set this property
        }
    }
    
    override func makeKey() {
        super.makeKey()
        NSApplication.shared.addWindowsItem(self, title: title, filename: false)
    }
    
    override func cancelOperation(_ sender: Any?) {
        // Override default behavior to prevent panel from closing
    }
}
