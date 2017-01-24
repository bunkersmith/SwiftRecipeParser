//
//  GroceryListItem.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/7/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class GroceryListItem: NSManagedObject {

    @NSManaged var cost: NSNumber
    @NSManaged var isBought: NSNumber
    @NSManaged var name: String
    @NSManaged var inGroceryList: GroceryList

    class func findGroceryListItemWithName(name: String) -> GroceryListItem? {
        if let groceryListItems = DatabaseInterface().entitiesOfType(entityTypeName: "GroceryListItem", predicate: NSPredicate(format: "name MATCHES %@", name)) as? Array<GroceryListItem> {
            if groceryListItems.count == 1 {
                return groceryListItems.first
            }
        }
        return nil
    }

    class func create(databaseInterface:DatabaseInterface, name: String, cost: Float) -> GroceryListItem? {
        if let groceryListItem:GroceryListItem = databaseInterface.newManagedObjectOfType(managedObjectClassName: "GroceryListItem") as? GroceryListItem {
            groceryListItem.name = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            groceryListItem.isBought = NSNumber(value: false)
            groceryListItem.cost = NSNumber(value: cost)
            
            databaseInterface.saveContext()
            
            logAll(databaseInterface: databaseInterface)
            
            return groceryListItem
        }
        
        return nil
    }

    class func createOrReturn(databaseInterface:DatabaseInterface, name: String, cost: Float) -> GroceryListItem? {
        let groceryListItems = databaseInterface.entitiesOfType(entityTypeName: "GroceryListItem", predicate: NSPredicate(format: "name MATCHES %@", name))
        
        if groceryListItems.count == 0 {
            //Logger.logDetails(msg: "Returning created item")
            return create(databaseInterface: databaseInterface, name: name, cost: cost)
        }
        
        if groceryListItems.count == 1 {
            if let groceryListItem = groceryListItems.first as? GroceryListItem {
                //Logger.logDetails(msg: "Returning existing item")
                
                groceryListItem.cost = NSNumber(value: cost)
                databaseInterface.saveContext()
                
                return groceryListItem
            }
        }
        
        return nil
    }
    
    class func logAll(databaseInterface: DatabaseInterface) {
        let groceryListItems = databaseInterface.entitiesOfType(entityTypeName: "GroceryListItem") { inputFetchRequest in
            let sortDescriptor:NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            inputFetchRequest.propertiesToFetch = ["name", "cost"]
            inputFetchRequest.sortDescriptors = [sortDescriptor]
            
            return inputFetchRequest
        } as? Array<GroceryListItem>
        
        if groceryListItems != nil {
            Logger.logDetails(msg: "Count of groceryListItems = \(groceryListItems!.count)")
            
            var itemsString = ""
            
            for item in groceryListItems! {
                itemsString = addItemToString(groceryListItem: item, string: itemsString)
            }
            
            writeItemsToICloudFile(itemsString: itemsString)
        }
    }
    
    class func addItemToString(groceryListItem:GroceryListItem, string: String) -> String {
        let itemString = "\(groceryListItem.name)\t\(groceryListItem.cost)"
        
        return "\(string)\n\(itemString)"
    }
    
    class func writeItemsToICloudFile(itemsString: String) {
        
        let icDocWrapper = ICloudDocWrapper(filename: FileUtilities.iCloudGroceryListItemsFileName())
        
        icDocWrapper.writeTextToDoc(text: itemsString) { (docResult) in
            Logger.logDetails(msg: "docResult = \(docResult)")
        }
        
    }
    
    class func importFile(completionHandler:@escaping ((Bool) -> Void)) {
        let textFile = ProcessTextFile(fileName: FileUtilities.groceryListItemsFilePath())
        
        guard textFile.open() else {
            Logger.logDetails(msg: "File open failed!")
            
            completionHandler(false)
            return
        }
        
        let importFileLines = textFile.linesInFile()
        
        //Logger.logDetails(msg: "Count of lines in file = \(importFileLines.count)")
        
        let databaseManager:DatabaseManager = DatabaseManager.instance
        
        databaseManager.backgroundOperation(block: {
            let databaseInterface = DatabaseInterface()
            
            for line in importFileLines {
                //NSLog("Line: \"\(line)\"")
                let components = line.components(separatedBy: "\t")
                
                //NSLog("Components: \(components)")
                let itemName = components[0]
                var itemCost:Float = 0.0
                
                if components.count >= 2 {
                    if let costNumber = NumberFormatter().number(from: components[1]) {
                        itemCost = costNumber.floatValue
                    }
                }
                
                if createOrReturn(databaseInterface: databaseInterface, name: itemName, cost: itemCost) == nil {
                    Logger.logDetails(msg: "Creation of grocery list item named \(itemName) with cost \(itemCost) failed!")
                    
                    completionHandler(false)
                    return
                }
            }
            
            completionHandler(true)
        })
    }
}
