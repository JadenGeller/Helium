//
//  StringHelpers.swift
//  Helium
//
//  Created by Samuel Beek on 16/03/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import Foundation

extension String {
    func replacePrefix(prefix: String, replacement: String) -> String {
        if hasPrefix(prefix) {
            return replacement + substringFromIndex(prefix.endIndex)
        }
        else {
            return self
        }
    }
    
    func indexOf(target: String) -> Int {
        let range = self.rangeOfString(target)
        if let range = range {
            return self.startIndex.distanceTo(range.startIndex)
        } else {
            return -1
        }
    }
}
