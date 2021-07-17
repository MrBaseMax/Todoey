//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Макс on 04.04.2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
//import CoreData
import RealmSwift
import ChameleonFramework


class CategoryViewController: SwipeTableViewController {
	
	let realm = try! Realm()
	var categories: Results<Category>? // какого-то хрена всегда существует
	
	//	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	
	//MARK: - lifecycle methods
	override func viewDidLoad() {
		super.viewDidLoad()
		
		loadCats()
	}
	 
	 
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if let navBar = navigationController?.navigationBar {
			let color:UIColor = .systemBlue
			let contrastColor = ContrastColorOf(color, returnFlat: true)
			navBar.backgroundColor = color
			navBar.tintColor = contrastColor
			navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:contrastColor]
		}
	}
	
	
	//MARK: - TableView Datasource Methods
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let count = categories!.count

		return count // == 0 ? 1 : count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		  
		 
		let cats = categories!
		
		if cats.count > 0 {
			let cat = cats[indexPath.row]
			cell.textLabel?.text = cat.name
			
			if cat.color == "" {
				cat.color = UIColor.randomFlat().hexValue()
			}
			cell.backgroundColor = UIColor(hexString: cat.color)
			
		} else { // чтобы заработал этот кейс, в numberOfRowsInSection надо возвращать 1 при пустом списке категорий, но это вызывает ошибку при удалении последней категории, тк фреймворк рассчитывает видеть после удаления 0
			cell.textLabel?.text = "No categories added"
			cell.backgroundColor = UIColor(hexString: "D4C171")
		}
		
		cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)

		
		return cell
	}
	
	
	
	//MARK: - TableView Delegate Methods
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "goToItems", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let destinationVC = segue.destination as! TodoListViewController
		
		if let indexPath = tableView.indexPathForSelectedRow {
			destinationVC.selectedCat = categories?[indexPath.row]
		}
	}
	
	
	//MARK: - Data Manipulation Methods
	
	func save(_ category: Category) {
		
		do {
			//			try context.save()
			try realm.write {
				realm.add(category)
			}
		} catch {
			print(error)
		}
		
		tableView.reloadData()
	}
	
	
	
	func loadCats(){
		//	func loadCats(with request: NSFetchRequest<Category> = Category.fetchRequest()){
		
		
		categories = realm.objects(Category.self)
		//		do {
		//			catArray = try context.fetch(request)
		//		} catch {
		//			print(error)
		//		}
		
		self.tableView.reloadData()
	}
	

	override func updateModel(at indexPath: IndexPath) {
		if let category = self.categories?[indexPath.row] {
			do {
				try self.realm.write {
					self.realm.delete(category)
				}
			} catch {
				print(error)
			}
		}
	}
	

	
	//MARK: - Add New Categories
	
	@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
		
		let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
		var textField = UITextField()
		
		
		let action = UIAlertAction(title: "Add", style: .default) { (action) in
			//        то, что должно происходить при нажатии на кнопку Add
			
			let newCat = Category()
			newCat.name = textField.text!
			newCat.color = UIColor.randomFlat().hexValue()
			
			self.save(newCat)
		}
		
		alert.addAction(action)
		
		alert.addTextField { (alertTextField) in
			textField = alertTextField
			textField.placeholder = "Type here"
		}
		
		
		
		present(alert, animated: true, completion: nil)
	}
	
	
}
