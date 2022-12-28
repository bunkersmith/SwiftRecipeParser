//
//  Location+CoreDataProperties.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 12/27/22.
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
    @NSManaged var forItem: GroceryListItem?

}
