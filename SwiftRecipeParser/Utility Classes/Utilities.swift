//
//  Utilities.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/27/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Utilities {
    
    @available(iOS 8.0, *)
    class func showOkButtonAlert(viewController:UIViewController, title: String, message:String, okButtonHandler:((UIAlertAction?) -> Void)?) /*-> UIAlertController*/ {
        let okButtonAlert = UIAlertController(title:title, message:message, preferredStyle:UIAlertControllerStyle.alert)
        okButtonAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: okButtonHandler))
        viewController.present(okButtonAlert, animated:true, completion: nil)
        //return okButtonAlert
    }

    @available(iOS 8.0, *)
    class func showYesNoAlert(viewController:UIViewController, title: String, message:String, yesButtonHandler:((UIAlertAction?) -> Void)?, noButtonHandler:((UIAlertAction?) -> Void)?) /*-> UIAlertController*/ {
        let yesNoButtonAlert = UIAlertController(title:title, message:message, preferredStyle:UIAlertControllerStyle.alert)
        yesNoButtonAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: yesButtonHandler))
        yesNoButtonAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: noButtonHandler))
        viewController.present(yesNoButtonAlert, animated:true, completion: nil)
        //return yesNoButtonAlert
    }
    
    @available(iOS 8.0, *)
    class func showTextFieldAlert(viewController:UIViewController,
                                           title: String,
                                         message:String?,
                                    startingText:String,
                                    keyboardType:UIKeyboardType,
                              capitalizationType:UITextAutocapitalizationType,
                                 okButtonHandler:((UIAlertAction?) -> Void)? /*-> UIAlertController*/,
                               completionHandler:@escaping ((UITextField) -> Void)) {
        
        let textFieldAlert = UIAlertController(title:title, message:message, preferredStyle:.alert)
        textFieldAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: okButtonHandler))
        textFieldAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
        textFieldAlert.addTextField { (textField: UITextField!) -> Void in
            let textField = textField
            textField!.keyboardType = keyboardType
            textField!.autocapitalizationType = capitalizationType
            textField!.text = startingText
            completionHandler(textField!)
        }
        
        viewController.present(textFieldAlert, animated: true, completion: nil)
        //return textFieldAlert
    }

    class func showAddIngredientAlert(object: AnyObject, viewController: UIViewController)
    {
        //let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        let selectedIngredient:Ingredient = object as! Ingredient;
        let currentGroceryList = GroceryList.returnCurrentGroceryList()
        
        if (currentGroceryList == nil)
        {
            if #available(iOS 8.0, *) {
                Utilities.showOkButtonAlert(viewController: viewController, title: "Error Alert", message: "No current grocery list", okButtonHandler: nil)
            } else {
                // Fallback on earlier versions
            }
        }
        else
        {
            let quantityString:String = FractionMath.doubleToString(inputDouble: selectedIngredient.quantity.doubleValue);
            let addString = "Add \(quantityString) \(selectedIngredient.unitOfMeasure) \(selectedIngredient.ingredientItem.name) to the \(currentGroceryList!.name) grocery list?"
            if #available(iOS 8.0, *) {
                let _ = Utilities.showYesNoAlert(viewController: viewController, title: "Add Item", message: addString, yesButtonHandler: { action in

                    GroceryList.addItemToCurrent(itemName: selectedIngredient.ingredientItem.name, quantity: quantityString, unitOfMeasure: selectedIngredient.unitOfMeasure)
                    
                }, noButtonHandler: nil)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    class func convertSectionTitles(fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>) -> Array<String> {
        var returnValue:Array<String> = [" "]
        var sections:Array = fetchedResultsController.sections!
        
        for i in 0 ..< sections.count {
            returnValue.append(sections[i].name)
        }
        
        return returnValue
    }
    
    class func convertSectionIndexTitles(fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>) -> Array<String> {
        var returnValue:Array<String> = [UITableViewIndexSearch]
        for i in 0 ..< fetchedResultsController.sectionIndexTitles.count {
            returnValue.append(fetchedResultsController.sectionIndexTitles[i] )
        }
        
        return returnValue
    }
    
    class func fileExistsAtAbsolutePath(pathname:String) -> Bool {
        var isDirectory:ObjCBool = ObjCBool(false)
        let existsAtPath:Bool = FileManager.default.fileExists(atPath: pathname, isDirectory: &isDirectory)
        
        return existsAtPath && !isDirectory.boolValue
    }
    
    class func directoryExistsAtAbsolutePath(pathname:String) -> Bool {
        var isDirectory:ObjCBool = ObjCBool(false)
        let existsAtPath:Bool = FileManager.default.fileExists(atPath: pathname, isDirectory: &isDirectory)
        
        return existsAtPath && isDirectory.boolValue
    }
    
    class func writelnToStandardOut(stringToWrite:String) {
        DispatchQueue.main.async {
            print(stringToWrite)
        }
    }
    
    // Returns the URL to the application's Documents directory.
    class func applicationDocumentsDirectory() -> URL
    {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] 
    }
    
    class func nsFetchedResultsChangeTypeToString( nsFetchedResultsChangeType: NSFetchedResultsChangeType) -> String {
        switch nsFetchedResultsChangeType {
            case .insert:
                return "NSFetchedResultsChangeInsert"
            case .delete:
                return "NSFetchedResultsChangeDelete"
            case .move:
                return "NSFetchedResultsChangeMove"
            case .update:
                return "NSFetchedResultsChangeUpdate"
        }
    }
    
    class func forceLoadDatabase() -> Bool {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist") else {
            return false
        }
        guard let dict = NSDictionary(contentsOfFile: path) else {
            return false
        }
        guard let obj = dict.object(forKey: "forceLoadDatabase") as? NSNumber else {
            return false
        }
        /*
         guard let bool = obj.boolValue else {
         return false
         }
         */
        return obj.boolValue
    }
    
/*
    class func updateGroceryListItems() -> Bool {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist") else {
            return false
        }
        guard let dict = NSDictionary(contentsOfFile: path) else {
            return false
        }
        guard let obj = dict.object(forKey: "updateGroceryListItems") as? NSNumber else {
            return false
        }
        /*
        guard let bool = obj.boolValue else {
            return false
        }
        */
        return obj.boolValue
    }
*/
    
}
