//
//  ItemListViewController.swift
//  ToDude
//
//  Created by A&A on 2020-03-02.
//  Copyright © 2020 Albert Kozak. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit

class ItemListViewController: UITableViewController {
  var items = [Item]()
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
  @IBAction func addItemButtonTapped(_ sender: UIBarButtonItem) {
    // we need this in order to access the text field data outside of the 'addTextField' scope below
      var tempTextField = UITextField()
      
      // create a UIAlertController object
      let alertController = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
      
      // create a UIAlertAction object
      let alertAction = UIAlertAction(title: "Done", style: .default) { (action) in
        // create a new item from our Item core data entity (we pass it the context)
        let newItem = Item(context: self.context)
        
        // if the text field text is not nil
        if let text = tempTextField.text {
          // set the item attributes
          newItem.title = text
          newItem.completed = false
          
          // append the item to our items array
          self.items.append(newItem)
          
          // call our saveItems() method which saves our context and reloads the table
          self.saveItems()
        }
      }
      
      alertController.addTextField { (textField) in
        textField.placeholder = "Title"
        tempTextField = textField
      }
      
      // Add the action we created above to our alert controller
      alertController.addAction(alertAction)
      // show our alert on screen
      present(alertController, animated: true, completion: nil)
    }

    func saveItems() {
      // wrap our try statement below in a do/catch block so we can handle any errors
      do {
        // save our context
        try context.save()
      } catch {
        print("Error saving context \(error)")
      }
      
      // reload our table to reflect any changes
      tableView.reloadData()
  }
  
  func loadItems() {
    // create a new fetch request of type NSFetchRequest<Item> - you must provide a type
    let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
    
    // wrap our try statement below in a do/catch block so we can handle any errors
    do {
      // fetch our items using our fetch request, save them in our items array
      items = try context.fetch(fetchRequest)
    } catch {
      print("Error fetching items: \(error)")
    }
    
    // reload our table to reflect any changes
    tableView.reloadData()
  }
  
  override func viewDidLoad() {
         super.viewDidLoad()
         loadItems()
         tableView.rowHeight = 85.0
     }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! SwipeTableViewCell
      cell.delegate = self as? SwipeTableViewCellDelegate
      
      let item = items[indexPath.row]
      
      cell.textLabel?.text = item.title
      cell.accessoryType = item.completed ? .checkmark : .none
      
      return cell
    }
  
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let item = items[indexPath.row]
      item.completed = !item.completed
      saveItems()
    }
}

// MARK: Search Bar Methods
extension ItemListViewController: UISearchBarDelegate {

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    // if our search text is nil we should not execute any more code and just return
    guard let searchText = searchBar.text else { return }
    searchItems(searchText: searchText)
  }

  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.count > 0 {
      searchItems(searchText: searchText)
    } else if searchText.count == 0 {
      // show the full list of items
      loadItems()
    }
  }

  // this method's use is restricted to this file
  fileprivate func searchItems(searchText: String) {
    // our fetch request for items
    let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
    
    // a predicate allows us to create a filter or mapping for our items
    // [c] means ignore case
    let predicate = NSPredicate(format: "title CONTAINS[c] %@", searchText)
    
    // the sort descriptor allows us to tell the request how we want our data sorted
    let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
    
    // set the predicate and sort descriptors for on the request
    fetchRequest.predicate = predicate
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    // retrieve the items with the request we created
    do {
      items = try context.fetch(fetchRequest)
    } catch {
      print("Error fetching items: \(error)")
    }
    
    // reload our table with our new data
    tableView.reloadData()
  }
}
