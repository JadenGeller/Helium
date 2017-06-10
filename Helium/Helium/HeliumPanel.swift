//
//  Panel.swift
//  Helium
//
//  Created by shdwprince on 8/10/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import Foundation
import Cocoa

// Sugar
extension NSPoint {
    static func - (left: NSPoint, right: NSPoint) -> NSPoint {
        return NSPoint(x: left.x - right.x, y: left.y - right.y)
    }
}

class HeliumPanel: NSPanel {
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
    
    // nil when not dragging
    var previousMouseLocation: NSPoint?
    
    override func sendEvent(_ event: NSEvent) {
        switch event.type {
        case .flagsChanged:
            // If modifier key was released, dragging should be disabled
            if !event.modifierFlags.contains(.command) {
                previousMouseLocation = nil
            }
        case .leftMouseDown:
            if event.modifierFlags.contains(.command) {
                previousMouseLocation = event.locationInWindow
            }
        case .leftMouseUp:
            previousMouseLocation = nil
        case .leftMouseDragged:
            if let previousMouseLocation = previousMouseLocation {
                let delta = previousMouseLocation - event.locationInWindow
                let newOrigin = self.frame.origin - delta
                self.setFrameOrigin(newOrigin)
                return // don't pass event to super
            }
        default:
            break
        }
        
        super.sendEvent(event)
    }
    
}
