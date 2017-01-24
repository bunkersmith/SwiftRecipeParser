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
    }
    
    class func setCurrentGroceryList(groceryListName:String, databaseInterfacePtr:DatabaseInterface)
    {
        let groceryLists:Array<GroceryList> = databaseInterfacePtr.entitiesOfType(entityTypeName:"GroceryList", predicate:nil) as! Array<GroceryList>
        for groceryList:GroceryList in groceryLists {
            if groceryList.name == groceryListName {
                groceryList.isCurrent = NSNumber(value: true);
            }
            else {
                groceryList.isCurrent = NSNumber(value: false);
            }
        }
        databaseInterfacePtr.saveContext();
    }
    
    class func returnCurrentGroceryListWithDatabaseInterfacePtr(databaseInterfacePtr:DatabaseInterface) -> GroceryList?
    {
        var returnValue:GroceryList? = nil
    
        let groceryLists:Array<GroceryList> = databaseInterfacePtr.entitiesOfType(entityTypeName:"GroceryList", predicate:NSPredicate(format:"isCurrent == %@", NSNumber(value: true))) as! Array<GroceryList>
    
        if (groceryLists.count == 1) {
            returnValue = groceryLists.first
        }
    
        return returnValue;
    }

    class func returnGroceryListWithName(name: String) -> GroceryList? {
        var returnValue:GroceryList? = nil
        
        let databaseInterfacePtr = DatabaseInterface()
        
        let groceryLists:Array<GroceryList> = databaseInterfacePtr.entitiesOfType(entityTypeName:"GroceryList", predicate:NSPredicate(format:"name == %@", name)) as! Array<GroceryList>
        
        if (groceryLists.count == 1) {
            returnValue = groceryLists.first
        }
        
        return returnValue
    }
    
    func updateProjectedCost() -> Float {
        projectedCost = NSNumber(value: 0.0)
        
        for item in hasItems {
            if let groceryListItem = item as? GroceryListItem {
                projectedCost = NSNumber(value:projectedCost.floatValue + groceryListItem.cost.floatValue)
            }
        }

        return projectedCost.floatValue
    }
}
