//
//  UserSettings.swift
//  Helium
//
//  Created by Christian Hoffmann on 10/31/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

import Foundation

internal struct UserSettings {
    internal class Setting<T> {
        private let key: String
        private let defaultValue: T
        
        init(_ userDefaultsKey: String, defaultValue: T) {
            self.key = userDefaultsKey
            self.defaultValue = defaultValue
        }
        
        var keyPath: String {
            get {
                return self.key
            }
        }
        var `default`: T {
            get {
                return self.defaultValue
            }
        }
        var value: T {
            get {
                return self.get()
            }
            set (value) {
                self.set(value)
                //  Inform all interested parties
                NotificationCenter.default.post(name: Notification.Name(rawValue: self.keyPath), object: nil)
            }
        }
        
        private func get() -> T {
            if let value = UserDefaults.standard.object(forKey: self.key) as? T {
                return value
            } else {
                // Sets default value if failed
                set(self.defaultValue)
                return self.defaultValue
            }
        }
        
        private func set(_ value: T) {
            UserDefaults.standard.set(value as Any, forKey: self.key)
        }
    }
    
    static let autoHideTitle = Setting<Bool>("rawAutoHideTitle", defaultValue: false)
    static let windowTitle = Setting<String>("windowTitle", defaultValue: "Helium")
    static let windowStyle = Setting<Int>("windowStyle", defaultValue: 0)
    
    static let disabledMagicURLs = Setting<Bool>("disabledMagicURLs", defaultValue: false)
    
    static let disabledFullScreenFloat = Setting<Bool>("disabledFullScreenFloat", defaultValue: false)
    
    static let opacityPercentage = Setting<Int>("opacityPercentage", defaultValue: 60)

    // See values in HeliumPanelController.TranslucencyPreference
    static let translucencyPreference = Setting<Int>("rawTranslucencyPreference", defaultValue: 0)
    
    static let homePageURL = Setting<String>(
        "homePageURL",
        defaultValue: "https://cdn.rawgit.com/JadenGeller/Helium/master/helium_start.html"
    )
    static let homePageName = Setting<String>("homePageName", defaultValue: "helium_start")
    
    static let userAgent = Setting<String>(
        "userAgent",
        defaultValue: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_4) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.1 Safari/603.1.30"
        // swiftlint:disable:previous line_length
    )

    //  User Defaults keys
    static let Playlists = Setting<String>("playlists", defaultValue:"playlists")
    static let Histories = Setting<String>("histories", defaultValue:"histories")
}
