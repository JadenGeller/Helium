//
//  StringHelpers.swift
//  Helium
//
//  Created by Samuel Beek on 16/03/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import Foundation

extension String {
    func replacePrefix(_ prefix: String, replacement: String) -> String {
        if hasPrefix(prefix) {
            return replacement + substring(from: prefix.endIndex)
        }
        else {
            return self
        }
    }
    
    func indexOf(_ target: String) -> Int {
        let range = self.range(of: target)
        if let range = range {
            return self.characters.distance(from: self.startIndex, to: range.lowerBound)
        } else {
            return -1
        }
    }

    func removeWhitespacesAndNewlines() -> String {
        return components(separatedBy: .whitespacesAndNewlines).joined()
    }
}
