//
//  GroceryListDetailViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 6/3/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit
import CoreData

class GroceryListDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddGroceryListItemDelegate, ModifyGroceryListItemDelegate {


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var projectedCostLabel: UILabel!
    @IBOutlet weak var clearAllItemsButton: UIButton!
    
    fileprivate var textFieldBottom: CGFloat = 0.0
    fileprivate var textFieldIndexPath: IndexPath? = nil
    
    var groceryList:GroceryList!

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

        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        navigationItem.title = groceryList.name

        updateCostLabels()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateCostLabels() {
        let totalCost = groceryList.updateAndReturnTotalCost()
        totalCostLabel.text = String(format:"Total Cost: $%.2f", totalCost)
        
        let projectedCost = groceryList.updateAndReturnProjectedCost()
        projectedCostLabel.text = String(format:"Projected Cost: $%.2f", projectedCost)
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
            groceryList.addHasItemsObject(value: groceryListItem)
            updateCostLabels()
        }
    }

    @IBAction func clearAllItemsButtonPressed(_ sender: Any) {
        if #available(iOS 8.0, *) {
            let _ = Utilities.showYesNoAlert(viewController: self, title: "Do you want to clear all the items in this grocery list?", message: "", yesButtonHandler: { action in
                
                self.groceryList.clearAllItems()
                self.updateCostLabels()
                self.totalCostLabel.text = "Total Cost: $0.00"
                self.projectedCostLabel.text = "Projected Cost: $0.00"
                self.tableView.reloadData()
            }, noButtonHandler: nil)
        }
    }
    
    @IBAction func buyItemButtonPressed(_ sender: UIButton!) {
        let buttonPosition:CGPoint = sender.convert(CGPoint(x:0, y:0), to: tableView)
        guard let indexPath  = tableView!.indexPathForRow(at: buttonPosition) else {
            return
        }
        
        guard let itemToBuy:GroceryListItem = groceryList.hasItems[indexPath.row] as? GroceryListItem else { return }
        
        if itemToBuy.isBought.boolValue {
            if #available(iOS 8.0, *) {
                let _ = Utilities.showYesNoAlert(viewController: self, title: "Do you want to return \(itemToBuy.name)?", message: "", yesButtonHandler: { action in
                    
                    (self.groceryList.hasItems[indexPath.row] as! GroceryListItem).isBought = NSNumber(value: false)
                    self.totalCostLabel.text = String(format:"Total Cost: $%.2f", self.groceryList.updateAndReturnTotalCost())
                    
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
                        
                        self.groceryList.buyItem(item: self.groceryList.hasItems[indexPath.row] as! GroceryListItem, quantity: itemToBuy.quantity.floatValue, cost: itemToBuyCost, taxableStatus: itemToBuy.isTaxable.boolValue)
                        
                        self.updateCostLabels()
                        
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
            return
        }
        
        if segue.identifier == "modifyGroceryListItemSegue" {
            let modifyViewController:ModifyGroceryListItemViewController = segue.destination as! ModifyGroceryListItemViewController
            
            guard let selectedRowIndexPath = tableView.indexPathForSelectedRow else {
                return
            }
            
            guard let selectedCell = tableView.cellForRow(at: selectedRowIndexPath) as? GroceryListItemTableViewCell else {
                return
            }
            
            let itemName = selectedCell.returnItemName()
            
            guard let glItem = GroceryListItem.findGroceryListItemWithName(name: itemName) else {
                return
            }
            
            let modStruct = ModGliVCStruct(itemName: itemName,
                                           quantity: glItem.quantity.floatValue,
                                           unitOfMeasure: glItem.unitOfMeasure,
                                           taxable: glItem.isTaxable.boolValue,
                                           indexPath: selectedRowIndexPath)
            modifyViewController.modStruct = modStruct
            
            modifyViewController.delegate = self
        }
    }
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard groceryList != nil else {
            return 0
        }
        return groceryList.hasItems.count
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroceryListItemCell", for: indexPath)
        
        guard let groceryListItemCell = cell as? GroceryListItemTableViewCell else {
            return cell
        }
        
        guard let groceryListItem = groceryList.hasItems[indexPath.row] as? GroceryListItem else {
            return cell
        }
        
        groceryListItemCell.configure(item:groceryListItem)
        
        return groceryListItemCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let itemToPutBack = groceryList.hasItems[indexPath.row] as? GroceryListItem {
                groceryList.removeHasItemsObject(value: itemToPutBack)
                updateCostLabels()

                tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    // MARK: - ModifyGroceryListItemDelegate
    
    func groceryListItemModified(modStruct: ModGliVCStruct) {
        let cell = tableView.cellForRow(at: modStruct.indexPath)
        
        guard let groceryListItemCell = cell as? GroceryListItemTableViewCell else {
            return
        }
        
        guard var groceryListItem = GroceryListItem.findGroceryListItemWithName(name: modStruct.itemName, inListNamed: groceryList.name) else {
            return
        }
        
        groceryListItem = groceryListItem.update(quantity: modStruct.quantity, taxable: modStruct.taxable)
        
        groceryListItemCell.configure(item: groceryListItem)
    }

}
