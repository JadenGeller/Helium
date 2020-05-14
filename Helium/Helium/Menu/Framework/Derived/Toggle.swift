//
//  Toggle.swift
//  Helium
//
//  Created by Jaden Geller on 5/1/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

struct Toggle: Menu {
    struct Configuration {
        var label: String
        @Binding var isOn: Bool
    }
    var configuration: Configuration
    var style: ToggleStyle = CheckmarkToggleStyle()
    
    init(_ label: String, isOn: Binding<Bool>) {
        self.configuration = Configuration(label: label, isOn: isOn)
    }
    
    var body: Menu {
        style.makeBody(configuration: configuration)
    }
    
    enum Style {
        case checkmark
        case title((String, Bool) -> String)
    }
    
    func toggleStyle(_ style: ToggleStyle) -> Toggle {
        var copy = self
        copy.style = style
        return copy
    }
    
    // FIXME: How can we avoid adding this complexity onto toggle? Can we use environment to send this down?
    var keyEquivalent: String = ""
    var keyEquivalentModifierMask: NSEvent.ModifierFlags = [.command]
    
    func keyboardShortcut(_ modifiers: NSEvent.ModifierFlags, _ key: Character) -> Toggle {
        var copy = self
        copy.keyEquivalent = String(key)
        copy.keyEquivalentModifierMask = modifiers
        return copy
    }

}

protocol ToggleStyle {
    typealias Configuration = Toggle.Configuration
    func makeBody(configuration: Configuration) -> Menu
}

struct CheckmarkToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> Menu {
        Button(configuration.label, action: { configuration.isOn.toggle() })
            .state(configuration.isOn ? .on : .off)
    }
}

struct TitleToggleStyle: ToggleStyle {
    var transformOn: (String) -> String
    var transformOff: (String) -> String
    init(on transformOn: @escaping (String) -> String, off transformOff: @escaping (String) -> String) {
        self.transformOn = transformOn
        self.transformOff = transformOff
    }
    
    func makeBody(configuration: Configuration) -> Menu {
        Button((configuration.isOn ? transformOn : transformOff)(configuration.label), action: { configuration.isOn.toggle() })
    }
}

extension TitleToggleStyle {
    static var showHide = TitleToggleStyle(on: { "Hide \($0)" }, off: { "Show \($0)" })
}
