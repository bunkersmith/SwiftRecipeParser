//
//  SelectGroceryListViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 4/3/21.
//  Copyright © 2021 CarlSmith. All rights reserved.
//

import UIKit

protocol GroceryListSelectionDelegate: class {
    func groceryListSelected(groceryList: GroceryList, groceryListItem: GroceryListItem?)
}

class SelectGroceryListViewController: UIViewController  {

    @IBOutlet weak var transparentView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: GroceryListSelectionDelegate?
    
    var groceryLists:Array<GroceryList>!
    var groceryListItem: GroceryListItem? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(transparentViewTapped))
        transparentView.addGestureRecognizer(tapRecognizer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if groceryListItem != nil {
            label.text = "Move \(groceryListItem!.name) to list:"
        } else {
            label.text = "Switch to grocery list:"
        }
//        populateGroceryLists()
    }

//    func populateGroceryLists() {
//        groceryLists = GroceryList.returnAllButCurrent()
//        tableView.reloadData()
//    }

    @objc func transparentViewTapped(sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
}

extension SelectGroceryListViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return groceryLists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroceryListTableCell", for: indexPath)
        let groceryList = groceryLists![indexPath.row]
        
        // Configure the cell...
        if groceryList.isCurrent.boolValue {
            cell.textLabel?.text = groceryList.name + "*"
        }
        else {
            cell.textLabel?.text = groceryList.name
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let groceryList = groceryLists![indexPath.row]
        delegate?.groceryListSelected(groceryList: groceryList, groceryListItem: groceryListItem)
        dismiss(animated: true, completion: nil)
    }

}
