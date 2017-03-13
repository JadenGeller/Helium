//
//  Panel.swift
//  Helium
//
//  Created by shdwprince on 8/10/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import Foundation
import Cocoa

protocol HeliumPanelDelegate {
    var paneShouldInterruptScroll : Bool { get set }
    func paneShouldFireEvent(_ event: HeliumPanel.ControlEventType) -> Bool
}

class HeliumPanel : NSPanel {
    enum ScrollingLock {
        case vertical
        case horizontal
        case none
    }

    enum ControlEventType {
        case playpause
        case up
        case down
        case left
        case right
    }

    var heliumDelegate : HeliumPanelDelegate?

    var previousMouseLocation : NSPoint? = nil
    var beingDragged = false

    var scrollingLock : ScrollingLock = ScrollingLock.none
    var scrollingTime : CFAbsoluteTime = 0
    let scrollingTimeout = 0.3

    override var canBecomeKey: Bool {
        return true
    }

    override var canBecomeMain: Bool {
        return true
    }

    override func sendEvent(_ event: NSEvent) {
        if event.type == .scrollWheel {
            if self.heliumDelegate?.paneShouldInterruptScroll ?? true {
                self.scrollingEvent(event)
            } else {
                super.sendEvent(event)
            }
        }

        let top = self.frame.size.height - event.locationInWindow.y
        if self.titleVisibility == .visible && top > 21 {
            switch event.type {
            case .leftMouseDown:
                self.previousMouseLocation = event.locationInWindow
                super.sendEvent(event)
            case .leftMouseDragged:
                self.beingDragged = true
                self.moveForEvent(event)
            case .leftMouseUp:
                if !self.beingDragged {
                    super.sendEvent(event)
                }
                
                self.beingDragged = false
            case .keyDown:
                var isSendEvent = false
                var type: ControlEventType? = nil
                let keyCode = event.keyCode
                if keyCode == 123 { //Left
                } else if keyCode == 124 { //Right
                } else if keyCode == 125 {//Down
                    type = .down
                    isSendEvent = true
                } else if keyCode == 126 { //Up
                    type = .up
                    isSendEvent = true
                }
                if isSendEvent {
                    self.fireControlEvent(of: type!)
                } else{
                    super.sendEvent(event)
                }
            default:
                super.sendEvent(event)
            }
        } else {
            super.sendEvent(event)
        }
    }

    func moveForEvent(_ event: NSEvent) {
        if let previousLocation = self.previousMouseLocation {
            let delta = NSPoint(x: previousLocation.x - event.locationInWindow.x,
                                y: previousLocation.y - event.locationInWindow.y)
            let newLocation = NSPoint(x: self.frame.origin.x - delta.x,
                                      y: self.frame.origin.y - delta.y)
            
            self.setFrameOrigin(newLocation)
        }
    }

    func scrollingEvent(_ event: NSEvent) {
        if self.scrollingLock == .none && event.phase == .changed {
            self.scrollingLock =
                abs(event.scrollingDeltaY) * 1.5 > abs(event.scrollingDeltaX)
                ? .vertical
                : .horizontal
        }

        if event.phase == .ended {
            self.scrollingLock = .none
            self.scrollingTime = 0
        }

        if event.phase == .changed {
            if (CFAbsoluteTimeGetCurrent() - self.scrollingTime > self.scrollingTimeout) {
                self.scrollingTime = CFAbsoluteTimeGetCurrent()

                var type : ControlEventType?
                switch self.scrollingLock {
                case .vertical:
                    type = event.scrollingDeltaY < 0 ? .up : .down
                case .horizontal:
                    type = event.scrollingDeltaX < 0 ? .left : .right
                case .none:
                    return
                }

                self.fireControlEvent(of: type!)
            }
        }

    }

    func fireControlEvent(of type: ControlEventType) {
        func makeKeyEvent(type: NSEventType, characters: String) -> NSEvent! {
            return NSEvent.keyEvent(with: type,
                                    location: NSPoint(x: 0, y: 0),
                                    modifierFlags: [],
                                    timestamp: Date.timeIntervalSinceReferenceDate,
                                    windowNumber: NSApp.keyWindow?.windowNumber ?? 0,
                                    context: NSApp.keyWindow?.graphicsContext,
                                    characters: characters,
                                    charactersIgnoringModifiers: characters,
                                    isARepeat: false,
                                    keyCode: 0)
        }

        let characters = [.up: "", .down: "", .left: "", .right: "", .playpause: " ", ][type]!
        if self.heliumDelegate?.paneShouldFireEvent(type) ?? true {
            self.keyDown(with: makeKeyEvent(type: .keyDown, characters: characters))
            self.keyUp(with: makeKeyEvent(type: .keyUp, characters: characters))
        }
    }
}

class EverenabledMenu : NSMenu {
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return true
    }
}
