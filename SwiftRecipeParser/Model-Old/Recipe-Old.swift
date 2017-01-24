//
//  Recipe.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/26/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class Recipe: NSManagedObject {

    @NSManaged var indexCharacter: String
    @NSManaged var instructions: String
    @NSManaged var name: String
    @NSManaged var notes: String
    @NSManaged var servings: NSNumber
    @NSManaged var containsIngredients: NSOrderedSet

    func recipeDescription() -> NSString {
        var returnValue: String = "\name: \(name)"
        returnValue += "\ninstructions: \(instructions)"
        returnValue += "\nnotes: \(notes)"
        returnValue += "\nindexCharacter: \(indexCharacter)"
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
