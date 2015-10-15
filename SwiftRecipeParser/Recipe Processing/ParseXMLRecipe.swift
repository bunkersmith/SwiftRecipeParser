//
//  ParseXMLRecipe.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 8/6/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import Foundation

class ParseXMLRecipe : NSObject, NSXMLParserDelegate {
    
    enum currentElementState
    {
        case noState
        case recipeState
        case nameState
        case indexCharacterState
        case notesState
        case servingsState
        case instructionsState
        case ingredientsState
        case ingredientState
        case quantityState
        case unitOfMeasureState
        case ingredientNameState
        case processingInstructionsState
    }
    
    var currentStateStack:Array<currentElementState>
    var localDatabaseInterface:DatabaseInterface?
    var currentRecipe:Recipe?
    var currentRecipeTitle:RecipeTitle?
    var currentIngredient:Ingredient?
    var currentElementString:String
    
    override init() {
        currentElementString = ""
        currentStateStack = Array()
        currentStateStack.append(currentElementState.noState)
        super.init()
    }
    
    func parseRecipeFromXMLData(recipeFileData:NSData,  databaseInterface:DatabaseInterface) {
        let xmlparser:NSXMLParser = NSXMLParser(data: recipeFileData)
        
        localDatabaseInterface = databaseInterface
        
        xmlparser.delegate = self
        
        let success:Bool = xmlparser.parse()
        
        if (!success) {
            NSLog("Error Error Error!!!")
        }
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        //NSLog("didStartElement: %@", elementName)
    
        currentElementString = ""
        
        let currentState:currentElementState = startProcessingForElement(elementName)
        currentStateStack.append(currentState)
    }
    
    func startProcessingForElement(elementName:NSString) -> currentElementState {
        if elementName.isEqualToString("quantity") {
            //NSLog(@"notes element found...")
            return currentElementState.quantityState
        }
        if elementName.isEqualToString("unitOfMeasure") {
            //NSLog(@"notes element found...")
            return currentElementState.unitOfMeasureState
        }
        if elementName.isEqualToString("ingredientName") {
            //NSLog(@"notes element found...")
            return currentElementState.ingredientNameState
        }
        if elementName.isEqualToString("processingInstructions") {
            //NSLog(@"notes element found...")
            return currentElementState.processingInstructionsState
        }
        if elementName.isEqualToString("ingredient") {
            //NSLog(@"ingredient element found – create a new instance of Ingredient class...")
            if localDatabaseInterface != nil {
                currentIngredient = (localDatabaseInterface!.newManagedObjectOfType("Ingredient") as! Ingredient)
                return currentElementState.ingredientState
            }
        }
        if elementName.isEqualToString("ingredients") {
            return currentElementState.ingredientsState
        }
        if elementName.isEqualToString("name") {
            //NSLog(@"notes element found...")
            return currentElementState.nameState
        }
        if elementName.isEqualToString("indexCharacter") {
            //NSLog(@"indexCharacter element found...")
            return currentElementState.indexCharacterState
        }
        if elementName.isEqualToString("notes") {
            //NSLog(@"notes element found...")
            return currentElementState.notesState
        }
        if elementName.isEqualToString("servings") {
            //NSLog(@"servings element found...")
            return currentElementState.servingsState
        }
        if elementName.isEqualToString("instructions") {
            //NSLog(@"instructions element found...")
            return currentElementState.instructionsState
        }
        if elementName.isEqualToString("recipe") {
            //NSLog(@"recipe element found – create a new instance of Recipe class...")
            if localDatabaseInterface != nil {
                currentRecipe = (localDatabaseInterface!.newManagedObjectOfType("Recipe") as! Recipe)
                if currentRecipe != nil {
                    currentRecipe!.notes = ""
                }
                return currentElementState.recipeState
            }
        }
        
        return currentElementState.noState
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        let squashed:NSString = string
        squashed.stringByReplacingOccurrencesOfString("\\s+", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: NSMakeRange(0, squashed.length))
        if (squashed.length > 0) {
            currentElementString += string
        }
    }
    
    func processValueForState(currentState:currentElementState, elementValue:NSString) {
    
        switch (currentState) {
            case currentElementState.noState:
            break
            
            case currentElementState.recipeState:
            break
            
            case currentElementState.nameState:
                if currentRecipe != nil {
                    currentRecipeTitle = localDatabaseInterface?.newManagedObjectOfType("RecipeTitle") as? RecipeTitle
                    currentRecipeTitle!.name = elementValue as String
                }
            break
            
            case currentElementState.indexCharacterState:
                if currentRecipe != nil && currentRecipeTitle != nil {
                    currentRecipeTitle!.indexCharacter = elementValue as String
                }
            break
            
            case currentElementState.notesState:
                if elementValue.isEqualToString("(null)") {
                    if currentRecipe != nil {
                        currentRecipe!.notes = ""
                    }
                }
                else {
                    if currentRecipe != nil {
                        currentRecipe!.notes = elementValue as String
                    }
                }
            break
            
            case currentElementState.servingsState:
                if currentRecipe != nil {
                    currentRecipe!.servings = NSNumber(integer: elementValue.integerValue)
                }
            break
            
            case currentElementState.instructionsState:
                if currentRecipe != nil {
                    currentRecipe!.instructions = elementValue as String
                }
            break
            
            case currentElementState.ingredientsState:
            break
            
            case currentElementState.ingredientState:
            break
            
            case currentElementState.quantityState:
                if currentIngredient != nil {
                    currentIngredient!.quantity = NSNumber(double: FractionMath.stringToDouble(elementValue as String))
                }
            break
            
            case currentElementState.unitOfMeasureState:
                if currentIngredient != nil {
                    currentIngredient!.unitOfMeasure = elementValue as String
                }
            break
            
            case currentElementState.ingredientNameState:
            //NSLog(@"Ingredient Name: %@", elementValue)
                if localDatabaseInterface != nil {
                    let groceryItem:GroceryItem = localDatabaseInterface!.newManagedObjectOfType("GroceryItem") as! GroceryItem
                    groceryItem.name = elementValue as String
                    if currentIngredient != nil {
                        currentIngredient!.processingInstructions = ""
                        currentIngredient!.ingredientItem = groceryItem
                    }
                }
            break
            
            case currentElementState.processingInstructionsState:
                if currentIngredient != nil {
                    currentIngredient!.processingInstructions = elementValue as String
                }
            break
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        //NSLog(@"didEndElement: %@", elementName)
        let currentState:currentElementState  = currentStateStack[currentStateStack.endIndex - 1]
        
        processValueForState(currentState, elementValue:currentElementString)

        if currentState == currentElementState.ingredientState {
            if currentRecipe != nil && currentIngredient != nil {
                currentRecipe!.addContainsIngredientsObject(currentIngredient!)
            }
        }
        else {
            if currentState == currentElementState.recipeState {
                //NSLog("currentRecipe: \(currentRecipe!.recipeDescription())")
                if (currentRecipe != nil && currentRecipeTitle != nil) {
                    currentRecipe!.title = currentRecipeTitle!
                }
                if localDatabaseInterface != nil {
                    localDatabaseInterface!.saveContext()
                }
            }
        }
        currentStateStack.removeLast()
    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError)  {
        NSLog("ParseXMLRecipe:parseErrorOccurred called with error %@", parseError)
    }
    
}