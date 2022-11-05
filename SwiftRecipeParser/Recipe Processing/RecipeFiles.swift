//
//  RecipeFiles.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/27/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import Foundation

class RecipeFiles {
    
    private var totalRecipes:Int = 0
//    private var sortedFiles:Array<String> = Array()
    
    func initializeRecipeDatabaseFromResourceFiles() {
        let databaseInterface = DatabaseInterface(concurrencyType: .privateQueueConcurrencyType)
        
        databaseInterface.performInBackground {
            self.asyncInitializeRecipeDatabase(databaseInterface: databaseInterface)
        }
    }
    
    func initializeRecipesInDirectory(directoryName:String) -> Array<String> {
        var directoryContent:Array<AnyObject>
        var usableFiles:Array<String> = Array()
        var usableFileCount:Int = 0

        do {
            directoryContent = try FileManager.default.contentsOfDirectory(atPath: directoryName) as Array<AnyObject>
            
            var fullRecipePathname:String
            //var recipeTitle:String
            
            //NSLog("\(directoryName.lastPathComponent) count = \(directoryContent.count)")
            
            for i in 0 ..< directoryContent.count {
                fullRecipePathname = directoryName + "/" + (directoryContent[i] as! String)
//                sortedFiles.append(directoryContent[i] as! String)
                //Utilities.writelnToStandardOut(fullRecipePathname)
                
                if Utilities.fileExistsAtAbsolutePath(pathname: fullRecipePathname) {
                    if fullRecipePathname.range(of: ".xml") != nil {
                        usableFiles.append(fullRecipePathname)
                        //recipeTitle = RecipeFiles.returnRecipeTitleFromPath(fullRecipePathname)
                        //Utilities.writelnToStandardOut("recipeTitle = \(recipeTitle)")
                        usableFileCount += 1
                    }
                    else {
                        Logger.logDetails(msg: "Recipe Pathname \(fullRecipePathname) does not contain .xml")
                    }
                }
                else {
                    Logger.logDetails(msg: "Utilities.fileExistsAtAbsolutPath returned fals for file \(fullRecipePathname)")
                }
            }
        } catch let error as NSError {
            Logger.logDetails(msg: "Error retrieving contents of directory at path \(directoryName): \(error)")
        }
        
        if usableFileCount > 0 {
            totalRecipes += usableFileCount
        }
        
        return usableFiles
    }
    
    func countOfRecipesInDirectory(directoryName:String) -> Int {
        var directoryContent:Array<AnyObject>
        var usableFileCount:Int = 0
        
        do {
            directoryContent = try FileManager.default.contentsOfDirectory(atPath: directoryName) as Array<AnyObject>
            
            var fullRecipePathname:String
            //var recipeTitle:String
            
            //NSLog("\(directoryName.lastPathComponent) count = \(directoryContent.count)")
            
            for i in 0 ..< directoryContent.count {
                fullRecipePathname = directoryName + "/" + (directoryContent[i] as! String)
                //Utilities.writelnToStandardOut(fullRecipePathname)
                
                if Utilities.fileExistsAtAbsolutePath(pathname: fullRecipePathname) {
                    if fullRecipePathname.range(of: ".xml") != nil {
                        //recipeTitle = RecipeFiles.returnRecipeTitleFromPath(fullRecipePathname)
                        //Utilities.writelnToStandardOut("recipeTitle = \(recipeTitle)")
                        usableFileCount += 1
                    }
                    else {
                        Logger.logDetails(msg: "Recipe Pathname \(fullRecipePathname) does not contain .xml")
                    }
                }
                else {
                    Logger.logDetails(msg: "Utilities.fileExistsAtAbsolutPath returned fals for file \(fullRecipePathname)")
                }
            }
        } catch let error as NSError {
            Logger.logDetails(msg: "Error retrieving contents of directory at path \(directoryName): \(error)")
        }
        
        if usableFileCount > 0 {
            totalRecipes += usableFileCount
        }
        
        return usableFileCount
    }
    
    func returnRecipeResourcesURL() -> URL {
        let resourcePath:String = Bundle.main.resourcePath!
        let returnValue = URL(fileURLWithPath:resourcePath).appendingPathComponent("XML_recipes")
        
        return returnValue
    }

