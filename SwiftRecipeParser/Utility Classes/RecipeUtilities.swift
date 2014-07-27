//
//  RecipeUtilities.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/27/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import Foundation

class RecipeUtilities {
    
    class func countOfRecipes() -> Int {
        let databaseInterface:DatabaseInterface = DatabaseInterface()

        return databaseInterface.countOfEntitiesOfType("Recipe", fetchRequestChangeBlock: nil)
    }
}