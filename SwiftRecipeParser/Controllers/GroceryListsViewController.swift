//
//  GroceryListsViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 6/1/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit
import CoreData

class GroceryListsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectedListsTotalLabel: UILabel!
    
    private var groceryLists:Array<GroceryList>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        clearSelectedGroceryLists()

// THIS LINE MAKES THE UITabBar AT THE BOTTOM OF THE SCREEN INVISIBLE.
// I'M GOING TO SEE IF I LIKE THE LOOK OF THIS ViewController BETTER WITH IT VISIBLE.
        
//        tableView.tableFooterView = UIView(frame: .zero)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        populateGroceryLists()
        
        caculateCoreDataSelectedGroceryListCosts()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(self, selector:  #selector(handleGroceryListCheckBoxNotification(notification:)), name: Notification.Name(rawValue:"SwiftRecipeParser.groceryListCheckBoxNotification"), object: nil)
        
        GroceryListItem.calculateAllTotalCosts()
        
        if UIDevice.current.model.starts(with: "iPad") {
            tabBarController?.selectedIndex = 1
        }

// THE CODE BELOW DISPLAYS AN ALERT FOR EACH GroceryListItem, POSSIBLY FOR IDENTIFYING ITEMS TO PURGE?

//        let groceryListItems = GroceryListItem.fetchAll()!
//        displayAlert(i: 0, groceryListItems: groceryListItems)
//        for groceryListItem in groceryListItems {
//            let alertString = "\(groceryListItem.quantity)\n\(groceryListItem.unitOfMeasure)\n\(groceryListItem.name)"
//            AlertUtilities.showOkButtonAlert(self, title: "Alert", message: alertString, buttonHandler: nil)
//        }
    }
    
