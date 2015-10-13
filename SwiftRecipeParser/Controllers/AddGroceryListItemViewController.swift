//
//  AddGroceryListItemViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 6/3/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit
import CoreData

protocol AddGroceryListItemDelegate {
    func groceryListItemAdded(groceryListItem: GroceryListItem)
}

class AddGroceryListItemViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    var delegate:AddGroceryListItemDelegate?
    var fetchedResultsController:NSFetchedResultsController!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    lazy private var databaseInterface:DatabaseInterface = {
        return DatabaseInterface()
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.becomeFirstResponder()
        nameTextField.addTarget(self, action: "textFieldChanged:", forControlEvents: .EditingChanged)
        
        createFetchedResultsController(nil)
    }

    func createFetchedResultsController(predicate: NSPredicate?) {
        fetchedResultsController = databaseInterface.createFetchedResultsController("GroceryListItem", sortKey: "name", secondarySortKey: nil, sectionNameKeyPath: nil, predicate: predicate)
            if fetchedResultsController != nil {
            fetchedResultsController.delegate = self
            tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addItemButtonPressed(sender: AnyObject) {
        var nameTextFieldText = nameTextField.text
        if nameTextFieldText == "" {
            Utilities.showOkButtonAlert(self, title: "Error alert", message:"Name is a required field", okButtonHandler: nil)
        }
        else {
            if let existingItem = GroceryListItem.findGroceryListItemWithName(nameTextFieldText) {
                delegate?.groceryListItemAdded(existingItem)
            }
            else {
                if let groceryListItem:GroceryListItem = databaseInterface.newManagedObjectOfType("GroceryListItem") as? GroceryListItem {
                    groceryListItem.name = nameTextFieldText
                    groceryListItem.isBought = false
                    delegate?.groceryListItemAdded(groceryListItem)
                }
            }
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AddGroceryListItemCell", forIndexPath: indexPath) as! UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if let groceryListItem = self.fetchedResultsController.objectAtIndexPath(indexPath) as? GroceryListItem {
                databaseInterface.deleteObject(groceryListItem)
                tableView.reloadData()
            }
        }
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        if let groceryListItem = self.fetchedResultsController.objectAtIndexPath(indexPath) as? GroceryListItem {
            if let groceryListItemCell = cell as? AddGroceryListItemTableViewCell {
                groceryListItemCell.nameLabel.text = groceryListItem.name
                if groceryListItem.cost.floatValue > 0.0 {
                    groceryListItemCell.costLabel.text = String(format: "%.2f", groceryListItem.cost.floatValue)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let groceryListItem = self.fetchedResultsController.objectAtIndexPath(indexPath) as? GroceryListItem {
            nameTextField.text = groceryListItem.name
        }
    }
    
    // MARK: - Fetched results controller
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    func textFieldChanged(textField: UITextField) {
        createFetchedResultsController(NSPredicate(format: "name contains[cd] %@", textField.text))
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
