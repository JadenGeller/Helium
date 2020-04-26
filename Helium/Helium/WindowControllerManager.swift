//
//  WindowManager.swift
//  Helium
//
//  Created by Jaden Geller on 4/22/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Cocoa

class WindowControllerManager {
    private(set) var managedControllers: [NSWindowController] = []
    
    func newWindow() -> HeliumWindowController {
        let controller = HeliumWindowController()
        managedControllers.append(controller)
        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: controller.window, queue: .main) { [unowned self] _ in
            self.managedControllers.removeAll(where: { window in window == controller.window })
        }
        return controller
    }
}
