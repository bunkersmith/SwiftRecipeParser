//
//  GroceryListDetailViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 6/3/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit
import CoreData

class GroceryListDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
                                       AddGroceryListItemDelegate, ModifyGroceryListItemDelegate, GroceryListSelectionDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var projectedCostLabel: UILabel!
    @IBOutlet weak var clearAllItemsButton: UIButton!
    
    fileprivate var textFieldBottom: CGFloat = 0.0
    fileprivate var textFieldIndexPath: IndexPath? = nil
    
    fileprivate var addedGroceryListItem:GroceryListItem? = nil
    fileprivate var addedAndBoughtGroceryListItem:GroceryListItem? = nil

    var groceryList:GroceryList!
    
    var titleViewButton:UIButton!
    
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

        titleViewButton = UIButton(type: .system)
        // Tell the titleViewButton to NOT use its frame for sizing purposes
        titleViewButton.translatesAutoresizingMaskIntoConstraints = false
        titleViewButton.setTitleColor(.black, for: .normal)
        titleViewButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleViewButton.addTarget(self, action: #selector(titleViewTapped(sender:)), for: .touchUpInside)
        navigationItem.titleView = titleViewButton
        
        titleViewButton.centerXAnchor.constraint(equalTo: navigationItem.titleView!.centerXAnchor).isActive = true
        titleViewButton.centerYAnchor.constraint(equalTo: navigationItem.titleView!.centerYAnchor).isActive = true

        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewControllerInit()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewControllerInit() {
        
        tableView.reloadData()
        titleViewButton.setTitle(groceryList.name, for: .normal)
        updateCostLabels()
        
        if addedGroceryListItem != nil {
            processAddedGroceryListItem(groceryListItem: addedGroceryListItem!)
            addedGroceryListItem = nil
        }

        if addedAndBoughtGroceryListItem != nil {
            processAddedAndBoughtGroceryListItem(groceryListItem: addedAndBoughtGroceryListItem!)
            addedAndBoughtGroceryListItem = nil
        }
    }

    @objc func titleViewTapped(sender: Any) {
        showSelectGroceryListViewController(groceryListItem: nil)
    }

    func updateCostLabels() {
        let totalCost = groceryList.updateAndReturnTotalCost()
        totalCostLabel.text = String(format:"Total Cost: $%.2f", totalCost)
        
        groceryList.updateProjectedCost()
        projectedCostLabel.text = "Projected Cost: \(groceryList.projectedCostString())"
    }
    
    func groceryListItemAdded(groceryListItem: GroceryListItem) {
        addedGroceryListItem = groceryListItem
    }

    func groceryListItemAddedAndBought(groceryListItem: GroceryListItem) {
        addedAndBoughtGroceryListItem = groceryListItem
    }

    func processAddedGroceryListItem(groceryListItem: GroceryListItem) {
        if groceryList.hasItems.contains(groceryListItem) {
            AlertUtilities.showOkButtonAlert(self, title: "Error Alert", message: "\(groceryListItem.name) is already on your list", buttonHandler: nil)
        }
        else {
            AlertUtilities.queryItemPrice(viewController: self, itemToBuy: groceryListItem) { (itemQuantity, itemUnits, itemPrice) in
                self.groceryList.addItem(item: groceryListItem,
                                         itemQuantity: itemQuantity,
                                         itemUnits: itemUnits,
                                         itemPrice: itemPrice,
                                         itemNotes: "")
                
                self.updateCostLabels()
                self.tableView.reloadData()
            }
        }
    }

    func processAddedAndBoughtGroceryListItem(groceryListItem: GroceryListItem) {
        if groceryList.hasItems.contains(groceryListItem) {
            AlertUtilities.showOkButtonAlert(self, title: "Error Alert", message: "\(groceryListItem.name) is already on your list", buttonHandler: nil)
        }
        else {
            AlertUtilities.queryItemPrice(viewController: self, itemToBuy: groceryListItem) { (itemQuantity, itemUnits, itemPrice) in
                self.groceryList.addItem(item: groceryListItem,
                                         itemQuantity: itemQuantity,
                                         itemUnits: itemUnits,
                                         itemPrice: itemPrice,
                                         itemNotes: "")
                self.groceryList.buyItem(item: groceryListItem,
                                         quantity: itemQuantity,
                                         units: itemUnits,
                                         cost: itemPrice,
                                         taxableStatus: groceryListItem.isTaxable.boolValue)

                self.updateCostLabels()
                self.tableView.reloadData()
            }
        }
    }

    func removeGroceryListItem(groceryList: GroceryList, groceryListItem: GroceryListItem) {
        groceryList.removeHasItemsObject(value: groceryListItem)
        updateCostLabels()

        tableView.reloadData()
    }
    
    @IBAction func importButtonPressed(_ sender: Any) {
        let pasteboard = UIPasteboard.general
        if #available(iOS 10.0, *) {
            if pasteboard.hasStrings {
                guard let pasteboardString = pasteboard.string else {
                    return
                }
                let lines = pasteboardString.components(separatedBy: CharacterSet.newlines)
                for line in lines {
                    if let groceryListItem = GroceryListItem.parseGroceryListItemString(string: line) {
                        groceryList.addItem(item: groceryListItem,
                                            itemQuantity: groceryListItem.quantity.floatValue,
                                            itemUnits: groceryListItem.unitOfMeasure,
                                            itemPrice: groceryListItem.cost.floatValue,
                                            itemNotes: groceryListItem.notes)
                        print("\(String(describing: groceryListItem))")
                    }
                }
                updateCostLabels()
                tableView.reloadData()
            }
        }
    }
    
    @IBAction func clearAllItemsButtonPressed(_ sender: Any) {
        AlertUtilities.showYesNoAlert(viewController: self, title: "Do you want to clear all the items in this grocery list?", message: "", yesButtonHandler: { action in
            
            self.groceryList.clearAllItems()
            self.updateCostLabels()
            self.totalCostLabel.text = "Total Cost: $0.00"
            self.projectedCostLabel.text = "Projected Cost: $0.00"
            self.tableView.reloadData()
        }, noButtonHandler: nil)
    }
    
    @IBAction func buyItemButtonPressed(_ sender: UIButton!) {
        let buttonPosition:CGPoint = sender.convert(CGPoint(x:0, y:0), to: tableView)
        guard let indexPath  = tableView!.indexPathForRow(at: buttonPosition) else {
            return
        }
        
        guard let itemToBuy:GroceryListItem = groceryList.hasItems[indexPath.row] as? GroceryListItem else {
            return
        }
        
        if itemToBuy.isBought.boolValue {
            AlertUtilities.showYesNoAlert(viewController: self, title: "Do you want to return \(itemToBuy.name)?", message: "", yesButtonHandler: { action in
                
                (self.groceryList.hasItems[indexPath.row] as! GroceryListItem).isBought = NSNumber(value: false)
                self.totalCostLabel.text = String(format:"Total Cost: $%.2f", self.groceryList.updateAndReturnTotalCost())
                
                self.tableView.reloadData()
            }, noButtonHandler: nil)
        }
        else {
            AlertUtilities.queryItemPrice(viewController: self, itemToBuy: itemToBuy) { (itemQuantity, itemUnits, itemPrice) in
                self.groceryList.buyItem(item: itemToBuy,
                                         quantity: itemQuantity,
                                         units: itemUnits,
                                         cost: itemPrice, taxableStatus: itemToBuy.isTaxable.boolValue)
                
                self.updateCostLabels()
                
                self.tableView.reloadData()
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
            
            let glItem = groceryList.hasItems.object(at:selectedRowIndexPath.row) as! GroceryListItem
                            
            modifyViewController.groceryListItem = glItem
            modifyViewController.indexPath = selectedRowIndexPath
                
            modifyViewController.delegate = self
            return
        }
        
        if segue.identifier == "textGroceryListSegue" {
            let textViewController:TextGroceryListViewController = segue.destination as! TextGroceryListViewController
            textViewController.initGroceryListName(groceryListName: groceryList.name)
            textViewController.requestMessageComposeViewController()
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
                removeGroceryListItem(groceryList: groceryList, groceryListItem: itemToPutBack)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func showSelectGroceryListViewController(groceryListItem: GroceryListItem?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "SelectGroceryListViewController") as? SelectGroceryListViewController
        myAlert!.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert!.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        myAlert!.groceryListItem = groceryListItem
        myAlert!.delegate = self
        self.present(myAlert!, animated: true, completion: nil)
    }
    
    @IBAction func tableViewLongPress(sender: UILongPressGestureRecognizer) {

        if sender.state == UIGestureRecognizer.State.began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                guard let groceryListItem = groceryList.hasItems[indexPath.row] as? GroceryListItem else {
                    return
                }

                if groceryListItem.isBought.boolValue {
                    AlertUtilities.showOkButtonAlert(self, title: "Error Alert", message: "You cannot move an item you have already bought", buttonHandler: nil)
                } else {
                    showSelectGroceryListViewController(groceryListItem: groceryListItem)
                }
            }
        }

    }

    // MARK: - ModifyGroceryListItemDelegate
    
    func groceryListItemModified(groceryListItem: GroceryListItem, indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        guard let groceryListItemCell = cell as? GroceryListItemTableViewCell else {
            return
        }
        
        groceryListItemCell.configure(item: groceryListItem)
    }
    
    // MARK: - GroceryListSelectionDelegate
    
    func groceryListSelected(groceryList: GroceryList, groceryListItem: GroceryListItem?) {
        if groceryListItem != nil {
            removeGroceryListItem(groceryList: self.groceryList, groceryListItem: groceryListItem!)
            groceryList.addHasItemsObject(value: groceryListItem!)
        } else {
            self.groceryList = groceryList
            GroceryList.setCurrentGroceryList(groceryListName: groceryList.name)
            viewControllerInit()
        }
    }
}
