//
//  Button.swift
//  Helium
//
//  Created by Jaden Geller on 5/1/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

struct Button: PrimitiveMenu {
    enum Action {
        case selector(Selector)
        case closure(perform: () -> Void, disabled: Bool)
    }
    class Coordinator: NSObject, NSMenuItemValidation {
        let action: () -> Void
        let disabled: Bool
        
        init(action: @escaping () -> Void, disabled: Bool) {
            self.action = action
            self.disabled = disabled
        }

        @objc func performAction(_ sender: NSMenuItem) {
            action()
        }

        func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
            !disabled
        }
    }
    
    var title: String
    var action: Action
    var keyEquivalent: String = ""
    var keyEquivalentModifierMask: NSEvent.ModifierFlags = [.command]
    var state: NSControl.StateValue = .off
    var disabled: Bool? = nil
    
    init(_ title: String, action: Selector) {
        self.title = title
        self.action = .selector(action)
    }

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = .closure(perform: action, disabled: false)
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
    
    func disabled(_ disabled: Bool) -> Button {
        guard case .closure(let perform, _) = action else {
            preconditionFailure("disabled cannot be used with Selector")
        }
        var copy = self
        copy.action = .closure(perform: perform, disabled: disabled)
        return copy
    }
    
    func makeNSMenuItems() -> [NSMenuItem] {
        let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: keyEquivalent)
        menuItem.keyEquivalentModifierMask = keyEquivalentModifierMask
        switch action {
        case .selector(let selector):
            menuItem.action = selector
        case .closure(let closure, let disabled):
            let coordinator = Coordinator(action: closure, disabled: disabled)
            menuItem.representedObject = coordinator
            menuItem.target = coordinator
            menuItem.action = #selector(Coordinator.performAction(_:))
        }
        menuItem.state = state
        return [menuItem]
    }
}
