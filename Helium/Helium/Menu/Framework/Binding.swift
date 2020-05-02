//
//  Binding.swift
//  Helium
//
//  Created by Jaden Geller on 5/1/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

@propertyWrapper
struct Binding<Value> {
    let get: () -> Value
    let set: (Value) -> Void

    var wrappedValue: Value {
        get { get() }
        nonmutating set { set(newValue) }
    }

    var projectedValue: Self {
       self
    }

    static func constant(_ value: Value) -> Binding {
        .init(get: { value }, set: { _ in fatalError("constant cannot be set") })
    }
}
