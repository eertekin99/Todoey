//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Efe Ertekin on 7.06.2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    var categoryArray: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadCategories()
        
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        guard let navBar = navigationController?.navigationBar else { fatalError("No NAVBAR") }
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor(hexString: "1D9BF6")
        navBar.standardAppearance = navBarAppearance
        navBar.scrollEdgeAppearance = navBarAppearance
        
        
    }
    
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Categories Added"
        cell.backgroundColor = UIColor(hexString: categoryArray?[indexPath.row].colour ?? "1D9BF6")
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
    
    //MARK: - Data Manipulation Methods
    
    func saveCategories(category: Category) {
        do{
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving context, \(error)")
        }
    }
    
    func loadCategories() {
        categoryArray = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { action in
            //what will happen once the user clicks the add item button on our UIAlert
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.colour = UIColor.randomFlat().hexValue()
            
            self.saveCategories(category: newCategory)
            self.tableView.reloadData()
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Deleting Category
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let category = self.categoryArray?[indexPath.row] {
                do {
                    //When you delete the category, you also have to delete all the items that belong to category.
                    //So, this is a basic loop that makes this possible
                    try self.realm.write({
                        for i in stride(from: category.items.count - 1, to: -1, by: -1) {
                            realm.delete(category.items[i])
                        }
                        //After deletion of items, you can delete the category.
                        realm.delete(category)
                    })
                    self.tableView.reloadData()
                } catch {
                    print("Error: \(error)")
                }
            }
        }
    }
    
    
    //MARK: - Updating Category
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let modifyAction = UIContextualAction(style: .normal, title:  "Update", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            var textField = UITextField()
            let alert = UIAlertController(title: "Update Category", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "Change", style: .default) { action in
                
                if let category = self.categoryArray?[indexPath.row] {
                    do {
                        try self.realm.write({
                            category.name = textField.text ?? "NULL"
                        })
                        self.tableView.reloadData()
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
            
            alert.addTextField { alertTextField in
                alertTextField.placeholder = "Change the Category Name"
                textField = alertTextField
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            success(true)
        })
        
        
        modifyAction.image = UIImage(systemName: "hammer.fill")
        modifyAction.backgroundColor = .blue
        return UISwipeActionsConfiguration(actions: [modifyAction])
    }
    
}
