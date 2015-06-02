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
        groceryLists = databaseInterface.entitiesOfType("GroceryList", fetchRequestChangeBlock:nil) as! Array<GroceryList>
    }
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        var addListAlert = UIAlertController(title:"Enter grocery list name", message:"", preferredStyle:UIAlertControllerStyle.Alert)
        var inputTextField:UITextField?
        
        addListAlert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.autocapitalizationType = UITextAutocapitalizationType.Words
            inputTextField = textField
        }
        
        addListAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            if inputTextField != nil {
                var groceryListName:String = inputTextField!.text
                
                var newGroceryList:GroceryList = self.databaseInterface.newManagedObjectOfType("GroceryList") as! GroceryList
                newGroceryList.name = groceryListName
                newGroceryList.totalCost = NSNumber(float:0.0)
                
                self.databaseInterface.saveContext();
                GroceryList.setCurrentGroceryList(newGroceryList.name, databaseInterfacePtr:self.databaseInterface)
                
                self.populateGroceryLists()
                self.tableView.reloadData()
            }
        }))
        
        addListAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))

        self.presentViewController(addListAlert, animated:true, completion: nil)
    }
    
    // MARK: - Table view data source

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return groceryLists.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GroceryListsTableCell", forIndexPath: indexPath) as! UITableViewCell
        var groceryList:GroceryList = groceryLists![indexPath.row]
        
        // Configure the cell...
        cell.textLabel?.text = groceryList.name
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the model and data source
            var groceryList:GroceryList = groceryLists[indexPath.row]
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
