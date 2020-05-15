//
//  HistoryMenu.swift
//  Helium
//
//  Created by Jaden Geller on 5/14/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import WebKit

struct HistoryMenu: Menu {
    var body: Menu {
        List {
            Button("Back", action: #selector(WebView.goBack(_:)))
                .keyboardShortcut(.command, "[")
            Button("Forward", action: #selector(WebView.goForward(_:)))
                .keyboardShortcut(.command, "]")
            //            Button("Home", action: ???)
            //                .keyboardShortcut([.command, .shift], "h")
        }
    }
}
