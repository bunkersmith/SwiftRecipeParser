//
//  AddGroceryListItemViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 6/3/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit
import CoreData

protocol AddGroceryListItemDelegate: class {
    func groceryListItemAdded(groceryListItem: GroceryListItem)
}

class AddGroceryListItemViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    weak var delegate:AddGroceryListItemDelegate?
    var fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    lazy private var databaseInterface:DatabaseInterface = {
        return DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.becomeFirstResponder()
        nameTextField.addTarget(self, action: #selector(AddGroceryListItemViewController.textFieldChanged(textField:)), for: .editingChanged)
        
        createFetchedResultsController(predicate: nil)
        
        tableView.tableFooterView = UIView(frame: .zero)
    }

    func createFetchedResultsController(predicate: NSPredicate?) {
        fetchedResultsController = databaseInterface.createFetchedResultsController(entityName: "GroceryListItem", sortKey: "name", secondarySortKey: nil, sectionNameKeyPath: nil, predicate: predicate)
            if fetchedResultsController != nil {
            fetchedResultsController.delegate = self
            tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addItemButtonPressed(_ sender: Any) {
        if #available(iOS 8.0, *) {
            let nameTextFieldText = nameTextField.text!
            if nameTextFieldText == "" {
                    Utilities.showOkButtonAlert(viewController: self, title: "Error alert", message:"Name is a required field", okButtonHandler: nil)
            }
            else {
                fetchedResultsController = nil
                if let existingItem = GroceryListItem.findGroceryListItemWithName(name: nameTextFieldText) {
                    existingItem.quantity = 1.0
                    existingItem.unitOfMeasure = "ea"
                    delegate?.groceryListItemAdded(groceryListItem: existingItem)
                }
                else {
                    
                    if let groceryListItem = GroceryListItem.create(name: nameTextFieldText, cost: 0.0, quantity: 1.0, unitOfMeasure: "ea") {
                        delegate?.groceryListItemAdded(groceryListItem: groceryListItem)
                    }
                }
                let _ = navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func importFileButtonPressed(_ sender: Any) {
        GroceryListItem.importFile { (isSuccessful) in
            if !isSuccessful {
                DispatchQueue.main.async {
                    Utilities.showOkButtonAlert(viewController: self, title: "Error alert", message:"File import failed", okButtonHandler: nil)
                    Logger.logDetails(msg: "File import failed")
                }
            }
        }
    }
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] 
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddGroceryListItemCell", for: indexPath)
        self.configureCell(cell: cell, atIndexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let groceryListItem = self.fetchedResultsController.object(at: indexPath) as? GroceryListItem {
                databaseInterface.deleteObject(coreDataObject: groceryListItem)
                tableView.reloadData()
            }
        }
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath:
        IndexPath) {
        if let groceryListItem = self.fetchedResultsController.object(at: indexPath) as? GroceryListItem {
            if let groceryListItemCell = cell as? AddGroceryListItemTableViewCell {
                groceryListItemCell.nameLabel.text = groceryListItem.name
                if groceryListItem.cost.floatValue > 0.0 {
                    groceryListItemCell.costLabel.text = String(format: "%.2f", groceryListItem.cost.floatValue)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let groceryListItem = self.fetchedResultsController.object(at: indexPath) as? GroceryListItem {
            nameTextField.text = groceryListItem.name
        }
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
            self.configureCell(cell: tableView.cellForRow(at: indexPath!)!, atIndexPath: indexPath!)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func textFieldChanged(textField: UITextField) {
        createFetchedResultsController(predicate: NSPredicate(format: "name contains[cd] %@", textField.text!))
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
