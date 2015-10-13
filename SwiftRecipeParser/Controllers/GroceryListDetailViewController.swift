//
//  GroceryListDetailViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 6/3/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit
import CoreData

class GroceryListDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddGroceryListItemDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalCostLabel: UILabel!
    
    var groceryList:GroceryList!
    
    lazy private var databaseInterface:DatabaseInterface = {
       return DatabaseInterface()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = groceryList.name
        totalCostLabel.text = String(format:"Total Cost: $%.2f", groceryList.totalCost.floatValue)
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
        if groceryList.hasItems.containsObject(groceryListItem) {
            Utilities.showOkButtonAlert(self, title: "Error Alert", message: "\(groceryListItem.name) is already on your list", okButtonHandler: nil)
        }
        else {
            groceryList.totalCost = NSNumber(float:groceryList.totalCost.floatValue + groceryListItem.cost.floatValue)
            totalCostLabel.text = String(format:"Total Cost: $%.2f", groceryList.totalCost.floatValue)
            groceryList.addHasItemsObject(groceryListItem)
            databaseInterface.saveContext()
        }
    }

    @IBAction func clearTotalButtonPressed(sender: AnyObject) {
        groceryList.totalCost = NSNumber(float:0.0)
        databaseInterface.saveContext()
        totalCostLabel.text = "Total Cost: $0.00"
    }
    
    @IBAction func buyItemButtonPressed(sender: AnyObject) {
        var buttonPosition:CGPoint = sender.convertPoint(CGPointZero, toView:tableView)
        var indexPath:NSIndexPath?  = tableView!.indexPathForRowAtPoint(buttonPosition)
        if (indexPath != nil)
        {
            var itemToBuy:GroceryListItem = groceryList.hasItems[indexPath!.row] as! GroceryListItem
            if itemToBuy.isBought.boolValue {
                var putBackItemAlert = Utilities.showYesNoAlert(self, title: "Do you want to put back \(itemToBuy.name)?", message: "", yesButtonHandler: { action in
                    itemToBuy.isBought = false;
                    self.groceryList.totalCost = NSNumber(float:self.groceryList.totalCost.floatValue - itemToBuy.cost.floatValue)
                    self.databaseInterface.saveContext()
                    
                    self.totalCostLabel.text = String(format:"Total Cost: $%.2f", self.groceryList.totalCost.floatValue)
                    self.tableView.reloadData()
                })
            }
            else {
                var textField:UITextField = UITextField()
                var startingText = ""
                if (itemToBuy.cost.floatValue > 0.0) {
                    startingText = String(format: "%.2f", itemToBuy.cost.floatValue);
                }
                var buyItemAlert = Utilities.showTextFieldAlert(self, title: "Enter price of \(itemToBuy.name)", message: "", inputTextField: &textField, startingText: startingText, keyboardType: .DecimalPad, capitalizationType:.None, okButtonHandler: { action in
                    if textField.text != "" {
                        var itemToBuyCost:Float = (textField.text as NSString).floatValue
                        itemToBuy.cost = NSNumber(float:itemToBuyCost)
                        itemToBuy.isBought = true
                        
                        self.groceryList.totalCost = NSNumber(float:self.groceryList.totalCost.floatValue + itemToBuyCost)
                        self.databaseInterface.saveContext()
                        
                        self.totalCostLabel.text = String(format:"Total Cost: $%.2f", self.groceryList.totalCost.floatValue)
                        self.tableView.reloadData()
                    }
                    else {
                        Utilities.showOkButtonAlert(self, title: "Please enter a price", message: "", okButtonHandler: nil)
                    }
                })
            }
        }
    }
    
    func processOkButton(textField: UITextField, itemToBuy: GroceryListItem) {
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
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groceryList.hasItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GroceryListItemCell", forIndexPath: indexPath) as! UITableViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if let itemToPutBack = groceryList.hasItems[indexPath.row] as? GroceryListItem {
                groceryList.totalCost = NSNumber(float:groceryList.totalCost.floatValue - itemToPutBack.cost.floatValue)
                totalCostLabel.text = String(format:"Total Cost: $%.2f", groceryList.totalCost.floatValue)
                groceryList.removeHasItemsObject(itemToPutBack)
                databaseInterface.saveContext()
                tableView.reloadData()
            }
        }
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let groceryListItemCell = cell as! GroceryListItemTableViewCell
        let groceryListItem = groceryList.hasItems[indexPath.row] as! GroceryListItem
        groceryListItemCell.groceryListItemName.text = groceryListItem.name
        groceryListItemCell.groceryListItemCost.text = String(format: "%.2f", groceryListItem.cost.floatValue)
        if groceryListItem.isBought.boolValue {
            groceryListItemCell.groceryListItemButton.setTitle("Put Back", forState: .Normal)
            groceryListItemCell.groceryListItemName.textColor = UIColor.redColor()
        }
        else {
            groceryListItemCell.groceryListItemButton.setTitle("Buy", forState: .Normal)
            groceryListItemCell.groceryListItemName.textColor = UIColor.blackColor()
        }
    }
    
}
