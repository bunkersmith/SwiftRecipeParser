//
//  AlertUtilities.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/24/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import Foundation
import UIKit

class AlertUtilities {
    
    class func showNoButtonAlert(_ viewController:UIViewController, title: String, message:String) -> UIAlertController {
        
        let noButtonAlert = UIAlertController(title:title, message:message, preferredStyle:UIAlertControllerStyle.alert)
        viewController.present(noButtonAlert, animated:true, completion: nil)
        
        return noButtonAlert
    }
    
    class func showTwoButtonAlert(_ viewController:UIViewController,
                                             title: String,
                                           message:String,
                                      buttonTitle1: String,
                                    buttonHandler1:((UIAlertAction) -> Void)?,
                                      buttonTitle2: String,
                                    buttonHandler2:((UIAlertAction) -> Void)?) {
        let twoButtonAlert = UIAlertController(title:title, message:message, preferredStyle:UIAlertControllerStyle.alert)
        twoButtonAlert.addAction(UIAlertAction(title: buttonTitle1, style: UIAlertActionStyle.default, handler: buttonHandler1))
        twoButtonAlert.addAction(UIAlertAction(title: buttonTitle2, style: UIAlertActionStyle.cancel, handler: buttonHandler2))
        viewController.present(twoButtonAlert, animated:true, completion: nil)
        //return twoButtonAlert
    }
    
    class func showOkButtonAlert(_ viewController:UIViewController, title: String, message:String, buttonHandler:((UIAlertAction) -> Void)?) {
        let okButtonAlert = UIAlertController(title:title, message:message, preferredStyle:UIAlertController.Style.alert)
        okButtonAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: buttonHandler))
        viewController.present(okButtonAlert, animated:true, completion: nil)
        //return okButtonAlert
    }
    
    class func showYesNoAlert(viewController:UIViewController, title: String, message:String, yesButtonHandler:((UIAlertAction?) -> Void)?, noButtonHandler:((UIAlertAction?) -> Void)?) /*-> UIAlertController*/ {
        let yesNoButtonAlert = UIAlertController(title:title, message:message, preferredStyle:UIAlertController.Style.alert)
        yesNoButtonAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: yesButtonHandler))
        yesNoButtonAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: noButtonHandler))
        viewController.present(yesNoButtonAlert, animated:true, completion: nil)
        //return yesNoButtonAlert
    }

    class func showThreeButtonAlert(_ viewController:UIViewController,
                                    title: String,
                                  message:String,
                             buttonTitle1: String,
                           buttonHandler1:((UIAlertAction) -> Void)?,
                             buttonTitle2: String,
                           buttonHandler2:((UIAlertAction) -> Void)?,
                             buttonTitle3: String,
                           buttonHandler3:((UIAlertAction) -> Void)?) {
        let threeButtonAlert = UIAlertController(title:title, message:message, preferredStyle:UIAlertControllerStyle.alert)
        threeButtonAlert.addAction(UIAlertAction(title: buttonTitle1, style: UIAlertActionStyle.default, handler: buttonHandler1))
        threeButtonAlert.addAction(UIAlertAction(title: buttonTitle2, style: UIAlertActionStyle.default, handler: buttonHandler2))
        threeButtonAlert.addAction(UIAlertAction(title: buttonTitle3, style: UIAlertActionStyle.cancel, handler: buttonHandler3))
        viewController.present(threeButtonAlert, animated:true, completion: nil)
    }
    
    @available(iOS 8.0, *)
    class func showTextFieldAlert(viewController:UIViewController,
                                           title: String,
                                         message:String?,
                                    startingText:String,
                                    keyboardType:UIKeyboardType,
                              capitalizationType:UITextAutocapitalizationType,
                                 okButtonHandler:((UIAlertAction?) -> Void)? /*-> UIAlertController*/,
                                textFieldHandler:@escaping ((UITextField) -> Void)) {
        
        let textFieldAlert = UIAlertController(title:title, message:message, preferredStyle:.alert)
        textFieldAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: okButtonHandler))
        textFieldAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
        textFieldAlert.addTextField { (textField: UITextField!) -> Void in
            let textField = textField
            textField!.keyboardType = keyboardType
            textField!.autocapitalizationType = capitalizationType
            textField!.text = startingText
            textFieldHandler(textField!)
        }
        
        viewController.present(textFieldAlert, animated: true, completion: nil)
        //return textFieldAlert
    }
    
    class func queryItemPrice(viewController: UIViewController, itemToBuy:GroceryListItem, completionHandler: @escaping ((Float,String,Float) -> Void)) {
        let priceText = itemToBuy.cost.floatValue > 0.0 ? itemToBuy.cost.floatValue.clean : ""
        
        TripleTextAlertDialogViewController.showPopup(parentVC: viewController,
                                                      prompt: "Enter the values for \(itemToBuy.name)",
                                                      initialQuantity: itemToBuy.quantity.floatValue.clean,
                                                      initialUnits: itemToBuy.unitOfMeasure,
                                                      initialPrice: priceText) { quantity, units, price in
            Logger.logDetails(msg: "quantity: \(quantity), units: \(units), price: \(price)")
            completionHandler(quantity, units, price)
        }
    }
    
    class func showAddIngredientAlert(object: AnyObject, viewController: UIViewController)
    {
        //let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        let currentGroceryList = GroceryList.returnCurrentGroceryList()
        
        if currentGroceryList == nil {
            AlertUtilities.showOkButtonAlert(viewController, title: "Error Alert", message: "No current grocery list", buttonHandler: nil)
        }
        else {
            
            let selectedIngredient:Ingredient = object as! Ingredient;
            let quantityString:String = FractionMath.doubleToString(inputDouble: selectedIngredient.quantity.doubleValue);
            let addString = "Add \(quantityString) \(selectedIngredient.unitOfMeasure) \(selectedIngredient.ingredientItem.name) to the \(currentGroceryList!.name) grocery list?"
            AlertUtilities.showYesNoAlert(viewController: viewController, title: "Add Item", message: addString, yesButtonHandler: { action in
                
                guard let groceryListItem = GroceryListItem.createOrReturn(name: selectedIngredient.ingredientItem.name,
                                                                           cost: 0.0,
                                                                           quantity: selectedIngredient.quantity.floatValue,
                                                                           unitOfMeasure: selectedIngredient.unitOfMeasure,
                                                                           databaseInterface: nil) else {
                    return
                }

                if currentGroceryList!.hasItems.contains(groceryListItem) {
                    AlertUtilities.showOkButtonAlert(viewController, title: "Error Alert", message: "\(groceryListItem.name) is already on your list", buttonHandler: nil)
                }
                else {
                    queryItemPrice(viewController: viewController, itemToBuy: groceryListItem) { (itemQuantity, itemUnits, itemPrice) in
                        currentGroceryList?.addItem(item: groceryListItem,
                                                    itemQuantity: itemQuantity,
                                                    itemUnits: itemUnits,
                                                    itemPrice: itemPrice,
                                                    itemNotes: nil)
                    }
                }

            }, noButtonHandler: nil)
        }
    }
    
}
