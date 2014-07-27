//
//  Ingredient.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/26/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

@objc(Ingredient)
class Ingredient: NSManagedObject {

    @NSManaged var processingInstructions: String
    @NSManaged var quantity: NSNumber
    @NSManaged var unitOfMeasure: String
    @NSManaged var containedInRecipes: NSSet
    @NSManaged var ingredientItem: GroceryItem

}
