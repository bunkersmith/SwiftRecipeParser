//
//  Ingredient.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/26/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class Ingredient: NSManagedObject {

    @NSManaged var processingInstructions: String
    @NSManaged var quantity: NSNumber
    @NSManaged var unitOfMeasure: String
    @NSManaged var containedInRecipes: NSSet
    @NSManaged var ingredientItem: RecipeItem

    func stringForPrinting() -> String {
        var returnValue = ""
        
        if quantity.intValue == 0 && unitOfMeasure == "-"
        {
            if ingredientItem.name == "-"
            {
                returnValue = " "
            }
            else
            {
                returnValue = ingredientItem.name
            }
        } else {
            let quantityString = FractionMath.doubleToString(inputDouble: quantity.doubleValue)
            returnValue = quantityString + "\t \(unitOfMeasure)\t\(ingredientItem.name)"
        }

        return returnValue + "\n"
    }
}
