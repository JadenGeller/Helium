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
            let attachment = item.attachments?.first as? NSItemProvider, attachment.hasItemConformingToTypeIdentifier("public.url")
        {
            attachment.loadItem(forTypeIdentifier: "public.url", options: nil)
                {
                    (url, error) in
                    
                    if let url = url as? URL,
                        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                    {
                        
                        components.scheme = "helium"
                        
                        let heliumURL = components.url!
                        
                        NSWorkspace.shared().open( heliumURL )
                    }
                    
            }
            
            self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }
        
        let error = NSError(domain: NSCocoaErrorDomain, code: NSURLErrorBadURL, userInfo: nil)
        self.extensionContext!.cancelRequest(withError: error)
    }
    
    @IBAction func send(_ sender: AnyObject?) {
        let outputItem = NSExtensionItem()
        // Complete implementation by setting the appropriate value on the output item
        
        let outputItems = [outputItem]
        self.extensionContext!.completeRequest(returningItems: outputItems, completionHandler: nil)
    }
    
    @IBAction func cancel(_ sender: AnyObject?) {
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext!.cancelRequest(withError: cancelError)
    }
    
}
