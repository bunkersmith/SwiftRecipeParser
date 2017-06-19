//
//  GroceryList.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 6/1/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class GroceryList: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var isCurrent: NSNumber
    @NSManaged var totalCost: NSNumber
    @NSManaged var projectedCost: NSNumber
    @NSManaged var hasItems: NSOrderedSet
    
    
    func addHasItemsObject(value:GroceryListItem)
    {
        self.willChangeValue(forKey: "hasItems");
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.hasItems);
        tempSet.add(value);
        self.hasItems = tempSet;
        self.didChangeValue(forKey: "hasItems");
    }
    
    func removeHasItemsObject(value:GroceryListItem)
    {
        self.willChangeValue(forKey: "hasItems");
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.hasItems);
        tempSet.remove(value);
        self.hasItems = tempSet;
        self.didChangeValue(forKey: "hasItems");
    }
    
    func removeAllHasItemsObjects()
    {
        self.willChangeValue(forKey: "hasItems")
        self.hasItems = NSMutableOrderedSet()
        self.didChangeValue(forKey: "hasItems")
        DatabaseInterface(concurrencyType: .mainQueueConcurrencyType).saveContext()
    }
    
    func clearAllItems() {
        
        hasItems.enumerateObjects({ (groceryListObject, idx, stop) -> Void in
            let groceryListItem = groceryListObject as! GroceryListItem
            if groceryListItem.isBought.boolValue {
                groceryListItem.isBought = NSNumber(value: false)
            }
        })
        
        removeAllHasItemsObjects()
        DatabaseInterface(concurrencyType: .mainQueueConcurrencyType).saveContext()
    }
    
    class func create(name: String) {
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        
        let groceryList:GroceryList = databaseInterface.newManagedObjectOfType(managedObjectClassName: "GroceryList") as! GroceryList
        groceryList.name = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        groceryList.totalCost = NSNumber(value:0.0)
        
        databaseInterface.saveContext();
    }
    
    class func delete(groceryList: GroceryList) {
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        
        databaseInterface.deleteObject(coreDataObject: groceryList)
        databaseInterface.saveContext()
    }
    
    class func setCurrentGroceryList(groceryListName:String)
    {
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        let groceryLists:Array<GroceryList> = databaseInterface.entitiesOfType(entityTypeName:"GroceryList", predicate:nil) as! Array<GroceryList>
        for groceryList:GroceryList in groceryLists {
            if groceryList.name == groceryListName {
                groceryList.isCurrent = NSNumber(value: true);
            }
            else {
                groceryList.isCurrent = NSNumber(value: false);
            }
        }
        databaseInterface.saveContext();
    }
    
    class func returnAll() -> Array<GroceryList> {
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
            
        guard let returnValue = databaseInterface.entitiesOfType(entityTypeName: "GroceryList", predicate:nil) as? Array<GroceryList> else {
            return []
        }
        
        return returnValue
    }
    
    class func returnCurrentGroceryList() -> GroceryList?
    {
        var returnValue:GroceryList? = nil
    
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        let groceryLists:Array<GroceryList> = databaseInterface.entitiesOfType(entityTypeName:"GroceryList", predicate:NSPredicate(format:"isCurrent == %@", NSNumber(value: true))) as! Array<GroceryList>
    
        if (groceryLists.count == 1) {
            returnValue = groceryLists.first
        }
    
        return returnValue;
    }

    class func returnGroceryListWithName(name: String) -> GroceryList? {
        var returnValue:GroceryList? = nil
        
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        let groceryLists:Array<GroceryList> = databaseInterface.entitiesOfType(entityTypeName:"GroceryList", predicate:NSPredicate(format:"name == %@", name)) as! Array<GroceryList>
        
        if (groceryLists.count == 1) {
            returnValue = groceryLists.first
        }
        
        return returnValue
    }
    
    func updateAndReturnProjectedCost() -> Float {
        projectedCost = NSNumber(value: 0.0)
        
        for item in hasItems {
            if let groceryListItem = item as? GroceryListItem {
                //Logger.logDetails(msg:"groceryListItem.name = \(groceryListItem.name)")
                var groceryListItemCost = groceryListItem.cost.floatValue * Float(groceryListItem.quantity.doubleValue)
                if groceryListItem.isTaxable.boolValue {
                    groceryListItemCost *= 1.0775
                }
                //Logger.logDetails(msg:"groceryListItemCost = \(groceryListItemCost)")
                projectedCost = NSNumber(value:projectedCost.floatValue + groceryListItemCost)
                //Logger.logDetails(msg:"projectedCost = \(projectedCost)")
            }
        }
        
        DatabaseInterface(concurrencyType: .mainQueueConcurrencyType).saveContext()
        
        return projectedCost.floatValue
    }
    
    func updateAndReturnTotalCost() -> Float {
        totalCost = NSNumber(value: 0.0)
        
        for item in hasItems {
            if let groceryListItem = item as? GroceryListItem {
                if groceryListItem.isBought.boolValue {
                    //Logger.logDetails(msg:"groceryListItem.name = \(groceryListItem.name)")
                    var groceryListItemCost = groceryListItem.cost.floatValue * Float(groceryListItem.quantity.doubleValue)
                    if groceryListItem.isTaxable.boolValue {
                        groceryListItemCost *= 1.0775
                    }
                    //Logger.logDetails(msg:"groceryListItemCost = \(groceryListItemCost)")
                    totalCost = NSNumber(value:totalCost.floatValue + groceryListItemCost)
                    //Logger.logDetails(msg:"totalCost = \(totalCost)")
                }
            }
        }
        
        DatabaseInterface(concurrencyType: .mainQueueConcurrencyType).saveContext()

        return totalCost.floatValue
    }
    
        
    func findGroceryListItemWithName(name: String) -> GroceryListItem? {
        
        var finalName = name
        
        let tRange = name.range(of: "t-")
        if tRange != nil {
            finalName = name.substring(from:tRange!.upperBound)
        } else {
            let parenRange = name.range(of: ") ")
            if parenRange != nil {
                finalName = name.substring(from:parenRange!.upperBound)
            }
        }
        
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        guard let groceryListItems = databaseInterface.entitiesOfType(entityTypeName: "GroceryListItem", predicate: NSPredicate(format: "name MATCHES %@", finalName)) as? Array<GroceryListItem> else {
            return nil
        }
        
        guard groceryListItems.count == 1 else {
            return nil
        }
        
        guard let groceryListItem = groceryListItems.first else {
            return nil
        }
        
        guard groceryListItem.inGroceryList == self else {
            return nil
        }
        
        return groceryListItem
    }
    
    func buyItem(item: GroceryListItem, quantity: Float, cost: Float, taxableStatus: Bool) {
        item.isBought = NSNumber(value: true)
        item.isTaxable = NSNumber(value: taxableStatus)
        item.quantity = NSNumber(value: quantity)
        item.cost = NSNumber(value:cost)
        DatabaseInterface(concurrencyType: .mainQueueConcurrencyType).saveContext()
    }
    
    class func addItemToCurrent(itemName: String, quantity: String, unitOfMeasure: String) {
        
        guard let groceryList = returnCurrentGroceryList() else {
            return
        }
        
        Logger.logDetails(msg: "\(groceryList)")
        
        guard let quantityFloat = Float(quantity) else {
            return
        }
        
        guard let groceryListItem = GroceryListItem.createOrReturn(name: itemName, cost: 0.0, quantity: quantityFloat, unitOfMeasure: unitOfMeasure) else {
            return
        }
        
        groceryList.addHasItemsObject(value: groceryListItem)
        
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        databaseInterface.saveContext()
    }
}
