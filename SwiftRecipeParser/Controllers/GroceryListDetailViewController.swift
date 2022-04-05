//
//  GroceryListDetailViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 6/3/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit
import CoreData

class GroceryListDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate,
                                       AddGroceryListItemDelegate, ModifyGroceryListItemDelegate, GroceryListSelectionDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var projectedCostLabel: UILabel!
    @IBOutlet weak var boughtSwitch: UISwitch!
    @IBOutlet weak var clearAllItemsButton: UIButton!
    
    fileprivate var textFieldBottom: CGFloat = 0.0
    fileprivate var textFieldIndexPath: IndexPath? = nil
    
    fileprivate var addedGroceryListItem:GroceryListItem? = nil
    fileprivate var addedAndBoughtGroceryListItem:GroceryListItem? = nil

    var groceryList:GroceryList!
    lazy private var databaseInterface:DatabaseInterface = {
        return DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        }()
    
    var fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>!

    var titleViewButton:UIButton!
    
//    var itemToDelete: GroceryListItem? = nil
    
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.tabBar.isHidden = true
        
        viewControllerInit()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        fetchedResultsController = nil
        
        if self.isMovingFromParentViewController {
            tabBarController?.tabBar.isHidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewControllerInit() {

        createFetchedResultsController(onlyUnbought: !boughtSwitch.isOn)

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

    func createFetchedResultsController(onlyUnbought: Bool) {

        let formatString = onlyUnbought ? "inGroceryList.name MATCHES %@ AND isBought == NO" : "inGroceryList.name MATCHES %@"
        
        var predicate: NSPredicate? = nil
        if groceryList != nil {
            predicate = NSPredicate(format: formatString, groceryList.name)
        }
        
        fetchedResultsController = databaseInterface.createFetchedResultsController(entityName: "GroceryListItem", sortKey: "listPosition", secondarySortKey: nil, sectionNameKeyPath: nil, predicate: predicate)
        
        if fetchedResultsController != nil {
            fetchedResultsController.delegate = self
            tableView.reloadData()
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
                                         taxableStatus: groceryListItem.isTaxable.boolValue,
                                         writeToIcloudNeeded: false)

                self.updateCostLabels()
                self.tableView.reloadData()
            }
        }
    }

    func removeGroceryListItem(groceryList: GroceryList, groceryListItem: GroceryListItem) {
        groceryList.removeHasItemsObject(value: groceryListItem)
        tableView.reloadData()

        updateCostLabels()
    }
    
    @IBAction func textButtonPressed(_ sender: Any) {
        if groceryList.unboughtItems(databaseInterface: databaseInterface).count > 0 {
            performSegue(withIdentifier: "textGroceryListSegue", sender: self)
        } else {
            AlertUtilities.showOkButtonAlert(self, title: "Error Alert", message: "No unbought items to text.", buttonHandler: nil)
        }
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {

        let attrs = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.black]
        let str = NSAttributedString(string: groceryList.stringForPrinting(), attributes: attrs)
        let print = UISimpleTextPrintFormatter(attributedText: str)

        let vc = UIActivityViewController(activityItems: [print], applicationActivities: nil)
        vc.excludedActivityTypes = [.openInIBooks]
        if #available(iOS 11.0, *) {
            vc.excludedActivityTypes?.append(.markupAsPDF)
        }
        present(vc, animated: true)
    }
    
    @IBAction func clearAllItemsButtonPressed(_ sender: Any) {
        AlertUtilities.showThreeButtonAlert(self,
                                            title: "Which items do you want to clear?",
                                            message: "",
                                            buttonTitle1: "All",
                                            buttonHandler1: { action in
                                                self.groceryList.clearAllItems()
                                                self.updateCostLabels()
                                                self.totalCostLabel.text = "Total Cost: $0.00"
                                                self.projectedCostLabel.text = "Projected Cost: $0.00"
                                                self.createFetchedResultsController(onlyUnbought: false)
                                            },
                                            buttonTitle2: "Bought",
                                            buttonHandler2: { action in
                                                self.fetchedResultsController = nil
                                                self.groceryList.clearBoughtItems()
                                                self.updateCostLabels()
                                                self.createFetchedResultsController(onlyUnbought: false)
                                            },
                                            buttonTitle3: "Cancel",
                                            buttonHandler3: nil)
    }
    
    @IBAction func buyItemButtonPressed(_ sender: UIButton!) {
        let buttonPosition:CGPoint = sender.convert(CGPoint(x:0, y:0), to: tableView)
        guard let indexPath  = tableView!.indexPathForRow(at: buttonPosition) else {
            return
        }
        
        guard let itemToBuy = self.fetchedResultsController.object(at: indexPath) as? GroceryListItem else {
            return
        }
        
        if itemToBuy.isBought.boolValue {
            AlertUtilities.showYesNoAlert(viewController: self, title: "Do you want to return \(itemToBuy.name)?", message: "", yesButtonHandler: { action in
                itemToBuy.isBought = NSNumber(value: false)
                self.databaseInterface.saveContext()
                self.totalCostLabel.text = String(format:"Total Cost: $%.2f", self.groceryList.updateAndReturnTotalCost())
                
                self.tableView.reloadData()
            }, noButtonHandler: nil)
        }
        else {
            AlertUtilities.queryItemPrice(viewController: self, itemToBuy: itemToBuy) { (itemQuantity, itemUnits, itemPrice) in
                self.groceryList.buyItem(item: itemToBuy,
                                         quantity: itemQuantity,
                                         units: itemUnits,
                                         cost: itemPrice,
                                         taxableStatus: itemToBuy.isTaxable.boolValue,
                                         writeToIcloudNeeded: true)
                
                self.updateCostLabels()

                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func boughtSwitchValueChanged(_ sender: UISwitch) {
        // Switch false, show only unbought
        // Switch true, show all
        createFetchedResultsController(onlyUnbought: !sender.isOn)
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
            
            guard let groceryListItem = self.fetchedResultsController.object(at: selectedRowIndexPath) as? GroceryListItem else {
                return
            }
                            
            modifyViewController.groceryListItem = groceryListItem
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
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let fetchedResultsController = fetchedResultsController else {
            return 0
        }
        guard let sectionInfo = fetchedResultsController.sections else {
            return 0
        }
//              Logger.logDetails(msg: "Returning \(sectionInfo.numberOfObjects) for section \(section)")
        return sectionInfo[section].numberOfObjects
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroceryListItemCell", for: indexPath)
        self.configureCell(cell: cell, atIndexPath: indexPath)
/*
        if let groceryListItemCell = cell as? AddGroceryListItemTableViewCell {
            print("Name is '\(groceryListItemCell.nameLabel.text ?? "none")' for row at indexPath \(indexPath)")
        }
*/
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let itemToDelete = self.fetchedResultsController.object(at: indexPath) as? GroceryListItem {
//                self.itemToDelete = itemToDelete
                removeGroceryListItem(groceryList: groceryList, groceryListItem: itemToDelete)
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

    func showSelectGroceryListViewController(groceryListItem: GroceryListItem?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let selectGroceryListViewController = storyboard.instantiateViewController(withIdentifier: "SelectGroceryListViewController") as? SelectGroceryListViewController
        selectGroceryListViewController!.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        selectGroceryListViewController!.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        selectGroceryListViewController!.groceryLists = GroceryList.returnAllButCurrent()
        if groceryListItem != nil {
            selectGroceryListViewController!.listTitle = "Move \(groceryListItem!.name) to list:"
        } else {
            selectGroceryListViewController!.listTitle = "Switch to grocery list:"
        }
        selectGroceryListViewController!.groceryListItem = groceryListItem
        selectGroceryListViewController!.delegate = self
        self.present(selectGroceryListViewController!, animated: true, completion: nil)
    }
    
    @IBAction func tableViewLongPress(sender: UILongPressGestureRecognizer) {

        if sender.state == UIGestureRecognizer.State.began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                guard let groceryListItem = self.fetchedResultsController.object(at: indexPath) as? GroceryListItem else {
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
    
    // MARK: - Fetched results controller
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            guard let indexPath = indexPath else {
                return
            }

            guard let cell = tableView.cellForRow(at: indexPath) else {
                return
            }
            
            configureCell(cell: cell, atIndexPath: indexPath)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        
//        if itemToDelete != nil {
//            itemToDelete?.isBought = NSNumber(booleanLiteral: false)
//            itemToDelete = nil
//        }
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        guard let groceryListItemCell = cell as? GroceryListItemTableViewCell else {
            return
        }
        
        if let groceryListItem = self.fetchedResultsController.object(at: indexPath) as? GroceryListItem {
            groceryListItemCell.configure(item:groceryListItem)
        }
    }
}
