//
//  UserDefaultHelpers.swift
//  Helium
//
//  Created by Jaden Geller on 4/21/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Foundation
import OpenCombine

extension UserDefaults {
    func value<Persisted: RawRepresentable>(of type: Persisted.Type, forKey key: String, withDefault defaultValue: Persisted) -> Persisted {
        guard let rawValue = UserDefaults.standard.value(forKey: key) as! Persisted.RawValue? else {
            return defaultValue
        }
        return Persisted(rawValue: rawValue)!
    }
}

@propertyWrapper
struct UserDefault<Persisted: RawRepresentable> {
    let key: String
    let defaultValue: Persisted
    var storage: UserDefaults = .standard
    let subject: CurrentValueSubject<Persisted, Never>

    init(wrappedValue: Persisted, key: String) {
        self.key = key
        self.defaultValue = wrappedValue
        self.subject = .init(UserDefaults.standard.value(of: Persisted.self, forKey: key, withDefault: defaultValue))
    }
    
    var wrappedValue: Persisted {
        get {
            UserDefaults.standard.value(of: Persisted.self, forKey: key, withDefault: defaultValue)
        }
        nonmutating set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
            subject.send(newValue)
        }
    }
    
    var projectedValue: CurrentValueSubject<Persisted, Never> {
       subject
    }
}

extension Bool: RawRepresentable {
    public init?(rawValue: Self) {
        self = rawValue
    }
    public var rawValue: Self {
        self
    }
}
extension Int: RawRepresentable {
    public init?(rawValue: Self) {
        self = rawValue
    }
    public var rawValue: Self {
        self
    }
}
extension String: RawRepresentable {
    public init?(rawValue: Self) {
        self = rawValue
    }
    public var rawValue: Self {
        self
    }
}
extension Optional: RawRepresentable where Wrapped: RawRepresentable {
    public init?(rawValue: Self) {
        self = rawValue
    }
    public var rawValue: Self {
        self
    }
}
