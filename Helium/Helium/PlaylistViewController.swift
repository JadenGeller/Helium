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
    var link : NSURL = NSURL.init(string: "http://")!
	var time : NSTimeInterval
	var rank : Int
    
    override init() {
        name = k.item
        link = NSURL.init(string: "http://")!
		time = 0.0
		rank = 0
        super.init()
    }
	init(name:String, link:NSURL, time:NSTimeInterval, rank:Int) {
        self.name = name
        self.link = link
		self.time = time
        self.rank = rank
        super.init()
    }
}

class PlayList: NSObject {
    var name : String = k.list
    var list : Array <PlayItem> = Array()
    
    override init() {
        name = k.list
        list = Array <PlayItem> ()
        super.init()
    }

    init(name:String, list:Array <PlayItem>) {
        self.name = name
        self.list = list
        super.init()
    }

    func listCount() -> Int {
        return list.count
    }
}

class PlaylistViewController: NSViewController,NSTableViewDataSource,NSTableViewDelegate {

    @IBOutlet var playlistArrayController: NSArrayController!
    @IBOutlet var playitemArrayController: NSArrayController!

    @IBOutlet var playlistTableView: NSTableView!
    @IBOutlet var playitemTableView: NSTableView!
    @IBOutlet var playlistSplitView: NSSplitView!

    //    cache playlists read and saved to defaults
    var defaults = NSUserDefaults.standardUserDefaults()
    var playlists = [PlayList]()
    var playCache = [PlayList]()
    
    override func viewDidLoad() {
        let types = ["public.data",kUTTypeURL as String]

        playlistTableView.registerForDraggedTypes(types)
        playitemTableView.registerForDraggedTypes(types)

        self.restorePlaylists(restoreButton)
    }

    override func viewWillAppear() {
        // cache our list before editing
        playCache = playlists

        self.playlistSplitView.setPosition(120, ofDividerAtIndex: 0)
    }

    @IBAction func addPlaylist(sender: NSButton) {
        if let play = playlistArrayController.selectedObjects.first as? PlayList {
			let item = PlayItem(name:"item#",link:NSURL.init(string: "http://")!,time:0.0,rank:play.list.count + 1);
            let temp = NSString(format:"%p",item) as String
            item.name += String(temp.characters.suffix(3))

            play.willChangeValueForKey("listCount")
            playitemArrayController.addObject(item)
            play.didChangeValueForKey("listCount")

            dispatch_async(dispatch_get_main_queue()) {
                self.playitemTableView.scrollRowToVisible(play.list.count - 1)
            }
        } else {
            let play = PlayList(name:"play#", list:Array <PlayItem>())
            let temp = NSString(format:"%p",play) as String
            play.name += String(temp.characters.suffix(3))
            
            playlistArrayController.addObject(play)

            dispatch_async(dispatch_get_main_queue()) {
                self.playlistTableView.scrollRowToVisible(self.playlists.count - 1)
            }
        }
    }

    @IBAction func removePlaylist(sender: NSButton) {
        if let selectedPlayItem = playitemArrayController.selectedObjects.first as? PlayItem {
            let selectedPlaylist = playlistArrayController.selectedObjects.first as? PlayList

            selectedPlaylist?.willChangeValueForKey("listCount")
            playitemArrayController.removeObject(selectedPlayItem)
            selectedPlaylist?.didChangeValueForKey("listCount")
        }
        else
        if let selectedPlaylist = playlistArrayController.selectedObjects.first as? PlayList {
            playlistArrayController.removeObject(selectedPlaylist)
        }
    }

    @IBAction func playPlaylist(sender: AnyObject) {
        if let selectedPlayItem = playitemArrayController.selectedObjects.first as? PlayItem {
            let selectedPlaylist = playlistArrayController.selectedObjects.first as? PlayList
            super.dismissController(sender)

            print("play \(selectedPlayItem.name) from \(selectedPlaylist!.name)")

            let notif = NSNotification(name: "HeliumPlaylistItem", object: selectedPlayItem.link);
            NSNotificationCenter.defaultCenter().postNotification(notif)
        }
        else
        if let selectedPlaylist = playlistArrayController.selectedObjects.first as? PlayList {
            if selectedPlaylist.list.count > 0 {
                super.dismissController(sender)

                print("play \(selectedPlaylist.name) \(selectedPlaylist.list.count)")
                for (i,item) in selectedPlaylist.list.enumerate() {
                    print("\(i) \(item.rank) \(item.name)")
                }
            }
        }
    }
    
