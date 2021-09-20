//
//  RecipeItem+CoreDataProperties.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 1/14/21.
//  Copyright © 2021 CarlSmith. All rights reserved.
//
//

import Foundation
import CoreData

extension RecipeItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecipeItem> {
        return NSFetchRequest<RecipeItem>(entityName: "RecipeItem")
    }

    @NSManaged public var name: String
    @NSManaged public var containedInIngredients: NSSet

}

// MARK: Generated accessors for containedInIngredients
extension RecipeItem {

    @objc(addContainedInIngredientsObject:)
    @NSManaged func addToContainedInIngredients(_ value: Ingredient)

    @objc(removeContainedInIngredientsObject:)
    @NSManaged func removeFromContainedInIngredients(_ value: Ingredient)

    @objc(addContainedInIngredients:)
    @NSManaged func addToContainedInIngredients(_ values: NSSet)

    @objc(removeContainedInIngredients:)
    @NSManaged func removeFromContainedInIngredients(_ values: NSSet)

}
