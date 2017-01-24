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
    @NSManaged var hasItems: NSOrderedSet
    
    
    func addHasItemsObject(value:GroceryListItem)
    {
        self.willChangeValueForKey("hasItems");
        var tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.hasItems);
        tempSet.addObject(value);
        self.hasItems = tempSet;
        self.didChangeValueForKey("hasItems");
    }
    
    func removeHasItemsObject(value:GroceryListItem)
    {
        self.willChangeValueForKey("hasItems");
        var tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.hasItems);
        tempSet.removeObject(value);
        self.hasItems = tempSet;
        self.didChangeValueForKey("hasItems");
    }
    
    class func setCurrentGroceryList(groceryListName:String, databaseInterfacePtr:DatabaseInterface)
    {
        var groceryLists:Array<GroceryList> = databaseInterfacePtr.entitiesOfType("GroceryList", fetchRequestChangeBlock:nil) as! Array<GroceryList>
        for groceryList:GroceryList in groceryLists {
            if groceryList.name == groceryListName {
                groceryList.isCurrent = NSNumber(bool: true);
            }
            else {
                groceryList.isCurrent = NSNumber(bool: false);
            }
        }
        databaseInterfacePtr.saveContext();
    }
    
    class func returnCurrentGroceryListWithDatabaseInterfacePtr(databaseInterfacePtr:DatabaseInterface) -> GroceryList?
    {
        var returnValue:GroceryList?
    
        var groceryLists:Array<GroceryList> = databaseInterfacePtr.entitiesOfType("GroceryList", fetchRequestChangeBlock:{
            inputFetchRequest in
            inputFetchRequest.predicate = NSPredicate(format:"isCurrent == %@", NSNumber(bool: true))
            return inputFetchRequest;
        }) as! Array<GroceryList>
    
        if (groceryLists.count == 1) {
            returnValue = groceryLists.first
        }
    
    return returnValue;
    }

}
