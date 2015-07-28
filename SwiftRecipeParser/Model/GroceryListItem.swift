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
        if let groceryListItems = DatabaseInterface().entitiesOfType("GroceryListItem", predicate: NSPredicate(format: "name MATCHES %@", name)) as? Array<GroceryListItem> {
            if groceryListItems.count == 1 {
                return groceryListItems.first
            }
        }
        return nil
    }
    
}
