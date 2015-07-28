//
//  Recipe.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 6/4/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class Recipe: NSManagedObject {

    @NSManaged var instructions: String
    @NSManaged var notes: String
    @NSManaged var servings: NSNumber
    @NSManaged var containsIngredients: NSOrderedSet
    @NSManaged var title: RecipeTitle
    
    func recipeDescription() -> NSString {
        var returnValue: String = "\name: \(title.name)"
        returnValue += "\ninstructions: \(instructions)"
        returnValue += "\nnotes: \(notes)"
        returnValue += "\nindexCharacter: \(title.indexCharacter)"
        returnValue += "\nservings: \(servings.intValue)"
        returnValue += "\ningredient count: \(containsIngredients.count)"
        
        return returnValue
    }
    
    func addContainsIngredientsObject(value:Ingredient)
    {
        self.willChangeValueForKey("containsIngredients")
        
        var tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet: containsIngredients)
        
        tempSet.addObject(value)
        
        self.containsIngredients = tempSet
        
        self.didChangeValueForKey("containsIngredients")
    }
}
