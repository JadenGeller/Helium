//
//  UserSettings.swift
//  Helium
//
//  Created by Christian Hoffmann on 10/31/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

import Foundation

@propertyWrapper
struct UserDefault<Persisted> {
    let key: String
    let defaultValue: Persisted
    var storage: UserDefaults = .standard

    init(wrappedValue: Persisted, key: String) {
        self.key = key
        self.defaultValue = wrappedValue
    }
    
    var wrappedValue: Persisted {
        get {
            UserDefaults.standard.value(forKey: key) as! Persisted? ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

internal enum UserSetting {
    @UserDefault(key: "disabledMagicURLs")
    static var disabledMagicURLs = false

    @UserDefault(key: "disabledFullScreenFloat")
    static var disabledFullScreenFloat = false

    @UserDefault(key: "opacityPercentage")
    static var opacityPercentage = 100
    
    @UserDefault(key: "homePageURL")
    static var homePageURL: String? = nil
}
