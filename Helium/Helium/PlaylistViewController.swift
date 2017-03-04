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
	static let rank = "rank"
}

class PlayItem : NSObject {
	var name : String = k.item
	var link : NSURL = NSURL.init(string: "http://")!
	var rank = 0
	
	override init() {
		name = k.item
		link = NSURL.init(string: "http://")!
		super.init()
	}
	init(name:String, link:NSURL, rank:Int) {
		self.name = name
		self.link = link
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

class PlaylistViewController: NSViewController,NSTableViewDelegate {

	@IBOutlet var playlistArrayController: NSArrayController!
	@IBOutlet var playitemArrayController: NSArrayController!

	@IBOutlet var playlistTableView: NSTableView!
	@IBOutlet var playitemTableView: NSTableView!

	//	cache playlists read and saved to defaults
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
	}

	@IBAction func addPlaylist(sender: NSButton) {
		if let play = playlistArrayController.selectedObjects.first as? PlayList {
			let item = PlayItem(name:"item#",link:NSURL.init(string: "http://")!,rank:play.list.count + 1);
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
		if let selectedPlaylist = playlistArrayController.selectedObjects.first as? PlayList {
			if selectedPlaylist.list.count > 0 {
				super.dismissController(sender)
				
				print("play \(selectedPlaylist.name) \(selectedPlaylist.list)")
				for item in selectedPlaylist.list {
					print("\(item.rank) \(item.name)")
				}
			}
		}
	}
	
	@IBOutlet weak var restoreButton: NSButton!
	@IBAction func restorePlaylists(sender: NSButton) {
		if let playArray = defaults.arrayForKey(UserSetting.Playlists.userDefaultsKey) {
			playlistArrayController.removeObjects(playlistArrayController.arrangedObjects as! [AnyObject])
//			self.playlists = [PlayList]()

			for playlist in playArray {
				let play = playlist as! Dictionary<String,AnyObject>
				let items = play[k.list] as! [Dictionary <String,AnyObject>]
				var list : [PlayItem] = [PlayItem]()
				for playitem in items {
					let item = playitem as Dictionary <String,AnyObject>
					let name = item[k.name] as! String
					let path = item[k.link] as! String
					let link = NSURL.init(string: path)
					let rank = item[k.rank] as! Int
					let temp = PlayItem(name:name, link:link!, rank:rank)
					list.append(temp)
				}
				let name = play[k.name] as! String
				let temp = PlayList(name: name, list: list)
				playlistArrayController.addObject(temp)
			}
			dispatch_async(dispatch_get_main_queue()) {
				self.playlistTableView.reloadData()
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
				let item : [String:AnyObject] = [k.name:playitem.name, k.link:playitem.link.absoluteString, k.rank:playitem.rank]
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
		//	Save or go
		switch sender!.tag == 0 {
			case true:
				print("true")
				break
			case false:
				//	Restore from cache
				playlists = playCache
				print("false")
		}
	}
	
	// MARK: Drag-n-Drop
	
	func draggingEntered(sender: NSDraggingInfo!) -> NSDragOperation {
		let pasteboard = sender.draggingPasteboard()
//		let filteringOptions = [NSPasteboardURLReadingContentsConformToTypesKey:NSImage.imageTypes()]

		print("draggingEntered")

		if pasteboard.canReadItemWithDataConformingToTypes([NSPasteboardURLReadingFileURLsOnlyKey])
			/*.canReadObject(forClasses: [NSURL.self], options: filteringOptions)*/ {
			return .Copy
		}
		return .Copy
	}
	
	func draggingUpdated(sender: NSDraggingInfo!) -> NSDragOperation  {
		print("draggingUpdated")
		return NSDragOperation.Copy
	}
	
	func tableView(tableView: NSTableView, namesOfPromisedFilesDroppedAtDestination dropDestination: NSURL, forDraggedRowsWith indexSet: NSIndexSet) -> [String] {
		print("drop(s) \(dropDestination)")
		return ["tom","dick","harry"]
	}

	func tableView(tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
//		let type = (tableView == playlistTableView ? Constants.PlayList : Constants.PlayItem)
		let item = NSPasteboardItem()
		
		item.setString(String(row), forType: "public.data")
		
		return item
	}

	func tableView(tableView: NSTableView, writeRowsWith rowIndexes: NSIndexSet, to pboard: NSPasteboard) -> Bool {
		print("writeRowsWith \(pboard)")
//		let type = (tableView == playlistTableView ? Constants.PlayList : Constants.PlayItem)
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
						
						//	if it's a video file, get and set window content size to its dimentions
						let track0 = AVURLAsset(URL:fileURL!, options:nil).tracks[0]
						if track0.mediaType != AVMediaTypeVideo
						{
//							print("validate nonAV -> .None")
							return .None
						}
						
//						let path = fileURL!.absoluteString.stringByRemovingPercentEncoding
//						print("validate file \(path)")
					} else {
						print("validate item -> \(item)")
					}
				}
			}
//			print("validate Above -> .Move")
			return .Move
		}
//		print("validate other -> .None")
		return .None
	}
	
	func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
		let pasteboard = info.draggingPasteboard()
		let options = [NSPasteboardURLReadingFileURLsOnlyKey : true,
		               NSPasteboardURLReadingContentsConformToTypesKey : [kUTTypeMovie as String]]
		var oldIndexes = [Int]()
		var items : [AnyObject]
		var oldIndexOffset = 0
		var newIndexOffset = 0

		tableView.beginUpdates()

		//	we have intra tableView drag-n-drop ?
		info.enumerateDraggingItemsWithOptions([], forView: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) {
			if let str = ($0.0.item as! NSPasteboardItem).stringForType("public.data"), index = Int(str) {
				oldIndexes.append(index)
			}
			// For simplicity, the code below uses `tableView.moveRowAtIndex` to move rows around directly.
			// You may want to move rows in your content array and then call `tableView.reloadData()` instead.
			
			for oldIndex in oldIndexes {
				if oldIndex < row {
					tableView.moveRowAtIndex(oldIndex + oldIndexOffset, toIndex: row - 1)
					oldIndexOffset -= 1
				} else {
					tableView.moveRowAtIndex(oldIndex, toIndex: row + newIndexOffset)
					newIndexOffset += 1
				}
			}
			
			//	For playlist items renumber the rank
			if tableView == self.playitemTableView {
				var rank = 1
				
				for item in self.playitemArrayController.arrangedObjects as! [AnyObject] {
					print("item.rank \(item.rank) -> \(rank)")
					item.setValue(rank, forKey: "rank")
					rank += 1;
				}
			}
		}
		
		//	We have a Finder drag-n-drop of file URLs ?
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
					let item = PlayItem(name:itemURL.lastPathComponent.stringByRemovingPercentEncoding!,
					                    link:NSURL.init(string: path)!,
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
			
		tableView.endUpdates()

		return true
	}
	
}
