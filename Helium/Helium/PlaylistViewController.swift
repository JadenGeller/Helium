//
//  PlaylistViewController.swift
//  Helium
//
//  Created by Carlos D. Santiago on 2/15/17.
//  Copyright © 2017 Jaden Geller. All rights reserved.
//

import Foundation
import AVFoundation

struct k {
    static let play = "play"
    static let item = "item"
    static let name = "name"
    static let list = "list"
    static let link = "link"
    static let time = "time"
    static let rank = "rank"
}

class PlayItem : NSObject {
    var name : String = k.item
    var link : URL = URL.init(string: "http://")!
    var time : TimeInterval
    var rank : Int
    
    override init() {
        name = k.item
        link = URL.init(string: "http://")!
        time = 0.0
        rank = 0
        super.init()
    }
    init(name:String, link:URL, time:TimeInterval, rank:Int) {
        self.name = name
        self.link = link
        self.time = time
        self.rank = rank
        super.init()
    }
    override var description : String {
        return String(format: "%@: %p '%@'", self.className, self, name)
    }
}

class PlayTableView : NSTableView {
    override func keyDown(with event: NSEvent) {
        if event.charactersIgnoringModifiers! == String(Character(UnicodeScalar(NSDeleteCharacter)!)) ||
           event.charactersIgnoringModifiers! == String(Character(UnicodeScalar(NSDeleteFunctionKey)!)) {
            // Take action in the delegate.
            let delegate: PlaylistViewController = self.delegate as! PlaylistViewController
            
            delegate.removePlaylist(self)
        }
        else
        {
            // still here?
            super.keyDown(with: event)
        }
    }
    
    func tableViewColumnDidResize(notification: NSNotification ) {
        // Pay attention to column resizes and aggressively force the tableview's
        // cornerview to redraw.
        self.cornerView?.needsDisplay = true
    }

}

class PlayItemCornerView : NSView {
    @IBOutlet weak var playitemTableView: PlayTableView!
    override func draw(_ dirtyRect: NSRect) {
        let tote = NSImage.init(imageLiteralResourceName: "NSRefreshTemplate")
        let alignRect = tote.alignmentRect
        
        NSGraphicsContext.saveGraphicsState()
        tote.draw(in: NSMakeRect(2, 5, 7, 11), from: alignRect, operation: .sourceOver, fraction: 1)
        NSGraphicsContext.restoreGraphicsState()
    }
    
    override func mouseDown(with event: NSEvent) {
        playitemTableView.beginUpdates()
        // Renumber playlist items
        let col = playitemTableView.column(withIdentifier: "rank")
        for row in 0...playitemTableView.numberOfRows-1 {
            let cell = playitemTableView.view(atColumn: col, row: row, makeIfNecessary: true) as! NSTableCellView
            cell.textField?.integerValue = row + 1
        }
        playitemTableView.endUpdates()
    }
}

extension NSURL {
    
    func compare(_ other: URL ) -> ComparisonResult {
        return (self.absoluteString?.compare(other.absoluteString))!
    }
}

class PlaylistViewController: NSViewController,NSTableViewDataSource,NSTableViewDelegate {

    @IBOutlet var playlistArrayController: NSDictionaryController!
    @IBOutlet var playitemArrayController: NSArrayController!

    @IBOutlet var playlistTableView: PlayTableView!
    @IBOutlet var playitemTableView: PlayTableView!
    @IBOutlet var playlistSplitView: NSSplitView!

    //    cache playlists read and saved to defaults
    var appDelegate: AppDelegate = NSApp.delegate as! AppDelegate
    var defaults = UserDefaults.standard
    var playlists = Dictionary<String, Any>()
    var playCache = Dictionary<String, Any>()
    
    override func viewDidLoad() {
        let types = ["public.data",kUTTypeURL as String,
                     NSFilenamesPboardType,
                     NSURLPboardType]

        playlistTableView.register(forDraggedTypes: types)
        playitemTableView.register(forDraggedTypes: types)

        self.restorePlaylists(restoreButton)
    }

    var historyCache: NSDictionaryControllerKeyValuePair? = nil
    override func viewWillAppear() {
        // cache our list before editing
        playCache = playlists
        
        // add existing history entry if any
        if historyCache == nil && appDelegate.histories.count > 0 {
            playlists[UserSettings.Histories.value] = nil
            
            // overlay in history using NSDictionaryControllerKeyValuePair Protocol setKey
            historyCache = playlistArrayController.newObject() as NSDictionaryControllerKeyValuePair
            historyCache!.key = UserSettings.Histories.value
            historyCache!.value = appDelegate.histories
            playlistArrayController.addObject(historyCache!)
        }
        else
        if historyCache != nil
        {
            historyCache!.value = appDelegate.histories
        }
        
        self.playlistSplitView.setPosition(120, ofDividerAt: 0)
    }

