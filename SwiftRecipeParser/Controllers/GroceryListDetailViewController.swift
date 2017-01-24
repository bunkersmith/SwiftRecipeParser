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
    @IBOutlet weak var projectedCostLabel: UILabel!
    
    var groceryList:GroceryList!
    
    lazy private var databaseInterface:DatabaseInterface = {
       return DatabaseInterface()
    }()
    
    override func encodeRestorableState(with aCoder: NSCoder) {
        super.encodeRestorableState(with: aCoder)
        aCoder.encode(groceryList.name, forKey: "groceryListName")
    }
    
    override func decodeRestorableState(with aDecoder: NSCoder) {
        super.decodeRestorableState(with: aDecoder)
        guard let groceryListName = aDecoder.decodeObject(forKey: "groceryListName") as? String else { return }
        groceryList = GroceryList.returnGroceryListWithName(name: groceryListName)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        navigationItem.title = groceryList.name
        totalCostLabel.text = String(format:"Total Cost: $%.2f", groceryList.totalCost.floatValue)
        projectedCostLabel.text = String(format:"Projected Cost: $%.2f", groceryList.updateProjectedCost())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func groceryListItemAdded(groceryListItem: GroceryListItem) {
        if groceryList.hasItems.contains(groceryListItem) {
            if #available(iOS 8.0, *) {
                let _ = Utilities.showOkButtonAlert(viewController: self, title: "Error Alert", message: "\(groceryListItem.name) is already on your list", okButtonHandler: nil)
            } else {
                // Fallback on earlier versions
            }
        }
        else {
            totalCostLabel.text = String(format:"Total Cost: $%.2f", groceryList.totalCost.floatValue)
            projectedCostLabel.text = String(format:"Projected Cost: $%.2f", groceryList.updateProjectedCost())
            groceryList.addHasItemsObject(value: groceryListItem)
            databaseInterface.saveContext()
        }
    }

    @IBAction func clearTotalButtonPressed(_ sender: Any) {
        groceryList.totalCost = NSNumber(value:0.0)
        databaseInterface.saveContext()
        totalCostLabel.text = "Total Cost: $0.00"
    }
    
    @IBAction func clearAllItemsButtonPressed(_ sender: Any) {
        if #available(iOS 8.0, *) {
            let _ = Utilities.showYesNoAlert(viewController: self, title: "Do you want to clear all the items in this grocery list?", message: "", yesButtonHandler: { action in
                self.groceryList.hasItems.enumerateObjects({ (groceryListObject, idx, stop) -> Void in
                    let groceryListItem = groceryListObject as! GroceryListItem
                    if groceryListItem.isBought.boolValue {
                        self.groceryList.totalCost = NSNumber(value:self.groceryList.totalCost.floatValue - groceryListItem.cost.floatValue)
                        groceryListItem.isBought = NSNumber(value: false)
                        self.databaseInterface.saveContext()
                    }
                })
                self.groceryList.removeAllHasItemsObjects()
                self.databaseInterface.saveContext()
                self.totalCostLabel.text = "Total Cost: $0.00"
                self.projectedCostLabel.text = String(format:"Projected Cost: $%.2f", self.groceryList.updateProjectedCost())
                self.tableView.reloadData()
            }, noButtonHandler: nil)
        }
    }
    
    @IBAction func buyItemButtonPressed(_ sender: UIButton!) {
        let buttonPosition:CGPoint = sender.convert(CGPoint(x:0, y:0), to: tableView)
        let indexPath:NSIndexPath?  = tableView!.indexPathForRow(at: buttonPosition) as NSIndexPath?
        guard indexPath != nil else { return }
        
        guard let itemToBuy:GroceryListItem = groceryList.hasItems[indexPath!.row] as? GroceryListItem else { return }
        
        if itemToBuy.isBought.boolValue {
            if #available(iOS 8.0, *) {
                let _ = Utilities.showYesNoAlert(viewController: self, title: "Do you want to put back \(itemToBuy.name)?", message: "", yesButtonHandler: { action in
                    (self.groceryList.hasItems[indexPath!.row] as! GroceryListItem).isBought = NSNumber(value: false)
                    self.groceryList.totalCost = NSNumber(value:self.groceryList.totalCost.floatValue - itemToBuy.cost.floatValue)
                    self.databaseInterface.saveContext()
                    
                    self.totalCostLabel.text = String(format:"Total Cost: $%.2f", self.groceryList.totalCost.floatValue)
                    self.tableView.reloadData()
                }, noButtonHandler: nil)
            } else {
                // Fallback on earlier versions
            }
        }
        else {
            var textField:UITextField = UITextField()
            var startingText = ""
            if (itemToBuy.cost.floatValue > 0.0) {
                startingText = String(format: "%.2f", itemToBuy.cost.floatValue);
            }
            if #available(iOS 8.0, *) {
                let _ = Utilities.showTextFieldAlert(viewController: self, title: "Enter price of \(itemToBuy.name)", message: "", startingText: startingText, keyboardType: .decimalPad, capitalizationType:.none, okButtonHandler: { action in
                    if textField.text != "" {
                        let itemToBuyCost:Float = (textField.text as NSString!).floatValue
                        (self.groceryList.hasItems[indexPath!.row] as! GroceryListItem).cost = NSNumber(value:itemToBuyCost)
                        (self.groceryList.hasItems[indexPath!.row] as! GroceryListItem).isBought = NSNumber(value: true)
                        
                        self.groceryList.totalCost = NSNumber(value:self.groceryList.totalCost.floatValue + itemToBuyCost)
                        self.projectedCostLabel.text = String(format:"Projected Cost: $%.2f", self.groceryList.updateProjectedCost())
                        self.databaseInterface.saveContext()
                        
                        self.totalCostLabel.text = String(format:"Total Cost: $%.2f", self.groceryList.totalCost.floatValue)
                        self.tableView.reloadData()
                    }
                    else {
                        let _ = Utilities.showOkButtonAlert(viewController: self, title: "Please enter a price", message: "", okButtonHandler: nil)
                    }
                }, completionHandler: { (txtField) in
                    textField = txtField
                })
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addGroceryListItemSegue" {
            let addViewController:AddGroceryListItemViewController = segue.destination as! AddGroceryListItemViewController
            addViewController.delegate = self
        }
    }
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard groceryList != nil else { return 0 }
        return groceryList.hasItems.count
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroceryListItemCell", for: indexPath) 
        configureCell(cell: cell, atIndexPath: indexPath as NSIndexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let itemToPutBack = groceryList.hasItems[indexPath.row] as? GroceryListItem {
                if itemToPutBack.isBought.boolValue {
                    groceryList.totalCost = NSNumber(value:groceryList.totalCost.floatValue - itemToPutBack.cost.floatValue)
                    totalCostLabel.text = String(format:"Total Cost: $%.2f", groceryList.totalCost.floatValue)
                }
                groceryList.removeHasItemsObject(value: itemToPutBack)
                projectedCostLabel.text = String(format:"Projected Cost: $%.2f", groceryList.updateProjectedCost())
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
            groceryListItemCell.groceryListItemButton.setTitle("Put Back", for: .normal)
            groceryListItemCell.groceryListItemName.textColor = UIColor.red
        }
        else {
            groceryListItemCell.groceryListItemButton.setTitle("Buy", for: .normal)
            groceryListItemCell.groceryListItemName.textColor = UIColor.black
        }
    }
    
}
