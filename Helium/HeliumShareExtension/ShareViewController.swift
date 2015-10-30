//
//  ShareViewController.swift
//  Share
//
//  Created by Kyle Carson on 10/30/15.
//  Copyright © 2015 Jaden Geller. All rights reserved.
//

import Cocoa

class ShareViewController: NSViewController {
	
	override var nibName: String? {
		return "ShareViewController"
	}
	
	override func viewDidLoad() {
		
		if let item = self.extensionContext!.inputItems.first as? NSExtensionItem,
			let attachment = item.attachments?.first as? NSItemProvider
			where attachment.hasItemConformingToTypeIdentifier("public.url")
		{
			attachment.loadItemForTypeIdentifier("public.url", options: nil)
				{
					(url, error) in
					
					if let url = url as? NSURL,
						let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
					{
						
						components.scheme = "helium"
						
						let heliumURL = components.URL!
						
						NSWorkspace.sharedWorkspace().openURL( heliumURL )
					}
					
			}
			
			self.extensionContext!.completeRequestReturningItems(nil, completionHandler: nil)
			return
		}
		
		let error = NSError(domain: NSCocoaErrorDomain, code: NSURLErrorBadURL, userInfo: nil)
		self.extensionContext!.cancelRequestWithError(error)
	}
	
	@IBAction func send(sender: AnyObject?) {
		let outputItem = NSExtensionItem()
		// Complete implementation by setting the appropriate value on the output item
		
		let outputItems = [outputItem]
		self.extensionContext!.completeRequestReturningItems(outputItems, completionHandler: nil)
	}
	
	@IBAction func cancel(sender: AnyObject?) {
		let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
		self.extensionContext!.cancelRequestWithError(cancelError)
	}
	
}