    @IBAction func addPlaylist(_ sender: NSButton) {
        if let selectedPlaylist = playlistArrayController.selectedObjects.first as? NSDictionaryControllerKeyValuePair {
            let list: Array<PlayItem> = selectedPlaylist.value as! Array
            let item = PlayItem(name:"item#",link:URL.init(string: "http://")!,time:0.0,rank:list.count + 1);
            let temp = NSString(format:"%p",item) as String
            item.name += String(temp.characters.suffix(3))

            playitemArrayController.addObject(item)

            DispatchQueue.main.async {
                self.playitemTableView.scrollRowToVisible(list.count - 1)
            }
        } else {
            let item = playlistArrayController.newObject()
            let list = Array <PlayItem>()

            let temp = NSString(format:"%p",list) as String
            let name = "play#" + String(temp.characters.suffix(3))
            item.key = name
            item.value = list
            
            playlistArrayController.addObject(item)

            DispatchQueue.main.async {
                self.playlistTableView.scrollRowToVisible(self.playlists.count - 1)
            }
        }
    }

    @IBAction func removePlaylist(_ sender: AnyObject) {
        if sender as! NSObject == playlistTableView, let selectedPlaylist = playlistArrayController.selectedObjects.first as? NSDictionaryControllerKeyValuePair {
            playlistArrayController.removeObject(selectedPlaylist)
        }
        else
        if sender as! NSObject == playitemTableView, let selectedPlayItem = playitemArrayController.selectedObjects.first as? PlayItem {
            playitemArrayController.removeObject(selectedPlayItem)
        }
        else
        if let selectedPlayItem = playitemArrayController.selectedObjects.first as? PlayItem {
            playitemArrayController.removeObject(selectedPlayItem)
        }
        else
        if let selectedPlaylist = playlistArrayController.selectedObjects.first as? Dictionary<String,AnyObject> {
            playlistArrayController.removeObject(selectedPlaylist)
        }
        else
        {
             AudioServicesPlaySystemSound(1051);
        }
    }

    @IBAction func playPlaylist(_ sender: AnyObject) {
        if let selectedPlayItem = playitemArrayController.selectedObjects.first as? PlayItem {
            let selectedPlaylist = playlistArrayController.selectedObjects.first as? NSDictionaryControllerKeyValuePair
            super.dismiss(sender)

            Swift.print("play \(selectedPlayItem.name) from \(String(describing: selectedPlaylist?.key!))")

            let notif = Notification(name: Notification.Name(rawValue: "HeliumPlaylistItem"), object: selectedPlayItem.link);
            NotificationCenter.default.post(notif)
        }
        else
        if let selectedPlaylist = playlistArrayController.selectedObjects.first as? NSDictionaryControllerKeyValuePair {
            let list: Array<PlayItem> = selectedPlaylist.value as! Array
            
            if list.count > 0 {
                super.dismiss(sender)
                // TODO: For now just log what we would play once we figure out how to determine when an item finishes so we can start the next
                print("play \(selectedPlaylist) \(list.count)")
                for (i,item) in list.enumerated() {
                    print("\(i) \(item.rank) \(item.name)")
                }
            }
        }
    }
    
    @IBOutlet weak var restoreButton: NSButton!
    @IBAction func restorePlaylists(_ sender: NSButton) {
        if let playArray = defaults.array(forKey: UserSettings.Playlists.keyPath) {
            playlistArrayController.remove(contentsOf: playlistArrayController.arrangedObjects as! [AnyObject])

            for playlist in playArray {
                let play = playlist as! Dictionary<String,AnyObject>
                let items = play[k.list] as! [Dictionary <String,AnyObject>]
                var list : [PlayItem] = [PlayItem]()
                for playitem in items {
                    let item = playitem as Dictionary <String,AnyObject>
                    let name = item[k.name] as! String
                    let path = item[k.link] as! String
                    let time = item[k.time] as? TimeInterval
                    let link = URL.init(string: path)
                    let rank = item[k.rank] as! Int
                    let temp = PlayItem(name:name, link:link!, time:time!, rank:rank)
                    list.append(temp)
                }
                let name = play[k.name] as? String

                // Use NSDictionaryControllerKeyValuePair Protocol setKey
                let temp = playlistArrayController.newObject() as NSDictionaryControllerKeyValuePair
                temp.key = name
                temp.value = list
                playlistArrayController.addObject(temp)
            }
        }
    }

