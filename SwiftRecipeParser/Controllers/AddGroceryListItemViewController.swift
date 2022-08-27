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
    func groceryListItemAddedAndBought(groceryListItem: GroceryListItem)
}

class AddGroceryListItemViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    weak var delegate:AddGroceryListItemDelegate?
    var fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var renameButton: UIButton!
    
    lazy private var databaseInterface:DatabaseInterface = {
        return DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        nameTextField.becomeFirstResponder()
        nameTextField.addTarget(self, action: #selector(AddGroceryListItemViewController.textFieldChanged(textField:)), for: .editingChanged)
        
        createFetchedResultsController(predicate: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
    func returnNameTextFieldText() -> String? {
        let nameTextFieldText = nameTextField.text!
        if nameTextFieldText == "" {
            AlertUtilities.showOkButtonAlert(self, title: "Error Alert", message:"Name is a required field", buttonHandler: nil)
            return nil
        }
        
        return nameTextFieldText
    }
    
    @IBAction func addItemButtonPressed(_ sender: Any) {
        if let nameTextFieldText = returnNameTextFieldText() {
            fetchedResultsController = nil
            if let groceryListItem = GroceryListItem.createOrReturn(name: nameTextFieldText, cost: 0.0, quantity: 1.0, unitOfMeasure: "ea", databaseInterface: nil) {
                delegate?.groceryListItemAdded(groceryListItem: groceryListItem)
            }

            let _ = navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func addAndBuyItemButtonPressed(_ sender: Any) {
        if let nameTextFieldText = returnNameTextFieldText() {
            fetchedResultsController = nil
            if let groceryListItem = GroceryListItem.createOrReturn(name: nameTextFieldText, cost: 0.0, quantity: 1.0, unitOfMeasure: "ea", databaseInterface: nil) {
                delegate?.groceryListItemAddedAndBought(groceryListItem: groceryListItem)
            }

            let _ = navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func importFileButtonPressed(_ sender: Any) {
        AlertUtilities.showYesNoAlert(viewController: self, title: "Import Alert", message: "ARE YOU SURE you want to import all the Grocery List Items from the iCloud file?", yesButtonHandler: { action in
                GroceryListItem.importFromIcloudFile { (isSuccessful) in
                    if !isSuccessful {
                        DispatchQueue.main.async {
                            AlertUtilities.showOkButtonAlert(self, title: "Error Alert", message:"File import failed", buttonHandler: nil)
                            Logger.logDetails(msg: "File import failed")
                        }
                    }
                }
        }, noButtonHandler: nil)
    }
    
    @IBAction func exportButtonPressed(_ sender: Any) {
        AlertUtilities.showYesNoAlert(viewController: self, title: "Export Alert", message: "Do you want to export all the Grocery List Items to the iCloud file?", yesButtonHandler: { action in
            GroceryListItem.writeAllToIcloud()
        }, noButtonHandler: nil)
    }
    
    @IBAction func renameButtonPressed(_ sender: Any) {
        var inputTextField = UITextField()

        AlertUtilities.showTextFieldAlert(viewController: self,
                                          title: "Rename Grocery List Item",
                                          message: "Enter the new name for your grocery list item",
                                          startingText: nameTextField.text!,
                                          keyboardType: nil,
                                          capitalizationType: .words) { alertAction in
            guard GroceryListItem.findGroceryListItemWithName(name: inputTextField.text!) == nil else {
                AlertUtilities.showOkButtonAlert(self,
                                                 title: "Error Alert",
                                                 message: "Sorry, you already have a grocery list item with that name.",
                                                 buttonHandler: nil)
                return
            }
            
            GroceryListItem.rename(oldName: self.nameTextField.text!,
                                   newName: inputTextField.text!,
                                   databaseInterface: self.databaseInterface)
        } textFieldHandler: { textField in
            inputTextField = textField
        }

    }
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        Logger.logDetails(msg: "Table has \(fetchedResultsController.sections?.count ?? 0) section(s)")
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard fetchedResultsController != nil else {
            return 0
        }
        guard let sectionInfo = fetchedResultsController.sections else {
            return 0
        }
        Logger.logDetails(msg: "Returning \(sectionInfo[section].numberOfObjects) for section \(section)")
        return sectionInfo[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        Logger.logDetails(msg: "Called for indexPath = \(indexPath)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddGroceryListItemCell", for: indexPath)
        configureCell(cell: cell, atIndexPath: indexPath)
/*
        if let groceryListItemCell = cell as? AddGroceryListItemTableViewCell {
            print("Name is '\(groceryListItemCell.nameLabel.text ?? "none")' for row at indexPath \(indexPath)")
        }
*/
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let groceryListItem = fetchedResultsController.object(at: indexPath) as? GroceryListItem {
                databaseInterface.deleteObject(coreDataObject: groceryListItem)
                tableView.reloadData()
            }
        }
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let object = fetchedResultsController.object(at: indexPath)
        Logger.logDetails(msg: "object at indexPath \(indexPath): \(object)")
        if let groceryListItem = object as? GroceryListItem {
            if let groceryListItemCell = cell as? AddGroceryListItemTableViewCell {
                groceryListItemCell.nameLabel.text = groceryListItem.name
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let groceryListItem = fetchedResultsController.object(at: indexPath) as? GroceryListItem {
            nameTextField.text = groceryListItem.name
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
    }
    
    @objc func textFieldChanged(textField: UITextField) {
        if let textFieldText = textField.text {
            if textFieldText.count == 0 {
                renameButton.isHidden = true
                createFetchedResultsController(predicate: nil)
            } else {
                renameButton.isHidden = false
                createFetchedResultsController(predicate: NSPredicate(format: "name contains[cd] %@", textFieldText))
            }
        }
    }
    
}
