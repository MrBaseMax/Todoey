//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Макс on 07.04.2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//


import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		 
		tableView.rowHeight = 50
		tableView.separatorStyle = .none
	} 
	 
	
	
	//MARK: - TableView Datasource Methods
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
		
		//		cell.accessoryType = item.done ? .checkmark : .none
		
		cell.delegate = self
		return cell
	}
	
	
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
		guard orientation == .right else { return nil }
		
		let deleteAction = SwipeAction(style: .destructive, title: nil) { action, indexPath in
			// handle action by updating model with deletion
			
			self.updateModel(at: indexPath)
		}
		
		// customize the action appearance
		deleteAction.image = UIImage(named: "delete-icon")
		
		return [deleteAction]
	}
	 
	
	func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
		var options = SwipeOptions()
		options.expansionStyle = .destructive
		return options
	}
	
	func updateModel(at indexPath: IndexPath){
		
	}
	
}