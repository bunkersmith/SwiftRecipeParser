//
//  RecipeUtilities.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 8/6/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class RecipeUtilities {
    
    class func fetchRecipeWithName(recipeName: String) -> Recipe? {
        var recipeObjects = DatabaseInterface().entitiesOfType("Recipe", predicate: NSPredicate(format: "title.name == %@", recipeName)) as! [Recipe]
        
        if recipeObjects.count == 1 {
            return recipeObjects.first
        }
        
        return nil
    }
    
    class func countOfRecipes() -> Int {
        let databaseInterface:DatabaseInterface = DatabaseInterface()
        
        return databaseInterface.countOfEntitiesOfType("Recipe", predicate: nil)
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
        let fileManager:NSFileManager = NSFileManager.defaultManager()
        
        var recipeDirectory:String = Utilities.applicationDocumentsDirectory().path!
        
        if (fileIsXML) {
            recipeDirectory = recipeDirectory.stringByAppendingPathComponent("XML_recipes")
        }
        recipeDirectory = recipeDirectory.stringByAppendingPathComponent(recipeIndexChar)
        
        let separatorCharacters:NSCharacterSet = NSCharacterSet(charactersInString: " ,/'")
        
        var fileNameComponents:Array<String> = recipeName.componentsSeparatedByCharactersInSet(separatorCharacters)
        var fileName:String = componentsJoinedByString(fileNameComponents, joinString: "_")
        
        var filePathname: String
        
        if fileIsXML {
            filePathname = recipeDirectory.stringByAppendingPathComponent(fileName.stringByAppendingPathExtension("xml")!)
        }
        else {
            filePathname = recipeDirectory.stringByAppendingPathComponent(fileName.stringByAppendingPathExtension("txt")!)
        }
        
        var error:NSError?
        
        if !Utilities.directoryExistsAtAbsolutePath(recipeDirectory) {
            fileManager.createDirectoryAtPath(recipeDirectory, withIntermediateDirectories: true, attributes: nil, error: &error)
            //NSLog(@"recipeDirectory = %@", recipeDirectory)
        }
        
        if Utilities.directoryExistsAtAbsolutePath(recipeDirectory) {
            var fileContents: String
            
            if fileIsXML {
                fileContents = RecipeUtilities.convertRecipeNameToXMLText(recipeName)
            }
            else {
                fileContents = RecipeUtilities.convertRecipeNameToFormattedText(recipeName)
            }
            
            var fileWritten: Bool
            
            fileWritten = fileContents.writeToFile(filePathname, atomically: true, encoding: NSUTF8StringEncoding, error: &error)
            
            
            if fileWritten == false {
                NSLog("Error writing to %@", filePathname)
                
                if error != nil {
                    NSLog("error: \(error)")
                    
                    if error!.code == 517 {
                        NSLog("fileContents = *%@*", fileContents)
                    }
                }
            }
        }
        else {
            NSLog("%@ does not exist, and could not be created", recipeDirectory)
        }
    }
    
    class func convertRecipeNameToXMLText(recipeName:String) -> String {
        var returnValue:String = ""

        var recipe:Recipe? = RecipeUtilities.convertRecipeNameToObject(recipeName)
        
        if recipe != nil {
            returnValue = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
            returnValue = returnValue.stringByAppendingString("<recipe>\n")
            returnValue = returnValue.stringByAppendingString("    <name>\(recipe!.title.name)</name>\n")
            returnValue = returnValue.stringByAppendingString("    <indexCharacter>\(recipe!.title.indexCharacter)</indexCharacter>\n")
            returnValue = returnValue.stringByAppendingString("    <notes>\(recipe!.notes)</notes>\n")
            returnValue = returnValue.stringByAppendingString("    <servings>\(recipe!.servings.intValue)</servings>\n")
            returnValue = returnValue.stringByAppendingString("    <instructions>\(recipe!.instructions)</instructions>\n")
            
            var ingredient:Ingredient
            
            returnValue = returnValue.stringByAppendingString("    <ingredients>\n")
            
            for i in 0 ..< recipe!.containsIngredients.count {
                ingredient = recipe!.containsIngredients[i] as! Ingredient
                    
                returnValue = returnValue.stringByAppendingString("        <ingredient>\n")
                
                returnValue = returnValue.stringByAppendingString("            <quantity>\(ingredient.quantity.doubleValue)</quantity>\n")
                returnValue = returnValue.stringByAppendingString("            <unitOfMeasure>\(ingredient.unitOfMeasure)</unitOfMeasure>\n")
                returnValue = returnValue.stringByAppendingString("            <ingredientName>\(ingredient.ingredientItem.name)</ingredientName>\n")
                returnValue = returnValue.stringByAppendingString("            <processingInstructions>\(ingredient.processingInstructions)</processingInstructions>\n")
                
                returnValue = returnValue.stringByAppendingString("        </ingredient>\n")
            }
    
            returnValue = returnValue.stringByAppendingString("    </ingredients>\n")
            returnValue = returnValue.stringByAppendingString("</recipe>\n")
        }
    
        return returnValue
    }
    
    class func convertRecipeNameToFormattedText(recipeName:String) -> String {
        var returnValue:String = "\(recipeName)\n\n"
        
        var recipe:Recipe? = RecipeUtilities.convertRecipeNameToObject(recipeName)
        
        returnValue = returnValue.stringByAppendingString("Notes:\n\(recipe!.notes)\n\n")
    
        if recipe!.servings.integerValue > 0 {
            returnValue = returnValue.stringByAppendingString("Servings:\(recipe!.servings.integerValue)\n\n")
        }
        
        var ingredient:Ingredient
        
        if recipe!.containsIngredients.count > 0 {
            returnValue = returnValue.stringByAppendingString("Ingredients:\n")
        }
        
        for i in 0 ..< recipe!.containsIngredients.count {
            ingredient = recipe!.containsIngredients[i] as! Ingredient
            
            if ingredient.quantity.doubleValue == 0 && ingredient.unitOfMeasure == "-" {
                if ingredient.ingredientItem.name == "-" {
                    returnValue = returnValue.stringByAppendingString("\n")
                }
                else {
                    returnValue = returnValue.stringByAppendingString("\(ingredient.ingredientItem.name)\n")
                }
            }
            else {
                var quantityString:String = FractionMath.doubleToString(ingredient.quantity.doubleValue)
                returnValue = returnValue.stringByAppendingString("\(quantityString)\t\(ingredient.unitOfMeasure)\t\(ingredient.ingredientItem.name)\n")
            }
        }
        
        if recipe!.containsIngredients.count > 0 {
            returnValue = returnValue.stringByAppendingString("\n")
        }
        
        returnValue = returnValue.stringByAppendingString("Instructions:\n%\(recipe!.instructions)\n\n")
    
        return returnValue
    }
    
    class func convertRecipeNameToObject(fileName:String) -> Recipe?
    {
        var recipe:Recipe? = nil
        
        var databaseManager:DatabaseManager = DatabaseManager.instance
        
        var context:NSManagedObjectContext = databaseManager.returnMainManagedObjectContext()
        
        var request:NSFetchRequest = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName("Recipe", inManagedObjectContext: context)
        
        request.predicate = NSPredicate(format: "title.name == %@", fileName)
        
        var error:NSError?
        var recipeObjects:Array<Recipe> = context.executeFetchRequest(request, error:&error) as! Array<Recipe>
        
        if recipeObjects.count == 1 {
            recipe = recipeObjects[0] as Recipe
        }
        
        return recipe
    }
    
    class func outputAllRecipesToFiles(inXMLFormat:Bool)
    {
        let databaseManager:DatabaseManager = DatabaseManager.instance
        
        databaseManager.backgroundOperation(
        {
            let databaseInterface:DatabaseInterface = DatabaseInterface()
            
            let recipes:Array<Recipe> = databaseInterface.entitiesOfType("Recipe", fetchRequestChangeBlock:{
                inputFetchRequest in
                inputFetchRequest.propertiesToFetch = ["name", "indexCharacter"]
                let sortDescriptor:NSSortDescriptor = NSSortDescriptor(key: "name", ascending: false)
                inputFetchRequest.sortDescriptors = [sortDescriptor]
                return inputFetchRequest
            }) as! Array<Recipe>
            
            var currentRecipe:Recipe
            
            let recipeDirectory:String = Utilities.applicationDocumentsDirectory().path!
            NSLog("recipeDirectory = %@", recipeDirectory)
            
            for i in 0 ..< recipes.count
            {
                currentRecipe = recipes[i]
                
                self.outputRecipeToFile(currentRecipe.title.name, recipeIndexChar:currentRecipe.title.indexCharacter, fileIsXML:inXMLFormat)
            }
        })
    }
    
}