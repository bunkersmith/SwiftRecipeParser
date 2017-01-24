//
//  GroceryListItem.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 6/3/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class GroceryListItem: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var totalQuantity: NSNumber
    @NSManaged var cost: NSNumber
    @NSManaged var unitOfMeasure: String
    @NSManaged var inGroceryList: GroceryList

}
