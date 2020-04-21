//
//  UserDefaultHelpers.swift
//  Helium
//
//  Created by Jaden Geller on 4/21/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Foundation

@propertyWrapper
struct UserDefault<Persisted: RawRepresentable> {
    let key: String
    let defaultValue: Persisted
    var storage: UserDefaults = .standard

    init(wrappedValue: Persisted, key: String) {
        self.key = key
        self.defaultValue = wrappedValue
    }
    
    var wrappedValue: Persisted {
        get {
            guard let rawValue = UserDefaults.standard.value(forKey: key) as! Persisted.RawValue? else {
                return defaultValue
            }
            return Persisted(rawValue: rawValue)!
        }
        nonmutating set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
        }
    }
    
    var projectedValue: UserDefaultPublisher<Persisted> {
        UserDefaultPublisher(userDefault: self)
    }
}

struct UserDefaultPublisher<Persisted: RawRepresentable>: Publisher {
    let userDefault: UserDefault<Persisted>

    typealias Output = Persisted
    
    class Subscription: NSObject {
        let userDefault: UserDefault<Persisted>
        let receiveValue: (Persisted) -> Void

        init(_ userDefault: UserDefault<Persisted>, _ receiveValue: @escaping (Persisted) -> Void) {
            self.userDefault = userDefault
            self.receiveValue = receiveValue
            super.init()
            userDefault.storage.addObserver(self, forKeyPath: userDefault.key, options: [], context: nil)
            self.receiveValue(userDefault.wrappedValue)
        }
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            precondition(keyPath == userDefault.key)
            precondition(object as! UserDefaults == userDefault.storage)
            self.receiveValue(userDefault.wrappedValue)
        }
        
        deinit {
            userDefault.storage.removeObserver(self, forKeyPath: userDefault.key)
        }
    }
    func subscribe(_ receiveValue: @escaping (Output) -> Void) -> Subscription {
        return Subscription(userDefault, receiveValue)
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
