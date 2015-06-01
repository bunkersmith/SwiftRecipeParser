//
//  GroceryItem.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/26/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

@objc(GroceryItem)
class GroceryItem: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var containedInIngredients: NSSet
    @NSManaged var hasLocations: NSSet
    @NSManaged var inGroceryLists: NSSet
    
    override var description: String {
        var returnValue:String
        
        returnValue = "\n***** GroceryItem"
        returnValue += "\nname = \(name)"
        
        return returnValue
    }
    
    class func count() -> Int {
        var groceryItemCount:Int
        var databaseInterface:DatabaseInterface = DatabaseInterface()
        groceryItemCount = databaseInterface.countOfEntitiesOfType("GroceryItem", fetchRequestChangeBlock:nil)
        
        return groceryItemCount
    }
    
    /*
    var groceryItems:[GroceryItem]
    groceryItems = mainDatabaseInterface.entitiesOfType("GroceryItem", fetchRequestChangeBlock:{inputFetchRequest in
    return inputFetchRequest
    }) as [GroceryItem]
    
    NSLog("groceryItems = \(groceryItems)")
    */

}
