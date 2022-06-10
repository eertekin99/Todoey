//
//  ViewController.swift
//  Todoey


import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: UITableViewController {
    
    let realm = try! Realm()
    var todoItems: Results<Item>?
    
    var selectedCategory: Category? {
        didSet{
            navigationItem.title = "\(selectedCategory?.name ?? "NULL")"
            loadItems()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.rowHeight = 60.0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colourHex = selectedCategory?.colour {
            
            guard let navBar = navigationController?.navigationBar else { fatalError("No NAVBAR") }
            
//            navBar.barTintColor = UIColor(hexString: colourHex)
//            navBar.backgroundColor = UIColor(hexString: colourHex)
//            navBar.tintColor = UIColor(hexString: "ffffff")
            
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.backgroundColor = UIColor(hexString: colourHex)
            navBar.standardAppearance = navBarAppearance
            navBar.scrollEdgeAppearance = navBarAppearance
            
        }
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            
            cell.textLabel?.text = item.title
            
            let selectedColour = UIColor(hexString: selectedCategory?.colour ?? "1D9BF6")
            
            if let colour = selectedColour!.darken(byPercentage: CGFloat(Float(indexPath.row) / Float((todoItems?.count ?? 1)))) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try self.realm.write({
                    item.done = !item.done
                })
            } catch {
                print("Error: \(error)")
            }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            //what will happen once the user clicks the add item button on our UIAlert
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error: \(error)")
                }
            }
            
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Deleting Item
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            if let item = self.todoItems?[indexPath.row] {
                do {
                    try self.realm.write({
                        realm.delete(item)
                    })
                    self.tableView.reloadData()
                } catch {
                    print("Error: \(error)")
                }
            }
            
        }
    }
    
    //MARK: - Updating Item
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let modifyAction = UIContextualAction(style: .normal, title:  "Update", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            var textField = UITextField()
            let alert = UIAlertController(title: "Update Item", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "Change", style: .default) { action in
                
                if let item = self.todoItems?[indexPath.row] {
                    do {
                        try self.realm.write({
                            item.title = textField.text ?? "NULL"
                        })
                        self.tableView.reloadData()
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
            
            alert.addTextField { alertTextField in
                alertTextField.placeholder = "Change the Title of Item"
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
    
    
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
    }
}


//MARK: - Search Bar Methods

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
        
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            //Backspace case.. It needs all the data to filter. Otherwise, it tries to work on previously filtered data.
            loadItems()
            todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        }
        tableView.reloadData()
    }
}
