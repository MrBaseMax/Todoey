//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
//import CoreData
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
	
	@IBOutlet weak var searchBar: UISearchBar!
	
	
	let realm = try! Realm()
	
	var todoItems: Results<Item>?
	var selectedCat: Category? {
		didSet {
			loadItems()
		}
	}
	
	
	//    var defaults = UserDefaults.standard
	
	//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
	
	//	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	
	
	//MARK: - lifecycle methods
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//        if let item = defaults.array(forKey: "TodoListArray") as? [Item]{
		//            itemArray = item
		//        }
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		 
		if let selectedCat = selectedCat {
			if let color = UIColor(hexString: selectedCat.color) {
				let contrastColor = ContrastColorOf(color, returnFlat: true)
				if let navBar = navigationController?.navigationBar {
					navBar.backgroundColor = color
					navBar.tintColor = contrastColor
					navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:contrastColor]
				}
				
				searchBar.barTintColor = color
				searchBar.searchTextField.backgroundColor = .white
			}
			title = selectedCat.name
		}
	}
	
	
	
	
	//MARK: - TableView Datasource Methods
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return todoItems?.count ?? 1
	}
	  
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		
		if let item = todoItems?[indexPath.row] {
			cell.textLabel?.text = item.title
			cell.accessoryType = item.done ? .checkmark : .none
			if let color = UIColor(hexString: selectedCat!.color)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoItems!.count) ){
				cell.backgroundColor = color
				cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
			}
		} else {
			cell.textLabel?.text = "No items added"
		}
		
		
		return cell
	}
	
	
	
	//MARK: - TableView Delegate Methods
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if let item = todoItems?[indexPath.row] {
			do {
				//			try context.save()
				try realm.write {
					item.done = !item.done
				}
			} catch {
				print(error)
			}
		}
		
		tableView.reloadData()
		
		//		let item = itemArray[indexPath.row]
		//
		//		//        context.delete(item)
		//		//        itemArray.remove(at: indexPath.row)
		//
		//
		//		item.done = !item.done
		//
		//		saveItems()
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	
	
	
	//MARK: - Add New Items
	@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
		let alert = UIAlertController(title: "Add New Todoey", message: "", preferredStyle: .alert)
		var textField = UITextField()
		
		
		let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
			//        то, что должно происходить при нажатии на кнопку Add Item
			//            print(textField.text!)
			
			//			let newItem = Item(context: self.context)
			//			newItem.title = textField.text!
			//			newItem.parentCategory = self.selectedCat
			//			newItem.done = false
			//
			//			self.itemArray.append(newItem)
			//			self.saveItems()
			
			if let currentCat = self.selectedCat {
				let newItem = Item()
				newItem.title = textField.text!
				newItem.dateCreated = Date()
				
				do {
					//			try context.save()
					try self.realm.write {
						currentCat.items.append(newItem)
						self.realm.add(newItem)
					}
				} catch {
					print(error)
				}
			}
			
			
			self.tableView.reloadData()
			
		}
		
		alert.addTextField { (alertTextField) in
			alertTextField.placeholder = "Type here"
			textField = alertTextField
		}
		
		alert.addAction(action)
		present(alert, animated: true, completion: nil)
		
	}
	
	
	
	//MARK: - Data Manipulation Methods
	//	func saveItems() {
	//
	//		do {
	//			try context.save()
	//		} catch {
	//			print(error)
	//		}
	//
	//		self.tableView.reloadData()
	//	}
	
	
	
	//	func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil ){
	func loadItems(){
		
		todoItems = selectedCat?.items.sorted(byKeyPath: "title", ascending: true)
		//		let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCat!.name! )
		//
		//
		//		if let additionalPredicate = predicate {
		//			request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
		//
		//		} else {
		//			request.predicate = categoryPredicate
		//		}
		//
		//		do {
		//			itemArray = try context.fetch(request)
		//		} catch {
		//			print(error)
		//		}
		
		self.tableView.reloadData()
		
		//        if let data = try? Data(contentsOf: dataFilePath!){
		//            let decoder = PropertyListDecoder()
		//            do {
		//                itemArray = try decoder.decode([Item].self, from: data)
		//            } catch  {
		//                print(error)
		//            }
		//        }
	}
	
	override func updateModel(at indexPath: IndexPath) {
		
		if let item = todoItems?[indexPath.row] {
			do {
				//			try context.save()
				try realm.write {
					self.realm.delete(item)
				}
			} catch {
				print(error)
			}
		}
		
	}
}




//MARK: - searchBar methods
extension TodoListViewController: UISearchBarDelegate {
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		
		todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
		tableView.reloadData()
		
		//			let request: NSFetchRequest<Item> = Item.fetchRequest()
		//			request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
		//
		//			loadItems(with: request, predicate: NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!) )
	}
	
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchBar.text?.count == 0 {
			loadItems()
			DispatchQueue.main.async {
				searchBar.resignFirstResponder()
			}
			
		}
	}
}
