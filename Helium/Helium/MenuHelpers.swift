//
//  MenuHelpers.swift
//  Helium
//
//  Created by Jaden Geller on 4/20/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa
import OpenCombine

extension Bundle {
    var name: String {
        infoDictionary![kCFBundleNameKey as String] as! String
    }
}

extension NSMenu {
    convenience init(title: String? = nil, items: [NSMenuItem]) {
        if let title = title {
            self.init(title: title)
        } else {
            self.init()
        }
        items.forEach(addItem(_:))
    }
}

extension NSMenuItem {
    convenience init(title: String) {
        self.init(title: title, action: nil, keyEquivalent: "")
    }
    
    func action(_ selector: Selector) -> Self {
        action = selector
        return self
    }
    
    func keyEquivalent(_ charCode: String, with modifierMask: NSEvent.ModifierFlags) -> Self {
        keyEquivalent = charCode
        keyEquivalentModifierMask = modifierMask
        return self
    }
    
    func submenu(_ items: [NSMenuItem]) -> Self {
        submenu = NSMenu(title: title, items: items)
        return self
    }
    
    func submenu(_ menu: NSMenu) -> Self {
        submenu = menu
        return self
    }
}

extension NSMenuItem {
    class Context {
        var action: (() -> Void)?
        var cancellables: [AnyCancellable] = []
        
        @objc func performAction(_ sender: NSMenuItem) {
            action?()
        }
        
        deinit {
            for cancellable in cancellables {
                cancellable.cancel()
            }
        }
    }
    
    var context: Context {
        if let representedObject = representedObject {
            return representedObject as! Context
        } else {
            let context = Context()
            representedObject = context
            return context
        }
    }
    
    convenience init<P: Publisher>(title publisher: P) where P.Output == String, P.Failure == Never {
        self.init(title: "", action: nil, keyEquivalent: "")
        context.cancellables.append(publisher.sink { [weak self] newValue in
            self?.title = newValue
        })
    }
    
    func state<P: Publisher>(_ publisher: P) -> Self where P.Output == NSControl.StateValue, P.Failure == Never {
        context.cancellables.append(publisher.sink { [weak self] newValue in
            self?.state = newValue
        })
        return self
    }
    
    func action(_ block: @escaping (NSMenuItem) -> Void) -> Self {
        return action({ block(self) })
    }
    
    func action(_ block: @escaping () -> Void) -> Self {
        context.action = block
        target = context
        action = #selector(Context.performAction(_:))
        return self
    }
}
