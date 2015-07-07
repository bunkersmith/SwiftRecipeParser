//
//  GroceryListDetailViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 6/3/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit
import CoreData

class GroceryListDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, AddGroceryListItemDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalCostLabel: UILabel!
    
    var groceryList:GroceryList!
    
    lazy private var databaseInterface:DatabaseInterface = {
       return DatabaseInterface()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = groceryList.name
        self.totalCostLabel.text = String(format:"Total Cost: $%.2f", self.groceryList.totalCost.floatValue)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func groceryListItemAdded(groceryListItem: GroceryListItem) {
        groceryList.addHasItemsObject(groceryListItem)
        databaseInterface.saveContext()
    }

    @IBAction func clearTotalButtonPressed(sender: AnyObject) {
        self.groceryList.totalCost = NSNumber(float:0.0)
        self.totalCostLabel.text = "Total Cost: $0"
    }
    
    @IBAction func buyItemButtonPressed(sender: AnyObject) {
        var buttonPosition:CGPoint = sender.convertPoint(CGPointZero, toView:self.tableView)
        var indexPath:NSIndexPath?  = self.tableView!.indexPathForRowAtPoint(buttonPosition)
        if (indexPath != nil)
        {
            NSLog("indexPath #1 = %d, %d", indexPath!.section, indexPath!.row)
            
            var itemToBuy:GroceryListItem = self.groceryList.hasItems[indexPath!.row] as! GroceryListItem
            var textField:UITextField = UITextField()
            var buyItemAlert = Utilities.showTextFieldAlert(self, title: "Enter price of \(itemToBuy.name)", message: "", inputTextField: &textField, keyboardType: .DecimalPad, capitalizationType:.None, okButtonHandler: { action in
                self.processOkButton(textField, itemToBuy: itemToBuy)
                NSLog("indexPath #2 = %d, %d", indexPath!.section, indexPath!.row)
                
                var cell = self.tableView.dequeueReusableCellWithIdentifier("GroceryListItemCell", forIndexPath:indexPath!) as! GroceryListItemTableViewCell
                cell.groceryListItemName.textColor = UIColor.redColor()
                self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
            })
        }
    }
    
    func processOkButton(textField: UITextField, itemToBuy: GroceryListItem) {
        if textField.text != "" {
            var itemToBuyCost:Float = (textField.text as NSString).floatValue
            itemToBuy.cost = NSNumber(float:itemToBuyCost)
            
            self.groceryList.totalCost = NSNumber(float:self.groceryList.totalCost.floatValue + itemToBuyCost)
            self.databaseInterface.saveContext()
            
            self.totalCostLabel.text = String(format:"Total Cost: $%.2f", self.groceryList.totalCost.floatValue)
        }
        else {
            Utilities.showOkButtonAlert(self, title: "Please enter a price", message: "", okButtonHandler: nil)
        }
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addGroceryListItemSegue" {
            var addViewController:AddGroceryListItemViewController = segue.destinationViewController as! AddGroceryListItemViewController
            addViewController.delegate = self
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
        let cell = tableView.dequeueReusableCellWithIdentifier("GroceryListItemCell", forIndexPath: indexPath) as! UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            databaseInterface.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! GroceryListItem)
            databaseInterface.saveContext()
            tableView.reloadData()
        }
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let groceryListItemCell = cell as! GroceryListItemTableViewCell
        let groceryListItem = self.fetchedResultsController.objectAtIndexPath(indexPath) as! GroceryListItem
        groceryListItemCell.groceryListItemName.text = groceryListItem.name
    }
    
    // MARK: - Fetched results controller
    

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        return databaseInterface.createFetchedResultsController("GroceryListItem", sortKey: "name", secondarySortKey: nil, sectionNameKeyPath: nil, fetchRequestChangeBlock:{
            inputFetchRequest in
            var predicate:NSPredicate = NSPredicate(format: "ANY inGroceryLists.name matches %@", self.groceryList.name)
            inputFetchRequest.predicate = predicate
            return inputFetchRequest
        })
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
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
    
    /*
    // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
    // In the simplest, most efficient, case, reload the table view.
    self.tableView.reloadData()
    }
    */
    
}
