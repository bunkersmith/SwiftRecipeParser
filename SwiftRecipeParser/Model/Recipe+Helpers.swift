//
//  Recipe+Helpers.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 8/29/17.
//  Copyright © 2017 CarlSmith. All rights reserved.
//

import UIKit
import CoreData

extension Recipe {
    
    class func fetchRecipeWithName(recipeName: String) -> Recipe? {
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        
        let recipeObjects = databaseInterface.entitiesOfType(entityTypeName: "Recipe", predicate: NSPredicate(format: "title.name == %@", recipeName)) as! [Recipe]
        
        if recipeObjects.count == 1 {
            return recipeObjects.first
        }
        
        return nil
    }
    
    class func countOfDatabaseRecipes() -> Int {
        let databaseInterface:DatabaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        
        return databaseInterface.countOfEntitiesOfType(entityTypeName: "Recipe", predicate: nil)
    }
    
    class func componentsJoinedByString(components:Array<String>, joinString:String) -> String {
        var returnValue:String = ""
        
        for i in 0 ..< components.count {
            returnValue = returnValue + components[i]
            if i != components.count - 1 {
                returnValue = returnValue + joinString
            }
        }
        
        return returnValue
    }
    
    class func outputRecipeToFile(recipeName:String, recipeIndexChar:String, fileIsXML:Bool)
    {
        let fileManager:FileManager = FileManager.default
        
        var recipeDirectory:URL = FileUtilities.applicationDocumentsDirectory()
        
        if (fileIsXML) {
            recipeDirectory = recipeDirectory.appendingPathComponent("XML_recipes")
        }
        recipeDirectory = recipeDirectory.appendingPathComponent(recipeIndexChar)
        
        let separatorCharacters:NSCharacterSet = NSCharacterSet(charactersIn: " ,/'")
        
        let fileNameComponents:Array<String> = recipeName.components(separatedBy: separatorCharacters as CharacterSet)
        let fileName:String = componentsJoinedByString(components: fileNameComponents, joinString: "_")
        
        var filePathname: URL
        
        if fileIsXML {
            filePathname = recipeDirectory.appendingPathComponent(fileName).appendingPathExtension("xml")
        }
        else {
            filePathname = recipeDirectory.appendingPathComponent(fileName).appendingPathExtension("txt")
        }
        
        if !Utilities.directoryExistsAtAbsolutePath(pathname: recipeDirectory.path) {
            do {
                try fileManager.createDirectory(atPath: recipeDirectory.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                Logger.logDetails(msg: "Error creating directory at path \(recipeDirectory.path): \(error)")
            }
            //NSLog(@"recipeDirectory = %@", recipeDirectory)
        }
        
        if Utilities.directoryExistsAtAbsolutePath(pathname: recipeDirectory.path) {
            var fileContents: String
            
            if fileIsXML {
                fileContents = Recipe.convertRecipeNameToXMLText(recipeName: recipeName)
            }
            else {
                fileContents = Recipe.convertRecipeNameToFormattedText(recipeName)
            }
            
            do {
                try fileContents.write(toFile: filePathname.path, atomically: true, encoding: String.Encoding.utf8)
            } catch let error as NSError {
                Logger.logDetails(msg: "Error writing file at path \(filePathname): \(error)")
                if error.code == 517 {
                    Logger.logDetails(msg: "fileContents = *\(fileContents)*")
                }
            }
        }
        else {
            Logger.logDetails(msg: "\(recipeDirectory) does not exist, and could not be created")
        }
    }
    
    class func convertRecipeNameToXMLText(recipeName:String) -> String {
        var returnValue:String = ""
        
        let recipe:Recipe? = Recipe.findRecipeByName(recipeName)
        
        if recipe != nil {
            returnValue = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
            returnValue = returnValue.appending("<recipe>\n")
            returnValue = returnValue.appending("    <name>\(recipe!.title.name)</name>\n")
            returnValue = returnValue.appending("    <indexCharacter>\(recipe!.title.indexCharacter)</indexCharacter>\n")
            returnValue = returnValue.appending("    <notes>\(recipe!.notes)</notes>\n")
            returnValue = returnValue.appending("    <servings>\(recipe!.servings.intValue)</servings>\n")
            returnValue = returnValue.appending("    <instructions>\(recipe!.instructions)</instructions>\n")
            
            var ingredient:Ingredient
            
            returnValue = returnValue.appending("    <ingredients>\n")
            
            for i in 0 ..< recipe!.containsIngredients.count {
                ingredient = recipe!.containsIngredients[i] as! Ingredient
                
                returnValue = returnValue.appending("        <ingredient>\n")
                
                returnValue = returnValue.appending("            <quantity>\(ingredient.quantity.doubleValue)</quantity>\n")
                returnValue = returnValue.appending("            <unitOfMeasure>\(ingredient.unitOfMeasure)</unitOfMeasure>\n")
                returnValue = returnValue.appending("            <ingredientName>\(ingredient.ingredientItem.name)</ingredientName>\n")
                returnValue = returnValue.appending("            <processingInstructions>\(ingredient.processingInstructions)</processingInstructions>\n")
                
                returnValue = returnValue.appending("        </ingredient>\n")
            }
            
            returnValue = returnValue.appending("    </ingredients>\n")
            returnValue = returnValue.appending("</recipe>\n")
        }
        
