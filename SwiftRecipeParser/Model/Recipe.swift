//
//  Recipe.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/26/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

@objc(Recipe)
class Recipe: NSManagedObject {

    @NSManaged var indexCharacter: String
    @NSManaged var instructions: String
    @NSManaged var name: String
    @NSManaged var notes: String
    @NSManaged var servings: NSNumber
    @NSManaged var containsIngredients: NSOrderedSet

}
