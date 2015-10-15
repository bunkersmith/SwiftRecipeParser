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
    
    func initializeRecipeDatabaseFromResourceFiles() {
        let databaseManager:DatabaseManager = DatabaseManager.instance
        
        databaseManager.backgroundOperation({
            self.asyncInitializeRecipeDatabase(DatabaseInterface())
        })
    }
    
    func initializeRecipesInDirectory(directoryName:String) -> Array<String> {
        var directoryContent:Array<AnyObject>
        var usableFiles:Array<String> = Array()
        var usableFileCount:Int = 0
        
        do {
            directoryContent = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(directoryName)
            
            var fullRecipePathname:String
            //var recipeTitle:String
            
            //NSLog("\(directoryName.lastPathComponent) count = \(directoryContent.count)")
            
            for i in 0 ..< directoryContent.count {
                fullRecipePathname = directoryName + "/" + (directoryContent[i] as! String)
                //Utilities.writelnToStandardOut(fullRecipePathname)
                
                if Utilities.fileExistsAtAbsolutePath(fullRecipePathname) {
                    if fullRecipePathname.rangeOfString(".xml") != nil {
                        usableFiles.append(fullRecipePathname)
                        //recipeTitle = RecipeFiles.returnRecipeTitleFromPath(fullRecipePathname)
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
        } catch let error as NSError {
            NSLog("Error retrieving contents of directory at path \(directoryName): \(error)")
        }
        
        if usableFileCount > 0 {
            totalRecipes += usableFileCount
        }
        
        return usableFiles
    }
    
    func returnRecipeResourcesURL() -> NSURL {
        let resourcePath:String = NSBundle.mainBundle().resourcePath!
        let returnValue = NSURL(fileURLWithPath:resourcePath).URLByAppendingPathComponent("XML_recipes")
        
        return returnValue
    }
    
    func initializeRecipePathnames() -> Array<Array<String>> {
        var recipePathnames:Array<Array<String>> = Array<Array<String>>()
        
        let recipesResourcesDirectory:NSURL = returnRecipeResourcesURL()
        let exists:Bool = Utilities.directoryExistsAtAbsolutePath(recipesResourcesDirectory.path!)
        
        NSLog("recipesResourcesDirectory = \(recipesResourcesDirectory), exists = \(exists)")
        
        if exists {
            var directoryContent:Array<AnyObject>
            
            do {
            directoryContent = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(recipesResourcesDirectory.path!)
                
                var fullDirectoryPathname:String
                
                for i in 0 ..< directoryContent.count {
                    fullDirectoryPathname = recipesResourcesDirectory.URLByAppendingPathComponent(directoryContent[i] as! String).path!
                    
                    if Utilities.directoryExistsAtAbsolutePath(fullDirectoryPathname) {
                        recipePathnames.append(initializeRecipesInDirectory(fullDirectoryPathname))
                    }
                }
                
                NSLog("Recipe resource pathnames added: \(totalRecipes)")
            } catch let error as NSError {
                NSLog("Error retrieving contents of directory at path \(recipesResourcesDirectory.path): \(error)")
            }
        }
        
        return recipePathnames
    }
    
    func asyncInitializeRecipeDatabase(databaseInterface:DatabaseInterface) {
        let asyncInitStartTime = MillisecondTimer.currentTickCount()
        
        var recipePathnames:Array<Array<String>> = initializeRecipePathnames()
        
        var currentRecipeSection:Array<String> = Array()
        
        let fivePercent:Int = totalRecipes / 20

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
        
        let asyncInitStopTime = MillisecondTimer.currentTickCount();
        
        NSLog("asyncRecipeDatabaseInit Elapsed Time = %.3f", Float(asyncInitStopTime - asyncInitStartTime) / 1000.0 )
    }
    
    func returnRecipeFromXML(recipePath:NSString, databaseInterface:DatabaseInterface)
    {
        let recipeFileData:NSData = NSFileManager.defaultManager().contentsAtPath(recipePath as String)!;
        
        let xmlRecipeParser:ParseXMLRecipe = ParseXMLRecipe();
        xmlRecipeParser.parseRecipeFromXMLData(recipeFileData, databaseInterface: databaseInterface)
    }
    
    class func readRecipeFile(filePath:String) -> String {
        var fileContents:String = ""
        
        if Utilities.fileExistsAtAbsolutePath(filePath) {
            do {
                fileContents = try String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
            } catch let error as NSError {
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
        let fileContents:String = readRecipeFile(recipeResourceFilePath)
        
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