        return returnValue
    }
        
    class func convertRecipeNameToFormattedIngredients(_ recipeName:String) -> String {
        var returnValue:String = ""
        
        guard let recipe:Recipe = findRecipeByName(recipeName) else {
            return returnValue
        }
        
        for i in 0 ..< recipe.containsIngredients.count {
            let ingredient = recipe.containsIngredients[i] as! Ingredient
            
            if ingredient.quantity.doubleValue == 0 && ingredient.unitOfMeasure == "-" {
                if ingredient.ingredientItem.name == "-" {
                    returnValue = returnValue.appending("\n")
                }
                else {
                    returnValue = returnValue.appending("\(ingredient.ingredientItem.name)\n")
                }
            }
            else {
                let quantityString:String = FractionMath.doubleToString(inputDouble: ingredient.quantity.doubleValue)
                returnValue = returnValue.appending("\(quantityString)\t\(ingredient.unitOfMeasure)\t\(ingredient.ingredientItem.name)\n")
            }
        }
        
        return returnValue
    }
    
    class func convertRecipeNameToFormattedText(_ recipeName:String) -> String {
        var returnValue:String = "\(recipeName)\n\n"
        
        let recipe:Recipe? = findRecipeByName(recipeName)
        
        returnValue = returnValue.appending("Notes:\n\(recipe!.notes)\n\n")
        
        if recipe!.servings.intValue > 0 {
            returnValue = returnValue.appending("Servings:\(recipe!.servings.intValue)\n\n")
        }
        
        var ingredient:Ingredient
        
        if recipe!.containsIngredients.count > 0 {
            returnValue = returnValue.appending("Ingredients:\n")
        }
        
        for i in 0 ..< recipe!.containsIngredients.count {
            ingredient = recipe!.containsIngredients[i] as! Ingredient
            
            if ingredient.quantity.doubleValue == 0 && ingredient.unitOfMeasure == "-" {
                if ingredient.ingredientItem.name == "-" {
                    returnValue = returnValue.appending("\n")
                }
                else {
                    returnValue = returnValue.appending("\(ingredient.ingredientItem.name)\n")
                }
            }
            else {
                let quantityString:String = FractionMath.doubleToString(inputDouble: ingredient.quantity.doubleValue)
                returnValue = returnValue.appending("\(quantityString)\t\(ingredient.unitOfMeasure)\t\(ingredient.ingredientItem.name)\n")
            }
        }
        
        if recipe!.containsIngredients.count > 0 {
            returnValue = returnValue.appending("\n")
        }
        
        returnValue = returnValue.appending("Instructions:\n%\(recipe!.instructions)\n\n")
        
        return returnValue
    }
    
    class func findRecipeByName(_ recipeName:String) -> Recipe?
    {
        var recipe:Recipe? = nil
        
        let databaseManager:DatabaseManager = DatabaseManager.instance
        
        let context:NSManagedObjectContext = databaseManager.returnMainManagedObjectContext()
        
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Recipe")
        
        request.predicate = NSPredicate(format: "title.name == %@", recipeName)
        
        var recipeObjects:[Any]
        do {
            recipeObjects = try context.fetch(request)
            
            if recipeObjects.count == 1 {
                recipe = recipeObjects[0] as? Recipe
            }
        } catch let error as NSError {
            Logger.logDetails(msg: "Error retrieving recipe named \(recipeName): \(error)")
        }
        
        return recipe
    }
    
    class func outputAllRecipesToFiles(inXMLFormat:Bool)
    {
        let databaseInterface = DatabaseInterface(concurrencyType: .privateQueueConcurrencyType)
        
        databaseInterface.performInBackground {
            
            let recipes:Array<Recipe> = databaseInterface.entitiesOfType(entityTypeName: "Recipe", fetchRequestChangeBlock:{
                inputFetchRequest in
                inputFetchRequest.propertiesToFetch = ["name", "indexCharacter"]
                let sortDescriptor:NSSortDescriptor = NSSortDescriptor(key: "name", ascending: false)
                inputFetchRequest.sortDescriptors = [sortDescriptor]
                return inputFetchRequest
            }) as! Array<Recipe>
            
            var currentRecipe:Recipe
            
            let recipeDirectory:String = FileUtilities.applicationDocumentsDirectory().path
            Logger.logDetails(msg: "recipeDirectory = %\(recipeDirectory)")
            
            for i in 0 ..< recipes.count
            {
                currentRecipe = recipes[i]
                
                self.outputRecipeToFile(recipeName: currentRecipe.title.name, recipeIndexChar:currentRecipe.title.indexCharacter, fileIsXML:inXMLFormat)
            }
        }
    }
    
}
