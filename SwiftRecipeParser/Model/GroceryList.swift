//
//  GroceryList.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/26/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

@objc(GroceryList)
class GroceryList: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var hasItems: NSOrderedSet

}