    @IBOutlet weak var restoreButton: NSButton!
    @IBAction func restorePlaylists(sender: NSButton) {
        if let playArray = defaults.arrayForKey(UserSetting.Playlists.userDefaultsKey) {
            playlistArrayController.removeObjects(playlistArrayController.arrangedObjects as! [AnyObject])

            for playlist in playArray {
                let play = playlist as! Dictionary<String,AnyObject>
                let items = play[k.list] as! [Dictionary <String,AnyObject>]
                var list : [PlayItem] = [PlayItem]()
                for playitem in items {
                    let item = playitem as Dictionary <String,AnyObject>
                    let name = item[k.name] as! String
                    let path = item[k.link] as! String
					let time = item[k.time] as? NSTimeInterval
                    let link = NSURL.init(string: path)
                    let rank = item[k.rank] as! Int
					let temp = PlayItem(name:name, link:link!, time:time!, rank:rank)
                    list.append(temp)
                }
                let name = play[k.name] as! String
                let temp = PlayList(name: name, list: list)
                playlistArrayController.addObject(temp)
            }
        }
    }

    @IBOutlet weak var saveButton: NSButton!
    @IBAction func savePlaylists(sender: AnyObject) {
        let playArray = playlistArrayController.arrangedObjects as! [PlayList]
        var temp = Array<AnyObject>()
        for playlist in playArray {
            var list = Array<AnyObject>()
            for playitem in playlist.list {
				let item : [String:AnyObject] = [k.name:playitem.name, k.link:playitem.link.absoluteString, k.time:playitem.time, k.rank:playitem.rank]
                list.append(item)
            }
            temp.append([k.name:playlist.name, k.list:list])
        }
        defaults.setObject(temp, forKey: UserSetting.Playlists.userDefaultsKey)
        defaults.synchronize()
    }
    
    @IBAction override func dismissController(sender: AnyObject?) {
        super.dismissController(sender)
        print(sender?.title)
        //    Save or go
        switch sender!.tag == 0 {
            case true:
                print("true")
                break
            case false:
                //    Restore from cache
                playlists = playCache
                print("false")
        }
    }
    
    // MARK: Drag-n-Drop
    
    func draggingEntered(sender: NSDraggingInfo!) -> NSDragOperation {
        let pasteboard = sender.draggingPasteboard()

        if pasteboard.canReadItemWithDataConformingToTypes([NSPasteboardURLReadingFileURLsOnlyKey]) {
            return .Copy
        }
        return .Copy
    }

    func tableView(tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let item = NSPasteboardItem()
        
        item.setString(String(row), forType: "public.data")
        
        return item
    }

    func tableView(tableView: NSTableView, writeRowsWith rowIndexes: NSIndexSet, to pboard: NSPasteboard) -> Bool {
        let data = NSKeyedArchiver.archivedDataWithRootObject(rowIndexes)
        let registeredTypes:[String] = ["public.data"]

        pboard.declareTypes(registeredTypes, owner: self)
        pboard.setData(data, forType: "public.data")
        
        return true
    }
    
    func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {

        if dropOperation == .Above {
            let pboard = info.draggingPasteboard();
            let options = [NSPasteboardURLReadingFileURLsOnlyKey : true,
                           NSPasteboardURLReadingContentsConformToTypesKey : [kUTTypeMovie as String]]
            let items = pboard.readObjectsForClasses([NSURL.classForCoder()], options: options)
            if items!.count > 0 {
                for item in items! {
                    if item.isFileReferenceURL() {
                        let fileURL : NSURL? = item.filePathURL
                        
                        //    if it's a video file, get and set window content size to its dimentions
                        let track0 = AVURLAsset(URL:fileURL!, options:nil).tracks[0]
                        if track0.mediaType != AVMediaTypeVideo
                        {
                            return .None
                        }
                    } else {
                        print("validate item -> \(item)")
                    }
                }
            }
            return .Move
        }
        return .None
    }
    
    func rearrange<T>(array: Array<T>, fromIndex: Int, toIndex: Int) -> Array<T> {
        var arr = array
        let element = arr.removeAtIndex(fromIndex)
        arr.insert(element, atIndex: toIndex)
        
        return arr
    }
    
	func metadataDictionaryForFileAt(fileName: String) -> Dictionary<NSObject,AnyObject>? {

		let item = MDItemCreate(kCFAllocatorDefault, fileName)
		if ( item == nil) { return nil };
		
		let list = MDItemCopyAttributeNames(item)
		let resDict = MDItemCopyAttributes(item,list) as Dictionary
		return resDict
	}

