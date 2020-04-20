//
//  main.swift
//  Helium
//
//  Created by Jaden Geller on 4/18/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

autoreleasepool {
    withExtendedLifetime(AppDelegate()) { delegate in
        NSApplication.shared.servicesMenu = NSMenu()
        NSApplication.shared.mainMenu = mainMenu()
        NSApplication.shared.delegate = delegate
        NSApplication.shared.run()
    }
}
