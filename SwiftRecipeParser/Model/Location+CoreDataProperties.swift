//
//  Location+CoreDataProperties.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 12/28/22.
//  Copyright © 2022 CarlSmith. All rights reserved.
//
//

import Foundation
import CoreData

extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged var storeName: String?
    @NSManaged var aisle: String?
    @NSManaged var details: String?
    @NSManaged var month: NSNumber?
    @NSManaged var day: NSNumber?
    @NSManaged var year: NSNumber?
    @NSManaged var forItems: NSSet?

}

// MARK: Generated accessors for forItems
extension Location {

    @objc(addForItemsObject:)
    @NSManaged func addToForItems(_ value: GroceryListItem)

    @objc(removeForItemsObject:)
    @NSManaged func removeFromForItems(_ value: GroceryListItem)

    @objc(addForItems:)
    @NSManaged func addToForItems(_ values: NSSet)

    @objc(removeForItems:)
    @NSManaged func removeFromForItems(_ values: NSSet)

}
