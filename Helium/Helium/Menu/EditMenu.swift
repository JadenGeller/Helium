//
//  EditMenu.swift
//  Helium
//
//  Created by Jaden Geller on 5/14/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

struct EditMenu: Menu {
    var body: Menu {
        List {
            Section {
                // FIXME: Undo/redo doesn't work!
                Button("Undo", action: #selector(UndoManager.undo))
                    .keyboardShortcut(.command, "z")
                Button("Redo", action: #selector(UndoManager.redo))
                    .keyboardShortcut([.command, .shift], "z")
            }
            Section {
                Button("Cut", action: #selector(NSText.cut(_:)))
                    .keyboardShortcut(.command, "x")
                Button("Copy", action: #selector(NSText.copy(_:)))
                    .keyboardShortcut(.command, "c")
                Button("Paste", action: #selector(NSText.paste(_:)))
                    .keyboardShortcut(.command, "v")
                Button("Delete", action: #selector(NSText.delete(_:)))
                Button("Select All", action: #selector(NSText.selectAll(_:)))
                    .keyboardShortcut(.command, "a")
            }
        }
    }
}