//    func displayAlert(i: Int, groceryListItems: [GroceryListItem]) {
//        if i < groceryListItems.count {
//            let groceryListItem = groceryListItems[i]
//            let alertString = "\(groceryListItem.quantity)\n\(groceryListItem.unitOfMeasure)\n\(groceryListItem.name)"
//            AlertUtilities.showOkButtonAlert(self, title: "Alert", message: alertString, buttonHandler: { _ in
//                self.displayAlert(i: i+1, groceryListItems: groceryListItems)
//            })
//        }
//    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        groceryLists = nil
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"SwiftRecipeParser.groceryListCheckBoxNotification"), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func caculateCoreDataSelectedGroceryListCosts() {
        let groceryLists = GroceryList.returnAll()
        var grandTotalCost:Float = 0

        for groceryList in groceryLists {
            if groceryList.isSelected.boolValue {
                grandTotalCost += groceryList.projectedCost.floatValue
            }
        }
        
        if grandTotalCost > 0 {
            selectedListsTotalLabel.alpha = 1.0
            selectedListsTotalLabel.text = String(format: "Grand Total: $%.2f", grandTotalCost)
        } else {
            selectedListsTotalLabel.alpha = 0.0
            selectedListsTotalLabel.text = ""
        }
    }
    
    func clearSelectedGroceryLists() {
        let groceryLists = GroceryList.returnAll()
        for groceryList in groceryLists {
            groceryList.isSelected = false
        }
        
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        databaseInterface.saveContext()
    }

    func initCheckBoxes() {
        if (groceryLists != nil) {
            for indexPath in tableView.getAllIndexes() {
                if let cell = tableView.cellForRow(at: indexPath) as? GroceryListTableViewCell {
                    cell.isSelectedCheckBox.isChecked = groceryLists![indexPath.row].isSelected.boolValue
                }
            }
        }
    }
    
    func populateGroceryLists() {
        groceryLists = GroceryList.returnAll()
        tableView.reloadData()

        initCheckBoxes()
    }
    
    @IBAction func emailLogButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "EmailLogSegue", sender: self)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        var inputTextField = UITextField()

        let _ = AlertUtilities.showTextFieldAlert(viewController: self, title: "Enter grocery list name", message: "", startingText: "", keyboardType: nil, capitalizationType: .words, okButtonHandler: { action in
            let groceryListName:String = inputTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            GroceryList.create(name: groceryListName)
            GroceryList.setCurrentGroceryList(groceryListName: groceryListName)
            
            self.populateGroceryLists()
            self.tableView.reloadData()
        }, textFieldHandler: { (txtField) in
            inputTextField = txtField
        })
    }
    
    @IBAction func importButtonPressed(_ sender: Any) {
        let pasteboard = UIPasteboard.general
        if #available(iOS 10.0, *) {
            if pasteboard.hasStrings {
                if let pasteboardString = pasteboard.string {
                    let lines = pasteboardString.components(separatedBy: CharacterSet.newlines)
                    var groceryListName = ""
                    var groceryList: GroceryList? = nil
                    for line in lines {
                        if let groceryListItem = GroceryListItem.parseGroceryListItemString(string: line, databaseInterface: nil) {
                            if groceryListName.isEmpty {
                                groceryListName = line
                                groceryList = GroceryList.findGroceryListWithName(name: groceryListName)
                                if groceryList == nil {
                                    AlertUtilities.showOkButtonAlert(self,
                                                                     title: "Error Alert",
                                                                     message: "You have no grocery list named \(groceryListName)",
                                                                     buttonHandler: nil)
                                    break
                                }
                            } else {
                                groceryList?.addItem(item: groceryListItem,
                                                     itemQuantity: groceryListItem.quantity.floatValue,
                                                     itemUnits: groceryListItem.unitOfMeasure,
                                                     itemPrice: groceryListItem.cost.floatValue,
                                                     itemNotes: groceryListItem.notes)
                                print("\(String(describing: groceryListItem))")
                            }
                        }
                    }
                    if groceryList != nil {
                        groceryList?.updateProjectedCost()
                        populateGroceryLists()
                        caculateSelectedGroceryListCosts()
                    }
                    return
                }
            }
            AlertUtilities.showOkButtonAlert(self, title: "Error Alert", message: "There is nothing in the clipboard.", buttonHandler: nil)
        }
    }
    
    @objc func handleGroceryListCheckBoxNotification(notification:NSNotification) {
        caculateSelectedGroceryListCosts()
    }

    func caculateSelectedGroceryListCosts() {
        
        var grandTotalCost:Float = 0
        
        for indexPath in tableView.getAllIndexes() {
            if let cell = tableView.cellForRow(at: indexPath) as? GroceryListTableViewCell {
                if cell.isSelectedCheckBox.isChecked {
                    if (groceryLists != nil) {
                        grandTotalCost += groceryLists![indexPath.row].projectedCost.floatValue
                        groceryLists![indexPath.row].isSelected = NSNumber(booleanLiteral: true)
                    }
                } else {
                    if (groceryLists != nil) {
                        groceryLists![indexPath.row].isSelected = NSNumber(booleanLiteral: false)
                    }
                }
            }
        }
        
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        databaseInterface.saveContext()
        
        if grandTotalCost > 0 {
            selectedListsTotalLabel.alpha = 1.0
            selectedListsTotalLabel.text = String(format: "Grand Total: $%.2f", grandTotalCost)
        } else {
            selectedListsTotalLabel.alpha = 0.0
            selectedListsTotalLabel.text = ""
        }
    }
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return groceryLists != nil ? groceryLists!.count : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroceryListTableCell", for: indexPath)
        
        let groceryListTableViewCell = cell as? GroceryListTableViewCell
        let groceryList:GroceryList = groceryLists![indexPath.row]
        
        // Configure the cell...
        if groceryList.isCurrent.boolValue {
            groceryListTableViewCell!.nameLabel?.text = groceryList.name + "*"
        }
        else {
            groceryListTableViewCell!.nameLabel?.text = groceryList.name
        }
        
        groceryListTableViewCell!.projectedCostLabel?.text = groceryList.projectedCostString()
        if groceryList.projectedCost.floatValue > 0 {
            groceryListTableViewCell!.projectedCostLabel?.textColor = .red
        } else {
            groceryListTableViewCell!.projectedCostLabel?.textColor = .black
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false                                )
        if (groceryLists != nil) {
            GroceryList.setCurrentGroceryList(groceryListName: groceryLists![indexPath.row].name)
            populateGroceryLists()
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if (groceryLists != nil) {
            // Delete the row from the model and data source
                let groceryList:GroceryList = groceryLists![indexPath.row]
                GroceryList.delete(groceryList:groceryList)
                groceryLists!.remove(at: indexPath.row)
                
                // Delete the row from the table view
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectGroceryListSegue" {
            if (groceryLists != nil) {
                let detailViewController:GroceryListDetailViewController = segue.destination as! GroceryListDetailViewController
                let indexPath:NSIndexPath = tableView.indexPathForSelectedRow! as NSIndexPath
                detailViewController.groceryList = groceryLists![indexPath.row]
            }
            return
        }

        if segue.identifier == "EmailLogSegue" {
            if let emailLogViewController = segue.destination as? EmailLogViewController {
                emailLogViewController.requestMailComposeViewController()
            }

            return
        }
    }

}
