//
//  RecipeFiles.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/27/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import Foundation

class RecipeFiles {
    
    private var totalRecipes:Int = 0;
    private var recipePathnames:Array<Array<String>> = Array()
    
    func initializeRecipeDatabaseFromResourceFiles() {
        var databaseManager:DatabaseManager = DatabaseManager.instance
        
        databaseManager.backgroundOperation({
            self.asyncInitializeRecipeDatabase(DatabaseInterface())
        })
    }
    
    func initializeRecipesInDirectory(directoryName:String) {
        var directoryContent:Array<AnyObject>
        directoryContent = NSFileManager.defaultManager().contentsOfDirectoryAtPath(directoryName, error: nil)!
        
        var usableFiles:Array<String> = Array()
        var usableFileCount:Int = 0
        var fullRecipePathname:String
        var recipeTitle:String
        
        //NSLog("\(directoryName.lastPathComponent) count = \(directoryContent.count)")
        
        for i in 0 ..< directoryContent.count {
            fullRecipePathname = directoryName.stringByAppendingPathComponent(directoryContent[i] as! String)
            //Utilities.writelnToStandardOut(fullRecipePathname)
            
            if Utilities.fileExistsAtAbsolutePath(fullRecipePathname) {
                if fullRecipePathname.rangeOfString(".xml") != nil {
                    usableFiles.append(fullRecipePathname)
                    recipeTitle = RecipeFiles.returnRecipeTitleFromPath(fullRecipePathname)
                    //Utilities.writelnToStandardOut("recipeTitle = \(recipeTitle)")
                    usableFileCount++
                }
                else {
                    NSLog("Recipe Pathname \(fullRecipePathname) does not contain .xml")
                }
            }
            else {
                NSLog("Utilities.fileExistsAtAbsolutPath returned fals for file \(fullRecipePathname)")
            }
        }
        
        if usableFileCount > 0 {
            recipePathnames.append(usableFiles)
            totalRecipes += usableFileCount
        }
    }
    
    func returnlRecipeResourcesPath() -> String {
        var returnValue:String = NSBundle.mainBundle().resourcePath!
        
        return returnValue.stringByAppendingPathComponent("XML_recipes")
    }
    
    func initializeRecipePathnames() {
        var recipesResourcesDirectory:String = returnlRecipeResourcesPath()
        var exists:Bool = Utilities.directoryExistsAtAbsolutePath(recipesResourcesDirectory)
        
        NSLog("recipesResourcesDirectory = \(recipesResourcesDirectory), exists = \(exists)")
        
        if exists {
            var directoryContent:Array<AnyObject>
            directoryContent = NSFileManager.defaultManager().contentsOfDirectoryAtPath(recipesResourcesDirectory, error: nil)!
            var fullDirectoryPathname:String
            
            for i in 0 ..< directoryContent.count {
                fullDirectoryPathname = recipesResourcesDirectory.stringByAppendingPathComponent(directoryContent[i] as! String)
                
                if Utilities.directoryExistsAtAbsolutePath(fullDirectoryPathname) {
                    initializeRecipesInDirectory(fullDirectoryPathname)
                }
            }
            
            NSLog("Recipe resource pathnames added: \(totalRecipes)")
        }
        
    }
    
    func asyncInitializeRecipeDatabase(databaseInterface:DatabaseInterface) {
        var asyncInitStartTime:CFAbsoluteTime = Utilities.currentTickCount()
        
        initializeRecipePathnames()
        
        var currentRecipeSection:Array<String> = Array()
        
        var fivePercent:Int = totalRecipes / 20

        NSLog("totalRecipes = \(totalRecipes)")
        NSLog("fivePercent = \(fivePercent)")
        NSLog("recipePathnames.count = \(recipePathnames.count)")
        
        var currentPercentage:Int
        var percentageDictionary:Dictionary<String,NSNumber>;
        var recipesProcessed:Int = 0
        
        for i in 0 ..< recipePathnames.count {
            currentRecipeSection = recipePathnames[i]
            
            for j in 0 ..< currentRecipeSection.count {
                returnRecipeFromXML(currentRecipeSection[j], databaseInterface:databaseInterface)
                recipesProcessed++
                
                //RecipeFiles.initRecipeFromPath(currentRecipeSection[j], databaseInterface:databaseInterface)
                if (recipesProcessed % fivePercent == 0) {
                    currentPercentage = (recipesProcessed * 100) / totalRecipes
                    percentageDictionary = ["percentage":currentPercentage]
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("RecipeProgressNotification", object: self, userInfo: percentageDictionary)
                }
            }
        }
        
        percentageDictionary = ["percentage": 100.0]
        NSNotificationCenter.defaultCenter().postNotificationName("RecipeProgressNotification", object: self, userInfo: percentageDictionary)
        
        var asyncInitStopTime:CFAbsoluteTime = Utilities.currentTickCount();
        
        var asyncInitElapsedTime:CFAbsoluteTime = asyncInitStopTime - asyncInitStartTime
        
        NSLog("asyncRecipeDatabaseInit Elapsed Time = %.3f", asyncInitElapsedTime / 1000.0 )
    }
    
    func returnRecipeFromXML(recipePath:NSString, databaseInterface:DatabaseInterface)
    {
        var recipeFileData:NSData = NSFileManager.defaultManager().contentsAtPath(recipePath as String)!;
        
        var xmlRecipeParser:ParseXMLRecipe = ParseXMLRecipe();
        xmlRecipeParser.parseRecipeFromXMLData(recipeFileData, databaseInterface: databaseInterface)
    }
    
    class func readRecipeFile(filePath:String) -> String {
        var error:NSError?
        var fileContents:String = ""
        
        if Utilities.fileExistsAtAbsolutePath(filePath) {
            var error:NSError?
            fileContents = String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding, error: &error)!
            
            if error != nil {
                fileContents = ""
                NSLog("readRecipeFile encountered error \(error) reading file with path \(filePath)")
            }
        }
        else {
            NSLog("readRecipeFile could not find file with path \(filePath)")
        }
        
        return fileContents
    }
    
    class func returnRecipeTitleFromPath(recipeResourceFilePath:String) -> String {
        var fileContents:String = readRecipeFile(recipeResourceFilePath)
        
        if fileContents == "" {
            return ""
        }
        else {
            return returnRecipeTitleFromFileContents(fileContents)
        }
    }
    
    class func returnRecipeTitleFromFileContents(recipeFileContents:String) -> String {
        var titleData:Array<NSString> = ParseRecipe.textBetweenStrings(recipeFileContents, startString: "<name>", endString: "</name>", keepStrings: false)
        var titleString:NSString = titleData[0]
        
        if titleString.length > 0 {
            titleString = ParseRecipe.replaceString("\r\n  ", inputString:titleString, replacementString:" ")
            titleString = ParseRecipe.replaceString("&amp;", inputString:titleString, replacementString:"&")
            titleString = ParseRecipe.replaceString("&quot;", inputString:titleString, replacementString:"\"")
        }
        
        return titleString as String
    }
}