//
//  ParseXMLRecipe.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 8/6/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import Foundation

class ParseXMLRecipe : NSObject, XMLParserDelegate {
    
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
    
    func parseRecipeFromXMLData(recipeFileData:NSData,  databaseInterface:DatabaseInterface) -> Bool {
        let xmlparser:XMLParser = XMLParser(data: recipeFileData as Data)
        
        localDatabaseInterface = databaseInterface
        
        xmlparser.delegate = self
        
        let success:Bool = xmlparser.parse()
        
        if (!success) {
            Logger.logDetails(msg: "Error Error Error!!!")
        }
        
        return success
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        // NSLog("didStartElement: %@", elementName)
    
        currentElementString = ""
        
        let currentState:currentElementState = startProcessingForElement(elementName: elementName as NSString)
        currentStateStack.append(currentState)
    }
    
    func startProcessingForElement(elementName:NSString) -> currentElementState {
        if elementName.isEqual(to: "quantity") {
            // NSLog("notes element found...")
            return currentElementState.quantityState
        }
        if elementName.isEqual(to: "unitOfMeasure") {
            // NSLog("notes element found...")
            return currentElementState.unitOfMeasureState
        }
        if elementName.isEqual(to: "ingredientName") {
            // NSLog("notes element found...")
            return currentElementState.ingredientNameState
        }
        if elementName.isEqual(to: "processingInstructions") {
            // NSLog("notes element found...")
            return currentElementState.processingInstructionsState
        }
        if elementName.isEqual(to: "ingredient") {
            // NSLog("ingredient element found – create a new instance of Ingredient class...")
            if localDatabaseInterface != nil {
                currentIngredient = (localDatabaseInterface!.newManagedObjectOfType(managedObjectClassName: "Ingredient") as! Ingredient)
                return currentElementState.ingredientState
            }
        }
        if elementName.isEqual(to: "ingredients") {
            return currentElementState.ingredientsState
        }
        if elementName.isEqual(to: "name") {
            // NSLog("notes element found...")
            return currentElementState.nameState
        }
        if elementName.isEqual(to: "indexCharacter") {
            // NSLog("indexCharacter element found...")
            return currentElementState.indexCharacterState
        }
        if elementName.isEqual(to: "notes") {
            // NSLog("notes element found...")
            return currentElementState.notesState
        }
        if elementName.isEqual(to: "servings") {
            // NSLog("servings element found...")
            return currentElementState.servingsState
        }
        if elementName.isEqual(to: "instructions") {
            // NSLog("instructions element found...")
            return currentElementState.instructionsState
        }
        if elementName.isEqual(to: "recipe") {
            // NSLog("recipe element found – create a new instance of Recipe class...")
            if localDatabaseInterface != nil {
                currentRecipe = (localDatabaseInterface!.newManagedObjectOfType(managedObjectClassName: "Recipe") as! Recipe)
                if currentRecipe != nil {
                    currentRecipe!.notes = ""
                }
                return currentElementState.recipeState
            }
        }
        
        return currentElementState.noState
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let squashed:NSString = string as NSString
        squashed.replacingOccurrences(of: "\\s+", with: "", options: NSString.CompareOptions.regularExpression, range: NSMakeRange(0, squashed.length))
        //squashed.stringByReplacingOccurrencesOfString("\\s+", withString: "", options: NSString.CompareOptions.RegularExpressionSearch, range: NSMakeRange(0, squashed.length))
        
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
                    currentRecipeTitle = localDatabaseInterface?.newManagedObjectOfType(managedObjectClassName: "RecipeTitle") as? RecipeTitle
                    currentRecipeTitle!.name = elementValue as String
                }
            break
            
            case currentElementState.indexCharacterState:
                if currentRecipe != nil && currentRecipeTitle != nil {
                    currentRecipeTitle!.indexCharacter = elementValue as String
                }
            break
            
            case currentElementState.notesState:
                if elementValue.isEqual(to: "(null)") {
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
                    currentRecipe!.servings = NSNumber(value: elementValue.integerValue)
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
                    currentIngredient!.quantity = NSNumber(value: FractionMath.stringToDouble(inputString: elementValue as String))
                }
            break
            
            case currentElementState.unitOfMeasureState:
                if currentIngredient != nil {
                    currentIngredient!.unitOfMeasure = (elementValue as String).lowercased()
                }
            break
            
            case currentElementState.ingredientNameState:
            // NSLog("Ingredient Name: %@", elementValue)
                if localDatabaseInterface != nil {
                    let recipeItemName = (elementValue as String).capitalized.trimmingCharacters(in: .whitespaces)
                    let recipeItem = RecipeItem.createOrReturn(databaseInterface: localDatabaseInterface!, recipeItemName: recipeItemName)
                    if currentIngredient != nil {
                        currentIngredient!.processingInstructions = ""
                        currentIngredient!.ingredientItem = recipeItem
                    }
                }
            break
            
            case currentElementState.processingInstructionsState:
                if currentIngredient != nil {
                    currentIngredient!.processingInstructions = (elementValue as String).trimmingCharacters(in: .whitespaces)
                }
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // NSLog("didEndElement: %@", elementName)
        let currentState:currentElementState  = currentStateStack[currentStateStack.endIndex - 1]
        
        processValueForState(currentState: currentState, elementValue:currentElementString as NSString)

        if currentState == currentElementState.ingredientState {
            if currentRecipe != nil && currentIngredient != nil {
                currentRecipe!.addContainsIngredientsObject(value: currentIngredient!)
            }
        }
        else {
            if currentState == currentElementState.recipeState {
                // NSLog("currentRecipe: \(currentRecipe!.recipeDescription())")
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
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error)  {
        Logger.logDetails(msg: "ParseXMLRecipe:parseErrorOccurred called with error \(parseError as NSError)")
    }
    
}
