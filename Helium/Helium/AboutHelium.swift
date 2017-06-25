//
//  AboutHelium.swift
//  Helium
//
//  Created by Carlos D. Santiago on 6/24/17.
//  Copyright © 2017 Jaden Geller. All rights reserved.
//

import Foundation
let kTitleUtility =		16
let	kTitleNormal =		22

class AboutBoxController : NSViewController {
	
    @IBOutlet var toggleButton: NSButton!
	@IBOutlet var appNameField: NSTextField!
    @IBOutlet var creditScroll: NSScrollView!
	@IBOutlet var creditsField: NSTextView!
    @IBOutlet var creditsButton: NSButton!
    @IBOutlet var versionButton: NSButton!
    @IBOutlet var creditSeparatorBox: NSBox!
    
    @IBOutlet var hideView: NSView!
    var hideRect: NSRect?
    var origRect: NSRect?
    
    @IBAction func toggleContent(_ sender: Any) {
        // Toggle content visibility
        if let window = self.view.window {
            let oldSize = window.contentView?.bounds.size
            var frame = window.frame
            if toggleButton.state == NSOffState {
                
                frame.origin.y += ((oldSize?.height)! - (hideRect?.size.height)!)
                window.setFrameOrigin(frame.origin)
                window.setContentSize((hideRect?.size)!)
                
                window.showsResizeIndicator = false
                window.minSize = NSMakeSize((hideRect?.size.width)!,(hideRect?.size.height)!+CGFloat(kTitleNormal))
                window.maxSize = window.minSize
                creditScroll.isHidden = true
            }
            else
            {
                let hugeSize = NSMakeSize(CGFloat(Float.greatestFiniteMagnitude), CGFloat(Float.greatestFiniteMagnitude))
                
                frame.origin.y += ((oldSize?.height)! - (origRect?.size.height)!)
                window.setFrameOrigin(frame.origin)
                window.setContentSize((origRect?.size)!)

                window.showsResizeIndicator = true
                window.minSize = NSMakeSize((origRect?.size.width)!,(origRect?.size.height)!+CGFloat(kTitleNormal))
                window.maxSize = hugeSize
                creditScroll.isHidden = false
            }
        }
    }
    
    @IBAction func toggleCredits(_ sender: Any) {

        AboutBoxController.creditsState += 1
        if AboutBoxController.creditsState >= AboutBoxController.maxStates
        {
            AboutBoxController.creditsState = 0
        }

        let credits = ["README", "Credits", "LICENSE"];
        
        //	Setup our credits; if sender is nil, give 'em long history
        let creditsString = NSAttributedString.string(fromAsset: credits[AboutBoxController.creditsState])
        creditsField.string = creditsString
    }
    
    @IBAction func toggleVersion(_ sender: Any) {
        
        AboutBoxController.versionState += 1
        if AboutBoxController.versionState >= AboutBoxController.maxStates
        {
            AboutBoxController.versionState = 0
        }

        let titles = [ versionData, versionLink, versionDate ]
        versionButton.title = titles[AboutBoxController.versionState]!

        let tooltip = [ "version", "build", "timestamp" ]
        versionButton.toolTip = tooltip[AboutBoxController.versionState];
    }

    var versionData: String? = nil
    var versionLink: String? = nil
    var versionDate: String? = nil

    var appName: String? = nil
    var versionString: String? = nil
    var copyrightString: String? = nil

    static var versionState: Int = 0
    static var creditsState: Int = 0
    static let maxStates: Int = 3

    override func viewWillAppear() {
        print("viewWillAppear")
        let theWindow = appNameField.window

        //	We no need no sticking title!
        theWindow?.title = ""

        appNameField.stringValue = appName!
        versionButton.title = versionData!
        creditsButton.title = copyrightString!

        if (appNameField.window?.isVisible)! {
            creditsField.scroll(NSMakePoint( 0, 0 ))
        }
        
        // Version criteria to cycle thru
        AboutBoxController.versionState = -1
        toggleVersion(self)

        //  Credit criteria initially hidden
        AboutBoxController.creditsState = 0-1
        toggleButton.state = NSOffState
        toggleCredits(self)
        toggleContent(self)
        
        // Setup the window
        theWindow?.isExcludedFromWindowsMenu = true
        theWindow?.menu = nil
        theWindow?.center()

        //	Show the window
        appNameField.window?.makeKeyAndOrderFront(self)
    }
    
    override func viewDidLoad() {
        print("viewDidLoad")
        
        //	Initially don't show history
        toggleButton.state = NSOffState
 
        //	Get the info dictionary (Info.plist)
        let infoDictionary = (Bundle.main.infoDictionary)!

        //	Get the app name field
        appName = infoDictionary[kCFBundleExecutableKey as String] as? String
        
        //	Setup the version to one we constrict
        versionString = String(format:"Version %@ (%@)",
                               infoDictionary["CFBundleShortVersionString"] as! CVarArg,
                               infoDictionary["CFBundleVersion"] as! CVarArg)

        // Version criteria to cycle thru
        self.versionData = versionString;
        self.versionLink = String(format:"Build %@",
                                  infoDictionary["CFBuildNumber"] as! CVarArg)
        self.versionDate = infoDictionary["CFBuildDate"] as? String;

        //  Capture hide and show initial sizes
        hideRect = hideView.frame
        origRect = self.view.frame

        // Setup the copyright field
        copyrightString = infoDictionary["NSHumanReadableCopyright"] as? String
        toggleButton.state = NSOffState
    }
    
}
