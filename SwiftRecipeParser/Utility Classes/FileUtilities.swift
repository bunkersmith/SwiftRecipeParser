//
//  FileUtilities.swift
//  Swift Music Player
//
//  Created by CarlSmith on 6/9/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit

class FileUtilities {
   
    class func fileExists(_ pathComponent: String) -> Bool {
        let url = applicationDocumentsDirectory()
        let pathComponent = url.appendingPathComponent(pathComponent)
        let filePath = pathComponent.path
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: filePath)
    }
    
    class func createDirectory(_ folderName: String) {
        let dataPath = applicationDocumentsDirectory().appendingPathComponent(folderName)
        if !FileManager.default.fileExists(atPath: dataPath.path) {
            do {
                try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    class func applicationDocumentsDirectory() -> URL {
        // The directory the application uses to store various files.
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    class func loggerArchiveFilePath() -> String {
        let documentsDirectory = FileUtilities.applicationDocumentsDirectory()
        return documentsDirectory.appendingPathComponent("SwiftRecipeParser.loggerArchive").path
    }
    
    class func exportFilePath() -> String {
        let documentsDirectory = FileUtilities.applicationDocumentsDirectory()
        return documentsDirectory.appendingPathComponent("GroceryListItems.txt").path
    }

    class func logFilePath() -> String {
        let documentsDirectory = FileUtilities.applicationDocumentsDirectory()
        return documentsDirectory.appendingPathComponent("SwiftRecipeParser-Log.txt").path
    }
    
    class func timeStampedLogFileName() -> String {
        let fileNameString = "SwiftRecipeParser-\(DateTimeUtilities.currentTimeToString())-Log.txt"
        return fileNameString
    }
    
    class func timeStampedGroceryListItemsFileName() -> String {
        let fileNameString = "SwiftRecipeParser-\(DateTimeUtilities.currentTimeToString())-GroceryListItems.txt"
        return fileNameString
    }
    
    class func groceryListItemsFilePath() -> String {
        let documentsDirectory = FileUtilities.applicationDocumentsDirectory()
        return documentsDirectory.appendingPathComponent("SwiftRecipeParser-GroceryListItems.txt").path
    }
    
}