	func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        let pasteboard = info.draggingPasteboard()
        let options = [NSPasteboardURLReadingFileURLsOnlyKey : true,
                       NSPasteboardURLReadingContentsConformToTypesKey : [kUTTypeMovie as String]]
        var oldIndexes = [Int]()
        var items : [AnyObject]
        var oldIndexOffset = 0
        var newIndexOffset = 0

        //    we have intra tableView drag-n-drop ?
        info.enumerateDraggingItemsWithOptions([], forView: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) {
            tableView.beginUpdates()

            if let str = ($0.0.item as! NSPasteboardItem).stringForType("public.data"), index = Int(str) {
                oldIndexes.append(index)
            }
            // For simplicity, the code below uses `tableView.moveRowAtIndex` to move rows around directly.
            // You may want to move rows in your content array and then call `tableView.reloadData()` instead.
            
            for oldIndex in oldIndexes {
                if oldIndex < row {
                    tableView.moveRowAtIndex(oldIndex + oldIndexOffset, toIndex: row - 1)
//                    print("move \(oldIndex+oldIndexOffset) +> \(row-1)")
                    if tableView == self.playlistTableView {
                        self.playlists = self.rearrange(self.playlists, fromIndex: (oldIndex+oldIndexOffset), toIndex: (row-1))
                    } else {
                        let playlist = self.playlistArrayController.selectedObjects.first as! PlayList
                        let list = playlist.list
                        playlist.list = self.rearrange(list, fromIndex: (oldIndex+oldIndexOffset), toIndex: (row-1))
                    }
                    oldIndexOffset -= 1
                } else {
                    tableView.moveRowAtIndex(oldIndex, toIndex: row + newIndexOffset)
//                    print("move \(oldIndex) -> \(row+newIndexOffset)")
                    if tableView == self.playlistTableView {
                        self.playlists = self.rearrange(self.playlists, fromIndex: (oldIndex), toIndex: (row+newIndexOffset))
                    } else {
                        let playlist = self.playlistArrayController.selectedObjects.first as! PlayList
                        let list = playlist.list
                        playlist.list = self.rearrange(list, fromIndex: (oldIndex), toIndex: (row+newIndexOffset))
                    }
                    newIndexOffset += 1
                }
            }

            tableView.endUpdates()
        }
        
        //    We have a Finder drag-n-drop of file URLs ?
        items = pasteboard.readObjectsForClasses([NSURL.classForCoder()], options: options)!
        if items.count > 0 {
            var play = playlistArrayController.selectedObjects.first as? PlayList
            
            if (play == nil) {
                let spec = items.first?.URLByDeletingLastPathComponent
                let head = spec!?.absoluteString
                let temp = PlayList(name:head!, list:Array <PlayItem>())
            
                playlistArrayController.addObject(temp)
                play = temp
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.playlistTableView.scrollRowToVisible(self.playlists.count - 1)
                }
            }
            
            play!.willChangeValueForKey("listCount")
            for itemURL in items {
                if itemURL.isFileReferenceURL() {
                    let fileURL : NSURL? = itemURL.filePathURL
                    let path = fileURL!.absoluteString//.stringByRemovingPercentEncoding
					let attr = metadataDictionaryForFileAt((fileURL?.path)!)
//					print("attr \(attr)")
					let time = attr?[kMDItemDurationSeconds] as! NSTimeInterval
                    let item = PlayItem(name:(itemURL.URLByDeletingPathExtension!!.lastPathComponent!.stringByRemovingPercentEncoding!),
                                        link:NSURL.init(string: path)!,
                                        time:time,
                                        rank:play!.list.count + 1)
                    playitemArrayController.insertObject(item, atArrangedObjectIndex: row + newIndexOffset)
                    newIndexOffset += 1
                } else {
                    print("accept item -> \(itemURL.absoluteString)")
                }
            }
            play!.didChangeValueForKey("listCount")
                
            dispatch_async(dispatch_get_main_queue()) {
                let rows = NSIndexSet.init(indexesInRange: NSMakeRange(row, newIndexOffset))
                self.playitemTableView.selectRowIndexes(rows, byExtendingSelection: false)
            }
        }
            
        if let selectedPlaylist = playlistArrayController.selectedObjects.first as? PlayList {
            if selectedPlaylist.list.count > 0 {
            
                tableView.beginUpdates()
                print("list \(selectedPlaylist.name) \(selectedPlaylist.list.count)")
                for (i,item) in selectedPlaylist.list.enumerate() {
                    item.rank = (i+1)
                    print("\(i) \(item.rank) \(item.name)")
                }
                tableView.endUpdates()
            }
        }

        return true
    }

}
