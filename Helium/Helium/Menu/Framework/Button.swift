//
//  Button.swift
//  Helium
//
//  Created by Jaden Geller on 5/1/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

struct Button: PrimitiveMenu, NSMenuItemRepresentable {
    enum Action {
        case selector(Selector)
        case closure(() -> Void)
    }
    class Coordinator {
        let action: () -> Void
        
        init(action: @escaping () -> Void) {
            self.action = action
        }

        @objc func performAction(_ sender: NSMenuItem) {
            action()
        }
    }
    
    var title: String
    var action: Action
    var keyEquivalent: String = ""
    var keyEquivalentModifierMask: NSEvent.ModifierFlags = [.command]
    var state: NSControl.StateValue = .off
    
    init(_ title: String, action: Selector) {
        self.title = title
        self.action = .selector(action)
    }

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = .closure(action)
    }
    
    func keyboardShortcut(_ modifiers: NSEvent.ModifierFlags, _ key: Character) -> Button {
        var copy = self
        copy.keyEquivalent = String(key)
        copy.keyEquivalentModifierMask = modifiers
        return copy
    }
    
    func state(_ state: NSControl.StateValue) -> Button {
        var copy = self
        copy.state = state
        return copy
    }
    
    func makeNSMenuItem() -> NSMenuItem {
        let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: keyEquivalent)
        menuItem.keyEquivalentModifierMask = keyEquivalentModifierMask
        switch action {
        case .selector(let selector):
            menuItem.action = selector
        case .closure(let closure):
            let coordinator = Coordinator(action: closure)
            menuItem.representedObject = coordinator
            menuItem.target = coordinator
            menuItem.action = #selector(Coordinator.performAction(_:))
        }
        menuItem.state = state
        return menuItem
    }
}
