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
    @NSManaged var quantity: NSNumber
    @NSManaged var unitOfMeasure: String
    @NSManaged var isTaxable: NSNumber
    @NSManaged var inGroceryList: GroceryList

    override var description: String {
        var returnValue:String
        
        returnValue = "\n***** GroceryListItem"
        returnValue += "\nname = \(name)"
        returnValue += "\ncost = \(cost)"
        returnValue += "\nquantity = \(quantity)"
        returnValue += "\nunitOfMeasure = \(unitOfMeasure)"
        returnValue += "\nisBought = \(isBought)"
        returnValue += "\nisTaxable = \(isTaxable)"
        
        return returnValue
    }
    
    class func findGroceryListItemWithName(name: String) -> GroceryListItem? {
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        if let groceryListItems = databaseInterface.entitiesOfType(entityTypeName: "GroceryListItem", predicate: NSPredicate(format: "name MATCHES %@", name)) as? Array<GroceryListItem> {
            if groceryListItems.count == 1 {
                return groceryListItems.first
            }
        }
        return nil
    }
    
    class func findGroceryListItemWithName(name: String, inListNamed: String) -> GroceryListItem? {
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        if let groceryListItems = databaseInterface.entitiesOfType(entityTypeName: "GroceryListItem", predicate: NSPredicate(format: "name MATCHES %@ AND inGroceryList.name MATCHES %@", name, inListNamed)) as? Array<GroceryListItem> {
            if groceryListItems.count == 1 {
                return groceryListItems.first
            }
        }
        return nil
    }

    class func create(name: String, cost: Float, quantity: Float, unitOfMeasure: String) -> GroceryListItem? {
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        
        if let groceryListItem:GroceryListItem = databaseInterface.newManagedObjectOfType(managedObjectClassName: "GroceryListItem") as? GroceryListItem {
            groceryListItem.name = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            groceryListItem.isBought = NSNumber(value: false)
            groceryListItem.cost = NSNumber(value: cost)
            groceryListItem.quantity = NSNumber(value: quantity)
            groceryListItem.unitOfMeasure = unitOfMeasure
            
            databaseInterface.saveContext()
            
            logAll()
            
            return groceryListItem
        }
        
        return nil
    }

    class func createOrReturn(name: String, cost: Float, quantity: Float, unitOfMeasure: String) -> GroceryListItem? {
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        
        let groceryListItems = databaseInterface.entitiesOfType(entityTypeName: "GroceryListItem", predicate: NSPredicate(format: "name MATCHES %@", name))
        
        if groceryListItems.count == 0 {
            //Logger.logDetails(msg: "Returning created item")
            return create(name: name, cost: cost, quantity: quantity, unitOfMeasure: unitOfMeasure)
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
    
    class func logAll() {
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        
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
    
    class func fetchAll() -> Array<GroceryListItem>? {
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        
        let groceryListItems = databaseInterface.entitiesOfType(entityTypeName: "GroceryListItem") { inputFetchRequest in
            let sortDescriptor:NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            inputFetchRequest.sortDescriptors = [sortDescriptor]
            
            return inputFetchRequest
        } as? Array<GroceryListItem>
        
        if groceryListItems != nil {
            Logger.logDetails(msg: "Count of groceryListItems = \(groceryListItems!.count)")
        }
        
        return groceryListItems
    }
    
    class func addItemToString(groceryListItem:GroceryListItem, string: String) -> String {
        let itemString = "\(groceryListItem.name)\t\(groceryListItem.cost)\t\(groceryListItem.quantity)\t\(groceryListItem.unitOfMeasure)"
        
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
        
        let databaseInterface = DatabaseInterface(concurrencyType: .privateQueueConcurrencyType)
        
        databaseInterface.performInBackground {
            
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
                
                // FIX THIS TO IMPORT THE quantity and unitOfMeasure values from the file
                
                if createOrReturn(name: itemName, cost: itemCost, quantity: 1, unitOfMeasure: "ea") == nil {
                    Logger.logDetails(msg: "Creation of grocery list item named \(itemName) with cost \(itemCost) failed!")
                    
                    completionHandler(false)
                    return
                }
            }
            
            databaseInterface.saveContext()
            
            completionHandler(true)
        }
    }
    
    func update(quantity: Float, taxable: Bool) -> GroceryListItem {
        self.quantity = NSNumber(value: quantity)
        isTaxable = NSNumber(value: taxable)
        
        DatabaseInterface(concurrencyType: .mainQueueConcurrencyType).saveContext()
        
        return self
    }
}
