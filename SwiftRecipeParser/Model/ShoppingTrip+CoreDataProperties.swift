//
//  ShoppingTrip+CoreDataProperties.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 1/12/22.
//  Copyright © 2022 CarlSmith. All rights reserved.
//
//

import Foundation
import CoreData

extension ShoppingTrip {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ShoppingTrip> {
        return NSFetchRequest<ShoppingTrip>(entityName: "ShoppingTrip")
    }

    @NSManaged public var groceryLists: NSOrderedSet

}

// MARK: Generated accessors for groceryLists
extension ShoppingTrip {

    @objc(insertObject:inGroceryListsAtIndex:)
    @NSManaged internal func insertIntoGroceryLists(_ value: GroceryList, at idx: Int)

    @objc(removeObjectFromGroceryListsAtIndex:)
    @NSManaged public func removeFromGroceryLists(at idx: Int)

    @objc(insertGroceryLists:atIndexes:)
    @NSManaged internal func insertIntoGroceryLists(_ values: [GroceryList], at indexes: NSIndexSet)

    @objc(removeGroceryListsAtIndexes:)
    @NSManaged public func removeFromGroceryLists(at indexes: NSIndexSet)

    @objc(replaceObjectInGroceryListsAtIndex:withObject:)
    @NSManaged internal func replaceGroceryLists(at idx: Int, with value: GroceryList)

    @objc(replaceGroceryListsAtIndexes:withGroceryLists:)
    @NSManaged internal func replaceGroceryLists(at indexes: NSIndexSet, with values: [GroceryList])

    @objc(addGroceryListsObject:)
    @NSManaged internal func addToGroceryLists(_ value: GroceryList)

    @objc(removeGroceryListsObject:)
    @NSManaged internal func removeFromGroceryLists(_ value: GroceryList)

    @objc(addGroceryLists:)
    @NSManaged public func addToGroceryLists(_ values: NSOrderedSet)

    @objc(removeGroceryLists:)
    @NSManaged public func removeFromGroceryLists(_ values: NSOrderedSet)

}
