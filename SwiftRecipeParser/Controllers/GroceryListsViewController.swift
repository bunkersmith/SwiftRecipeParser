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
    
    private var databaseInterface:DatabaseInterface!
    private var groceryLists:Array<GroceryList>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        databaseInterface = DatabaseInterface()
        populateGroceryLists()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func populateGroceryLists() {
        groceryLists = databaseInterface.entitiesOfType("GroceryList", predicate:nil) as! Array<GroceryList>
        self.tableView.reloadData()
    }
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        var inputTextField = UITextField()
        if #available(iOS 8.0, *) {
            Utilities.showTextFieldAlert(self, title: "Enter grocery list name", message: "", inputTextField: &inputTextField, startingText: "", keyboardType: .Default, capitalizationType: .Words) { action in
                let groceryListName:String = inputTextField.text!
                
                let newGroceryList:GroceryList = self.databaseInterface.newManagedObjectOfType("GroceryList") as! GroceryList
                newGroceryList.name = groceryListName
                newGroceryList.totalCost = NSNumber(float:0.0)
                
                self.databaseInterface.saveContext();
                GroceryList.setCurrentGroceryList(newGroceryList.name, databaseInterfacePtr:self.databaseInterface)
                
                self.populateGroceryLists()
                self.tableView.reloadData()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    // MARK: - Table view data source

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return groceryLists.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GroceryListsTableCell", forIndexPath: indexPath) 
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

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        GroceryList.setCurrentGroceryList(groceryLists[indexPath.row].name, databaseInterfacePtr: databaseInterface)
        populateGroceryLists()
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the model and data source
            let groceryList:GroceryList = groceryLists[indexPath.row]
            databaseInterface.deleteObject(groceryList)
            groceryLists.removeAtIndex(indexPath.row)
            
            // Delete the row from the table view
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectGroceryListSegue" {
            let detailViewController:GroceryListDetailViewController = segue.destinationViewController as! GroceryListDetailViewController
            let indexPath:NSIndexPath = tableView.indexPathForSelectedRow!
            detailViewController.groceryList = groceryLists[indexPath.row]
        }
    }

}
