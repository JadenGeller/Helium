//
//  UserSettings.swift
//  Helium
//
//  Created by Christian Hoffmann on 10/31/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

import Foundation

internal enum UserSetting {
    case disabledMagicURLs
    case disabledFullScreenFloat
    case opacityPercentage
    case homePageURL

    var userDefaultsKey: String {
        switch self {
        case .disabledMagicURLs: return "disabledMagicURLs"
        case .disabledFullScreenFloat: return "disabledFullScreenFloat"
        case .opacityPercentage: return "opacityPercentage"
        case .homePageURL: return "homePageURL"
        }
    }
}
