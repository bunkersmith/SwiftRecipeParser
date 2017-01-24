//
//  RecipeTitle.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 6/4/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class RecipeTitle: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var indexCharacter: String
    @NSManaged var forRecipe: Recipe

}
