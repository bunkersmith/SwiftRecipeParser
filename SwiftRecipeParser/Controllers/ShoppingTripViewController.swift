//
//  ShoppingTripViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 1/12/22.
//  Copyright © 2022 CarlSmith. All rights reserved.
//

import UIKit
import CoreData

class ShoppingTripViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, GroceryListSelectionDelegate {

    lazy private var databaseInterface:DatabaseInterface = {
        return DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        }()
    
    var shoppingTrip: ShoppingTrip!
    var fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>!
    var selectedGroceryList: GroceryList!
    var deletePending = false
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        shoppingTrip = ShoppingTrip.createOrReturn(databaseInterface: databaseInterface)
        createFetchedResultsController()
        selectedGroceryList = nil
    }
    
    func createFetchedResultsController() {
        let predicate = NSPredicate(format: "inShoppingTrip != nil")
        
        fetchedResultsController = databaseInterface.createFetchedResultsController(entityName: "GroceryList", sortKey: "stopNumber", secondarySortKey: nil, sectionNameKeyPath: nil, predicate: predicate)
        
        if fetchedResultsController != nil {
            fetchedResultsController.delegate = self
            tableView.reloadData()
        }
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        if let groceryList = self.fetchedResultsController.object(at: indexPath) as? GroceryList {
            cell.textLabel?.text = groceryList.name
        }
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        showSelectGroceryListViewController()
    }
    
    func showSelectGroceryListViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let selectGroceryListViewController = storyboard.instantiateViewController(withIdentifier: "SelectGroceryListViewController") as? SelectGroceryListViewController
        selectGroceryListViewController!.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        selectGroceryListViewController!.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        selectGroceryListViewController!.groceryLists = GroceryList.returnAllButCurrent()
        selectGroceryListViewController!.delegate = self
        self.present(selectGroceryListViewController!, animated: true, completion: nil)
    }
    
    func groceryListSelected(groceryList: GroceryList, groceryListItem: GroceryListItem?) {
        groceryList.stopNumber = NSNumber(integerLiteral: listSize() + 1)
        shoppingTrip.addToGroceryLists(groceryList)
        databaseInterface.saveContext()
        tableView.reloadData()
    }

    func listSize() -> Int {
        guard let fetchedResultsController = fetchedResultsController else {
            return 0
        }
        guard let sectionInfo = fetchedResultsController.sections else {
            return 0
        }
        guard fetchedResultsController.sections?.count == 1 else {
            return 0
        }
        
//        Logger.logDetails(msg: "Returning \(sectionInfo[section].numberOfObjects) for section \(section)")
        return sectionInfo[0].numberOfObjects
    }
    
    func compressList() {
        let listSize = listSize()
        for i in 0..<listSize {
            let indexPath = IndexPath(row: i, section: 0)
            if let groceryList = self.fetchedResultsController.object(at: indexPath) as? GroceryList {
                groceryList.stopNumber = NSNumber(integerLiteral: i)
            }
        }
        databaseInterface.saveContext()
    }
    
// MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listSize()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingTripCell", for: indexPath)
        self.configureCell(cell: cell, atIndexPath: indexPath)
        
        return cell
    }
     
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let groceryList = self.fetchedResultsController.object(at: indexPath) as? GroceryList {
                groceryList.stopNumber = 0
                shoppingTrip.removeFromGroceryLists(groceryList)
                deletePending = true
                tableView.reloadData()
            }
        }
    }

// MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let groceryList = self.fetchedResultsController.object(at: indexPath) as? GroceryList {
            selectedGroceryList = groceryList
            performSegue(withIdentifier: "ShoppingTripGroceryListSegue", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
// MARK: - Fetched results controller
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
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
            
            self.configureCell(cell: cell, atIndexPath: indexPath)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
        if (deletePending) {
            deletePending = false
            compressList()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShoppingTripGroceryListSegue" {
            let groceryListDetailViewController:GroceryListDetailViewController = segue.destination as! GroceryListDetailViewController
            groceryListDetailViewController.groceryList = selectedGroceryList
            return
        }

    }

}
