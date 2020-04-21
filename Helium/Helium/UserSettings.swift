//
//  UserSettings.swift
//  Helium
//
//  Created by Christian Hoffmann on 10/31/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

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
