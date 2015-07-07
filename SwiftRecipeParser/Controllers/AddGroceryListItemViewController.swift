//
//  AddGroceryListItemViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 6/3/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit

protocol AddGroceryListItemDelegate {
    func groceryListItemAdded(groceryListItem: GroceryListItem)
}

class AddGroceryListItemViewController: UIViewController {

    var delegate:AddGroceryListItemDelegate?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var unitOfMeasureTextField: UITextField!
    
    lazy private var databaseInterface:DatabaseInterface = {
        return DatabaseInterface()
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.nameTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addItemButtonPressed(sender: AnyObject) {
        var nameTextFieldText = nameTextField.text
        if nameTextFieldText == "" {
            Utilities.showOkButtonAlert(self, title: "Error alert", message:"Name is a required field", okButtonHandler: nil)
        }
        else {
            var groceryListItem:GroceryListItem = databaseInterface.newManagedObjectOfType("GroceryListItem") as! GroceryListItem
            groceryListItem.name = nameTextFieldText
            var quantityTextFieldText:NSString = quantityTextField.text
            groceryListItem.totalQuantity = NSNumber(float: quantityTextFieldText.floatValue)
            if unitOfMeasureTextField.text == "" {
                groceryListItem.unitOfMeasure = "-"
            }
            else {
                groceryListItem.unitOfMeasure = unitOfMeasureTextField.text
            }
            delegate?.groceryListItemAdded(groceryListItem)
            navigationController?.popViewControllerAnimated(true)
        }
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