    @IBOutlet weak var saveButton: NSButton!
    @IBAction func savePlaylists(_ sender: AnyObject) {
        let playArray = playlistArrayController.arrangedObjects as! [NSDictionaryControllerKeyValuePair]
        var temp = [Dictionary<String,AnyObject>]()
        for playlist in playArray {
            var list = Array<AnyObject>()
            for playitem in playlist.value as! [PlayItem] {
                let item : [String:AnyObject] = [k.name:playitem.name as AnyObject, k.link:playitem.link.absoluteString as AnyObject, k.time:playitem.time as AnyObject, k.rank:playitem.rank as AnyObject]
                list.append(item as AnyObject)
            }
            temp.append([k.name:playlist.key as AnyObject, k.list:list as AnyObject])
        }
        defaults.set(temp, forKey: UserSettings.Playlists.keyPath)
        defaults.synchronize()
    }
    
    @IBAction override func dismiss(_ sender: Any?) {
        super.dismiss(sender)

        //    Save or go
        switch (sender! as AnyObject).tag == 0 {
            case true:
                // Save history info which might have changed
                if historyCache != nil {
                    appDelegate.histories = historyCache?.value as! Array<PlayItem>
                    UserSettings.Histories.value = (historyCache?.key)!
                }
                break
            case false:
                // Restore from cache
                playlists = playCache
        }
    }
    
    // MARK:- Drag-n-Drop
    
    func draggingEntered(_ sender: NSDraggingInfo!) -> NSDragOperation {
        let pasteboard = sender.draggingPasteboard()

        if pasteboard.canReadItem(withDataConformingToTypes: [NSPasteboardURLReadingFileURLsOnlyKey]) {
            return .copy
        }
        return .copy
    }

    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let item = NSPasteboardItem()
        
        item.setString(String(row), forType: "public.data")
        
