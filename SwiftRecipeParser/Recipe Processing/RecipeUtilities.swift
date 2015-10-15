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
        let recipeObjects = DatabaseInterface().entitiesOfType("Recipe", predicate: NSPredicate(format: "title.name == %@", recipeName)) as! [Recipe]
        
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
        
        var recipeDirectory:NSURL = Utilities.applicationDocumentsDirectory()
        
        if (fileIsXML) {
            recipeDirectory = recipeDirectory.URLByAppendingPathComponent("XML_recipes")
        }
        recipeDirectory = recipeDirectory.URLByAppendingPathComponent(recipeIndexChar)
        
        let separatorCharacters:NSCharacterSet = NSCharacterSet(charactersInString: " ,/'")
        
        let fileNameComponents:Array<String> = recipeName.componentsSeparatedByCharactersInSet(separatorCharacters)
        let fileName:String = componentsJoinedByString(fileNameComponents, joinString: "_")
        
        var filePathname: String
        
        if fileIsXML {
            filePathname = recipeDirectory.URLByAppendingPathComponent(fileName).URLByAppendingPathExtension("xml").path!
        }
        else {
            filePathname = recipeDirectory.URLByAppendingPathComponent(fileName).URLByAppendingPathExtension("txt").path!
        }
        
        if !Utilities.directoryExistsAtAbsolutePath(recipeDirectory.path!) {
            do {
                try fileManager.createDirectoryAtPath(recipeDirectory.path!, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                NSLog("Error creating directory at path \(recipeDirectory.path!): \(error)")
            }
            //NSLog(@"recipeDirectory = %@", recipeDirectory)
        }
        
        if Utilities.directoryExistsAtAbsolutePath(recipeDirectory.path!) {
            var fileContents: String
            
            if fileIsXML {
                fileContents = RecipeUtilities.convertRecipeNameToXMLText(recipeName)
            }
            else {
                fileContents = RecipeUtilities.convertRecipeNameToFormattedText(recipeName)
            }
            
            do {
                try fileContents.writeToFile(filePathname, atomically: true, encoding: NSUTF8StringEncoding)
            } catch let error as NSError {
                NSLog("Error writing file at path \(filePathname): \(error)")
                if error.code == 517 {
                    NSLog("fileContents = *%@*", fileContents)
                }
            }
        }
        else {
            NSLog("%@ does not exist, and could not be created", recipeDirectory)
        }
    }
    
    class func convertRecipeNameToXMLText(recipeName:String) -> String {
        var returnValue:String = ""

        let recipe:Recipe? = RecipeUtilities.convertRecipeNameToObject(recipeName)
        
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
        
        let recipe:Recipe? = RecipeUtilities.convertRecipeNameToObject(recipeName)
        
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
                let quantityString:String = FractionMath.doubleToString(ingredient.quantity.doubleValue)
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
        
        let databaseManager:DatabaseManager = DatabaseManager.instance
        
        let context:NSManagedObjectContext = databaseManager.returnMainManagedObjectContext()
        
        let request:NSFetchRequest = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName("Recipe", inManagedObjectContext: context)
        
        request.predicate = NSPredicate(format: "title.name == %@", fileName)
        
        var recipeObjects:[AnyObject]
        do {
            recipeObjects = try context.executeFetchRequest(request)
            
            if recipeObjects.count == 1 {
                recipe = recipeObjects[0] as? Recipe
            }
        } catch let error as NSError {
            NSLog("Error retrieving recipe named \(fileName): \(error)")
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