    func recipePathnameFromTitle(userInput: String) -> URL {
        var xmlFilename = userInput.trimmingCharacters(in: .whitespaces)
        print("User entered: \(xmlFilename)")
        
        xmlFilename = xmlFilename.replacingOccurrences(of: " ", with: "_")
        print("xmlFilename: \(xmlFilename)")
    
        let recipeResourcesDirectory = RecipeFiles().returnRecipeResourcesURL()
        let specificRecipeDirectory = recipeResourcesDirectory.appendingPathComponent(String(xmlFilename.first!), isDirectory: true)
    
        let pathname = specificRecipeDirectory.appendingPathComponent(xmlFilename).appendingPathExtension("xml")
        print("\(pathname)")
        
        return pathname
    }
    
    func countOfRecipeResourceFiles() -> Int {
        var recipeFileCount = 0
        let recipesResourcesDirectory:URL = returnRecipeResourcesURL()
        if Utilities.directoryExistsAtAbsolutePath(pathname: recipesResourcesDirectory.path) {
            var directoryContent:Array<AnyObject>
            
            do {
                directoryContent = try FileManager.default.contentsOfDirectory(atPath: recipesResourcesDirectory.path) as Array<AnyObject>
                
                var fullDirectoryPathname:String
                
                for i in 0 ..< directoryContent.count {
                    fullDirectoryPathname = recipesResourcesDirectory.appendingPathComponent(directoryContent[i] as! String).path
                    
                    if Utilities.directoryExistsAtAbsolutePath(pathname: fullDirectoryPathname) {
                        recipeFileCount += countOfRecipesInDirectory(directoryName: fullDirectoryPathname)
                    }
                }
            } catch let error as NSError {
                Logger.logDetails(msg: "Error retrieving contents of directory at path \(recipesResourcesDirectory.path): \(error)")
            }
        }
        return recipeFileCount
    }
    
    func initializeRecipePathnames() -> Array<Array<String>> {
        var recipePathnames:Array<Array<String>> = Array<Array<String>>()
        
        let recipesResourcesDirectory:URL = returnRecipeResourcesURL()
        let exists:Bool = Utilities.directoryExistsAtAbsolutePath(pathname: recipesResourcesDirectory.path)
        
        Logger.logDetails(msg: "recipesResourcesDirectory = \(recipesResourcesDirectory), exists = \(exists)")
        
        if exists {
            var directoryContent:Array<AnyObject>
            
            do {
            directoryContent = try FileManager.default.contentsOfDirectory(atPath: recipesResourcesDirectory.path) as Array<AnyObject>
                
                var fullDirectoryPathname:String
                
                for i in 0 ..< directoryContent.count {
                    fullDirectoryPathname = recipesResourcesDirectory.appendingPathComponent(directoryContent[i] as! String).path
                    
                    if Utilities.directoryExistsAtAbsolutePath(pathname: fullDirectoryPathname) {
                        recipePathnames.append(initializeRecipesInDirectory(directoryName: fullDirectoryPathname))
                    }
                }
                
                Logger.logDetails(msg: "Recipe resource pathnames added: \(totalRecipes)")
            } catch let error as NSError {
                Logger.logDetails(msg: "Error retrieving contents of directory at path \(recipesResourcesDirectory.path): \(error)")
            }
        }
        
//        sortedFiles = sortedFiles.sorted(by: <)
//        for sortedFile in sortedFiles {
//            print("    - assets/xml/\(sortedFile.first!)/\(sortedFile)")
//        }
        
        return recipePathnames
    }
    
    func deleteExistingRecipes(databaseInterface:DatabaseInterface) {
        if Recipe.countOfDatabaseRecipes() > 0 {
// ONLY Recipe ENTITIES NEED TO BE DELETED NOW, BECAUSE THE CASCADE RULE CAUSES THE OTHER ENTITIES TO BE DELETED
            
//            databaseInterface.deleteAllObjectsWithEntityName(entityName: "Ingredient")
//            databaseInterface.deleteAllObjectsWithEntityName(entityName: "RecipeTitle")
//            databaseInterface.deleteAllObjectsWithEntityName(entityName: "RecipeItem")
            databaseInterface.deleteAllObjectsWithEntityName(entityName: "Recipe")
        }
    }
    
