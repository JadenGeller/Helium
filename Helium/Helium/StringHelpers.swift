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
}

// From http://nshipster.com/nsregularexpression/
extension String {
	/// An `NSRange` that represents the full range of the string.
	var nsrange: NSRange {
		return NSRange(location: 0, length: utf16.count)
	}

	/// Returns a substring with the given `NSRange`,
	/// or `nil` if the range can't be converted.
	func substring(with nsrange: NSRange) -> String? {
		guard let range = nsrange.toRange()
			else { return nil }
		let start = UTF16Index(range.lowerBound)
		let end = UTF16Index(range.upperBound)
		return String(utf16[start..<end])
	}

	/// Returns a range equivalent to the given `NSRange`,
	/// or `nil` if the range can't be converted.
	func range(from nsrange: NSRange) -> Range<Index>? {
		guard let range = nsrange.toRange() else { return nil }
		let utf16Start = UTF16Index(range.lowerBound)
		let utf16End = UTF16Index(range.upperBound)

		guard let start = Index(utf16Start, within: self),
			let end = Index(utf16End, within: self)
			else { return nil }

		return start..<end
	}
}
