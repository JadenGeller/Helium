//
//  PlaylistViewController.swift
//  Helium
//
//  Created by Carlos D. Santiago on 2/15/17.
//  Copyright © 2017 Jaden Geller. All rights reserved.
//

import Foundation

class PlayItem : NSObject {
	var name : String = "item"
	var link : NSURL = NSURL.init(string: "http://")!
	var rank = 0
	
	override init() {
		name = "item"
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
	var name : String = "list"
	var list : Array <PlayItem> = Array()
	
	override init() {
		name = "list"
		list = Array <PlayItem> ()
		super.init()
	}

	init(name:String, list:Array <PlayItem>) {
		self.name = name
		self.list = list
		super.init()
	}
}

class PlaylistViewController: NSViewController,NSTableViewDelegate {

	@IBOutlet var playlistArrayController: NSArrayController!
	@IBOutlet var playitemArrayController: NSArrayController!

	@IBOutlet var playlistTableView: NSTableView!
	@IBOutlet var playitemTableView: NSTableView!

	override func viewDidLoad() {
		let registeredTypes:[String] = [NSStringPboardType]
		playlistTableView.registerForDraggedTypes(registeredTypes)
		playitemTableView.registerForDraggedTypes(registeredTypes)

		playlistTableView.registerForDraggedTypes([Constants.PlayList])
		playitemTableView.registerForDraggedTypes([Constants.PlayItem])

		// Initially load playlists data
		if let playData = NSUserDefaults.standardUserDefaults().dataForKey(UserSetting.Playlists.userDefaultsKey) {
			playlists = NSKeyedUnarchiver.unarchiveObjectWithData(playData) as! Array <PlayList>
		}
	}
/*
	func tableView(tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
		let type = (tableView == playlistTableView ? Constants.PlayList : Constants.PlayItem)
		let item = NSPasteboardItem()
		item.setString(String(row), forType: type)

		return item
	}
*/
	func tableView(tableView: NSTableView, writeRowsWith rowIndexes: NSIndexSet, to pboard: NSPasteboard) -> Bool {
		let type = (tableView == playlistTableView ? Constants.PlayList : Constants.PlayItem)
		let data = NSKeyedArchiver.archivedDataWithRootObject(rowIndexes)
		pboard.declareTypes([type], owner: self)
		pboard.setData(data, forType: type)
		
		return true
	}

	func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
		if dropOperation == .Above {
			return .Move
		}
		return .None
	}
	
	func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
		let type = (tableView == playlistTableView ? Constants.PlayList : Constants.PlayItem)
		var oldIndexes = [Int]()
		info.enumerateDraggingItemsWithOptions([], forView: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) {
			if let str = ($0.0.item as! NSPasteboardItem).stringForType(type), index = Int(str) {
				oldIndexes.append(index)
			}
		}
		
		var oldIndexOffset = 0
		var newIndexOffset = 0
		
		// For simplicity, the code below uses `tableView.moveRowAtIndex` to move rows around directly.
		// You may want to move rows in your content array and then call `tableView.reloadData()` instead.
		tableView.beginUpdates()
		for oldIndex in oldIndexes {
			if oldIndex < row {
				tableView.moveRowAtIndex(oldIndex + oldIndexOffset, toIndex: row - 1)
				oldIndexOffset -= 1
			} else {
				tableView.moveRowAtIndex(oldIndex, toIndex: row + newIndexOffset)
				newIndexOffset += 1
			}
		}
		tableView.endUpdates()
		
		return true
	}

	//	cache playlists read and saved to defaults
	dynamic var playlists = [PlayList]()
	
	@IBAction func addPlaylist(sender: NSButton) {
		if let play = playlistArrayController.selectedObjects.first as? PlayList {
			let item = PlayItem(name:"item#",link:NSURL.init(string: "http://")!,rank:play.list.count + 1);
			let temp = NSString(format:"%p",item) as String
			item.name += String(temp.characters.suffix(3))
			playitemArrayController.addObject(item)
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
			playitemArrayController.removeObject(selectedPlayItem)
		}
		else
		if let selectedPlaylist = playlistArrayController.selectedObjects.first as? PlayList {
			playlistArrayController.removeObject(selectedPlaylist)
		}
	}
	
	@IBAction func restorePlaylists(sender: NSButton) {
		if let playData = NSUserDefaults.standardUserDefaults().dataForKey(UserSetting.Playlists.userDefaultsKey) {
			playlists = NSKeyedUnarchiver.unarchiveObjectWithData(playData) as! Array <PlayList>
		}
	}

	@IBAction override func dismissController(sender: AnyObject?) {
		super.dismissController(sender)
		print(sender?.title)
		//	Save or go
		switch sender!.tag == 0 {
			case true:
				let playArray = playlistArrayController.arrangedObjects
				let playData = NSKeyedArchiver.archivedDataWithRootObject(playArray)
				NSUserDefaults.standardUserDefaults().setObject(playData, forKey: UserSetting.Playlists.userDefaultsKey)
				NSUserDefaults.standardUserDefaults().synchronize()
				print("true")
				break
			case false:
				print("false")
		}
	}
	
}