    func asyncInitializeRecipeDatabase(databaseInterface:DatabaseInterface) {
        let asyncInitStartTime = MillisecondTimer.currentTickCount()

        deleteExistingRecipes(databaseInterface: databaseInterface)
        
        let asyncDeleteStopTime = MillisecondTimer.currentTickCount();
        
        var logString = String(format: "Recipe Database Deletion Time = %.3f", Float(asyncDeleteStopTime - asyncInitStartTime) / 1000.0 )
        
        Logger.logDetails(msg: logString)
        
        let recipePathnames:Array<Array<String>> = initializeRecipePathnames()
        
        var currentRecipeSection:Array<String> = Array()
        
        let fivePercent:Int = totalRecipes / 20

        Logger.logDetails(msg: "totalRecipes = \(totalRecipes)")
        Logger.logDetails(msg: "fivePercent = \(fivePercent)")
        Logger.logDetails(msg: "recipePathnames.count = \(recipePathnames.count)")
        
        var currentPercentage:Int = 0
        var percentageDictionary:Dictionary<String,NSNumber>;
        var recipesProcessed:Int = 0
        
        for i in 0 ..< recipePathnames.count {
            currentRecipeSection = recipePathnames[i]
            
            for j in 0 ..< currentRecipeSection.count {
                let _ = returnRecipeFromXML(recipePath: currentRecipeSection[j], databaseInterface:databaseInterface)
                recipesProcessed += 1
                
                let modValue = recipesProcessed % fivePercent
                
                //RecipeFiles.initRecipeFromPath(currentRecipeSection[j], databaseInterface:databaseInterface)
                if (modValue == 0) {
                    currentPercentage += 5
                    percentageDictionary = ["percentage":NSNumber(value: currentPercentage)]
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SwiftRecipeParser.RecipeProgressNotification"), object: self, userInfo: percentageDictionary)
                }
            }
        }
        
        percentageDictionary = ["percentage": 100.0]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SwiftRecipeParser.RecipeProgressNotification"), object: self, userInfo: percentageDictionary)
        
        let asyncInitStopTime = MillisecondTimer.currentTickCount();
        
        logString = String(format: "Recipe Database Init Time (Includes Delete Time) = %.3f", Float(asyncInitStopTime - asyncInitStartTime) / 1000.0 )
        
        Logger.logDetails(msg: logString)
    }
    
    func returnRecipeFromXML(recipePath:String, databaseInterface:DatabaseInterface) -> Bool {
        let recipeFileData:NSData = FileManager.default.contents(atPath: recipePath)! as NSData
        
        let xmlRecipeParser:ParseXMLRecipe = ParseXMLRecipe()
        return xmlRecipeParser.parseRecipeFromXMLData(recipeFileData: recipeFileData, databaseInterface: databaseInterface)
    }
    
    class func readRecipeFile(filePath:String) -> String {
        var fileContents:String = ""
        
        if Utilities.fileExistsAtAbsolutePath(pathname: filePath) {
            do {
                fileContents = try String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
            } catch let error as NSError {
                fileContents = ""
                Logger.logDetails(msg: "readRecipeFile encountered error \(error) reading file with path \(filePath)")
            }
        }
        else {
            Logger.logDetails(msg: "readRecipeFile could not find file with path \(filePath)")
        }
        
        return fileContents
    }
    
    class func returnRecipeTitleFromPath(recipeResourceFilePath:String) -> String {
        let fileContents:String = readRecipeFile(filePath: recipeResourceFilePath)
        
        if fileContents == "" {
            return ""
        }
        else {
            return returnRecipeTitleFromFileContents(recipeFileContents: fileContents)
        }
    }
    
    class func returnRecipeTitleFromFileContents(recipeFileContents:String) -> String {
        let titleData:Array<NSString> = ParseRecipe.textBetweenStrings(inputString: recipeFileContents as NSString, startString: "<name>", endString: "</name>", keepStrings: false) as Array<NSString>
        var titleString:NSString = titleData[0]
        
        if titleString.length > 0 {
            titleString = ParseRecipe.replaceString(stringToReplace: "\r\n  ", inputString:titleString as String, replacementString:" ") as NSString
            titleString = ParseRecipe.replaceString(stringToReplace: "&amp;", inputString:titleString as String, replacementString:"&") as NSString
            titleString = ParseRecipe.replaceString(stringToReplace: "&quot;", inputString:titleString as String, replacementString:"\"") as NSString
        }
        
        return titleString as String
    }
}
