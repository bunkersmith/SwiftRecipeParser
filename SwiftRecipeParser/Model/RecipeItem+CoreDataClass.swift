//
//  RecipeItem+CoreDataClass.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 1/14/21.
//  Copyright © 2021 CarlSmith. All rights reserved.
//
//

import Foundation
import CoreData


public class RecipeItem: NSManagedObject {

// THIS CLASS MERELY EXISTS TO AVOID THE CREATION OF MANY DIFFERENT Ingredients WITH THE SAME NAME,
// BUT ALL WITH DIFFERENT Quantitys, Units Of Measure and Processing Instructions
        

    class func create(databaseInterface: DatabaseInterface, recipeItemName: String) -> RecipeItem {
        let recipeItem = databaseInterface.newManagedObjectOfType(managedObjectClassName: "RecipeItem") as! RecipeItem
        recipeItem.name = recipeItemName
        return recipeItem
    }
    
    class func createOrReturn(databaseInterface: DatabaseInterface, recipeItemName: String) -> RecipeItem {
        let recipeItems = databaseInterface.entitiesOfType(entityTypeName: "RecipeItem", predicate: NSPredicate(format: "name == %@", recipeItemName))
        if recipeItems.count == 0 {
            return create(databaseInterface: databaseInterface, recipeItemName: recipeItemName)
        } else {
            if recipeItems.count > 1 {
                for i in 1..<recipeItems.count {
                    if let recipeItem = recipeItems[i] as? RecipeItem {
                        databaseInterface.deleteObject(coreDataObject: recipeItem)
                    }
                }
            }
            return recipeItems.first as! RecipeItem
        }
    }
}
