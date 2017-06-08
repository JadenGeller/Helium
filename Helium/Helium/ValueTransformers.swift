//
//  ValueTransformers.swift
//  Helium
//
//  Created by Carlos D. Santiago on 4/21/17.
//  Copyright © 2017 Jaden Geller. All rights reserved.
//

import Foundation

// Convert a numeric to an HMS string and back
class hmsTransformer: NSValueTransformer {
	
	// flag indicating transformation is read-write
	internal override class func allowsReverseTransformation() -> Bool {
		return true
	}

	// by default returns value
	internal override func transformedValue(value: AnyObject?) -> AnyObject? {
		if var secs : NSTimeInterval = value as? NSTimeInterval {
			let h = Int(secs / 3600)
			secs -= NSTimeInterval(h*3600)
			let m = Int(secs / 60)
			secs -= NSTimeInterval(m*60)

			//	return optional hms components
			return String(format:"%@%@%02.f",
			              (h > 0 ? String(format:"%d:",h) : ""),
			              (m > 0 ? String(format:"%02d:",m) : ""),
			              secs)
		}
		return nil
	}

	// by default raises an exception if +allowsReverseTransformation returns NO and otherwise invokes transformedValue:
	internal override func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
		return value
	}
}