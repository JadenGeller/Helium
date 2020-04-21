//
//  Publisher.swift
//  Helium
//
//  Created by Jaden Geller on 4/20/20.
//  Copyright © 2020 Jaden Geller. All rights reserved.
//

import Foundation

protocol Publisher {
    associatedtype Output
    associatedtype Subscription
    func subscribe(_ receiveValue: @escaping (Output) -> Void) -> Subscription
}

struct MapViewPublisher<Upstream: Publisher, Output>: Publisher {
    let upstream: Upstream
    let transform: (Upstream.Output) -> Output

    typealias Subscription = Upstream.Subscription
    func subscribe(_ receiveValue: @escaping (Output) -> Void) -> Subscription {
        upstream.subscribe { upstreamOutput in
            receiveValue(self.transform(upstreamOutput))
        }
    }
}

extension Publisher {
    func map<Mapped>(_ transform: @escaping (Output) -> Mapped) -> MapViewPublisher<Self, Mapped> {
        MapViewPublisher(upstream: self, transform: transform)
    }
}