        return item
    }

    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: rowIndexes)
        let registeredTypes:[String] = ["public.data"]

        pboard.declareTypes(registeredTypes, owner: self)
        pboard.setData(data, forType: "public.data")
        
        return true
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        let sourceTableView = info.draggingSource() as? NSTableView

        if sourceTableView == tableView {
            Swift.print("drag same")
        }
        else
        if sourceTableView == playlistTableView {
            Swift.print("drag from playlist")
        }
        else
        if sourceTableView == playitemTableView {
            Swift.print("drag from playitem")
        }
        if dropOperation == .above {
            let pboard = info.draggingPasteboard();
            let options = [NSPasteboardURLReadingFileURLsOnlyKey : true,
                           NSPasteboardURLReadingContentsConformToTypesKey : [kUTTypeMovie as String]] as [String : Any]
            let items = pboard.readObjects(forClasses: [NSURL.classForCoder()], options: options)
            if items!.count > 0 {
                for item in items! {
                    if (item as! NSURL).isFileReferenceURL() {
                        let fileURL : NSURL? = (item as AnyObject).filePathURL!! as NSURL
                        
                        //    if it's a video file, get and set window content size to its dimentions
                        let track0 = AVURLAsset(url:fileURL! as URL, options:nil).tracks[0]
                        if track0.mediaType != AVMediaTypeVideo
                        {
                            return NSDragOperation()
                        }
                    } else {
                        print("validate item -> \(item)")
                    }
                }
            }
            Swift.print("drag move")
            return .move
        }
        Swift.print("drag \(NSDragOperation())")
        return NSDragOperation()
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        let pasteboard = info.draggingPasteboard()
        let options = [NSPasteboardURLReadingFileURLsOnlyKey : true,
                       NSPasteboardURLReadingContentsConformToTypesKey : [kUTTypeMovie as String]] as [String : Any]
        let sourceTableView = info.draggingSource() as? NSTableView
        var oldIndexes = [Int]()
        var oldIndexOffset = 0
        var newIndexOffset = 0

        // We have intra tableView drag-n-drop ?
        if tableView == sourceTableView {
            Swift.print("same \(String(describing: tableView.identifier))")
            info.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) {
                tableView.beginUpdates()

                if let str = ($0.0.item as! NSPasteboardItem).string(forType: "public.data"), let index = Int(str) {
                    oldIndexes.append(index)
                }
                // For simplicity, the code below uses `tableView.moveRowAtIndex` to move rows around directly.
                // You may want to move rows in your content array and then call `tableView.reloadData()` instead.
                
                for oldIndex in oldIndexes {
                    if oldIndex < row {
                        tableView.moveRow(at: oldIndex + oldIndexOffset, to: row - 1)
                        oldIndexOffset -= 1
                    } else {
                        tableView.moveRow(at: oldIndex, to: row + newIndexOffset)
                        newIndexOffset += 1
                    }
                }
                tableView.endUpdates()
            }
        }
        else

        // We have inter tableView drag-n-drop ?
        // if source is a playlist, drag its items into the destination via copy
        // if source is a playitem, drag all items into the destination playlist
        // creating a new playlist item unless, we're dropping onto an existing.
        
        if sourceTableView == playlistTableView {
            Swift.print("from \(String(describing: sourceTableView?.identifier)) into \(String(describing: tableView.identifier))")
            
        }
        else
        
        if sourceTableView == playitemTableView {
            Swift.print("from \(String(describing: sourceTableView?.identifier)) into \(String(describing: tableView.identifier))")
            
        }
        else

        //    We have a Finder drag-n-drop of file or location URLs ?
        if let items: Array<AnyObject> = pasteboard.readObjects(forClasses: [NSURL.classForCoder()], options: options) as Array<AnyObject>? {
            Swift.print("into \(String(describing: tableView.identifier))")
            
            var play = playlistArrayController.selectedObjects.first as? NSDictionaryControllerKeyValuePair
            var okydoKey = false
            
            if (play == nil) {
                play = playlistArrayController.newObject() as NSDictionaryControllerKeyValuePair
                play?.value = Array <PlayItem>()
            
                playlistArrayController.addObject(play!)
                
                DispatchQueue.main.async {
                    self.playlistTableView.scrollRowToVisible(self.playlists.count - 1)
                }
            }
            else
            {
                okydoKey = true
            }
            
            for itemURL in items {
                if (itemURL as! NSURL).isFileReferenceURL() {
                    let fileURL : URL? = (itemURL as AnyObject).filePathURL

                    // Capture playlist name from origin folder of 1st item
                    if !okydoKey {
                        let spec = fileURL?.deletingLastPathComponent
                        let head = spec!().absoluteString
                        play?.key = head
                        okydoKey = true
                    }
                    
                    let path = fileURL!.absoluteString//.stringByRemovingPercentEncoding
                    let attr = appDelegate.metadataDictionaryForFileAt((fileURL?.path)!)
                    let time = attr?[kMDItemDurationSeconds] as! TimeInterval
                    let fuzz = (itemURL as AnyObject).deletingPathExtension!!.lastPathComponent as NSString
                    let name = fuzz.removingPercentEncoding
                    let item = PlayItem(name:name!,
                                        link:URL.init(string: path)!,
                                        time:time,
                                        rank:(playitemArrayController.arrangedObjects as AnyObject).count + 1)
                    playitemArrayController.insert(item, atArrangedObjectIndex: row + newIndexOffset)
                    newIndexOffset += 1
                } else {
                    print("accept item -> \((itemURL as AnyObject).absoluteString)")
                }
            }
            
            // Try to pick off whatever they sent us
            if items.count == 0 {
                for element in pasteboard.pasteboardItems! {
                    for type in element.types {
                        let item = element.string(forType:type)
                        if type == "public.url" {
                            if !okydoKey {
                                play?.key = type
                            }
                            let url = URL.init(string: item!)
                            let fuzz = url?.deletingPathExtension().lastPathComponent
                            let name = fuzz?.removingPercentEncoding
                            let temp = PlayItem(name: name!,
                                                link: url!,
                                                time: 0,
                                                rank: (playitemArrayController.arrangedObjects as AnyObject).count + 1)
                            playitemArrayController.insert(temp, atArrangedObjectIndex: row + newIndexOffset)
                            newIndexOffset += 1
                            break
                        }
                        else
                        {
                            Swift.print("type \(type) \(item!)")
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                let rows = IndexSet.init(integersIn: NSMakeRange(row, newIndexOffset).toRange() ?? 0..<0)
                self.playitemTableView.selectRowIndexes(rows, byExtendingSelection: false)
            }
        }
        else
        {
            Swift.print("WTF \(info)")
            return false
        }
        return true
    }

}
