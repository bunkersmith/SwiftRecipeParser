//
//  GroceryListsViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 6/1/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit
import CoreData

class GroceryListsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    private var groceryLists:Array<GroceryList>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateGroceryLists()
        
        tableView.tableFooterView = UIView(frame: .zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func populateGroceryLists() {
        groceryLists = GroceryList.returnAll()
        self.tableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        var inputTextField = UITextField()
        if #available(iOS 8.0, *) {
            let _ = Utilities.showTextFieldAlert(viewController: self, title: "Enter grocery list name", message: "", startingText: "", keyboardType: .default, capitalizationType: .words, okButtonHandler: { action in
                let groceryListName:String = inputTextField.text!
                
                GroceryList.create(name: groceryListName)
                GroceryList.setCurrentGroceryList(groceryListName: groceryListName)
                
                self.populateGroceryLists()
                self.tableView.reloadData()
            }, completionHandler: { (txtField) in
                inputTextField = txtField
            })
        } else {
            // Fallback on earlier versions
        }
    }
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return groceryLists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroceryListsTableCell", for: indexPath)
        let groceryList:GroceryList = groceryLists![indexPath.row]
        
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
        GroceryList.setCurrentGroceryList(groceryListName: groceryLists[indexPath.row].name)
        populateGroceryLists()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the model and data source
            let groceryList:GroceryList = groceryLists[indexPath.row]
            GroceryList.delete(groceryList:groceryList)
            groceryLists.remove(at: indexPath.row)
            
            // Delete the row from the table view
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectGroceryListSegue" {
            let detailViewController:GroceryListDetailViewController = segue.destination as! GroceryListDetailViewController
            let indexPath:NSIndexPath = tableView.indexPathForSelectedRow! as NSIndexPath
            detailViewController.groceryList = groceryLists[indexPath.row]
        }
    }

}
