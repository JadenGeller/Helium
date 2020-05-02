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
        let app = NSApplication.shared
        (app.servicesMenu, app.windowsMenu, app.mainMenu) = makeMenus()
        app.delegate = delegate
        app.run()
    }
}
