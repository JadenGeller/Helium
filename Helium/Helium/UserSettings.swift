//
//  UserSettings.swift
//  Helium
//
//  Created by Christian Hoffmann on 10/31/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

enum ToolbarVisibility: String {
    case visible
    case hidden
    
    mutating func toggle() {
        switch self {
        case .visible: self = .hidden
        case .hidden: self = .visible
        }
    }
}

internal enum UserSetting {
    @UserDefault(key: "disabledMagicURLs")
    static var disabledMagicURLs = false

    @UserDefault(key: "disabledFullScreenFloat")
    static var disabledFullScreenFloat = false

    @UserDefault(key: "opacityPercentage")
    static var opacityPercentage = 60
    
    @UserDefault(key: "homePageURL")
    static var homePageURL: String? = nil
    
    enum TranslucencyMode: String {
        case always
        case mouseOver
        case mouseOutside
    }
    @UserDefault(key: "translucencyMode")
    static var translucencyMode: TranslucencyMode = .always
    
    @UserDefault(key: "translucencyEnabled")
    static var translucencyEnabled: Bool = false
    
    @UserDefault(key: "toolbarVisibility")
    static var toolbarVisibility: ToolbarVisibility = .visible
}
