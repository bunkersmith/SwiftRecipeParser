//
//  FileUtilities.swift
//  Swift Music Player
//
//  Created by CarlSmith on 6/9/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit

class FileUtilities {
   
    class func applicationDocumentsDirectory() -> URL {
        // The directory the application uses to store various files.
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    class func loggerArchiveFilePath() -> String {
        let documentsDirectory = FileUtilities.applicationDocumentsDirectory()
        return documentsDirectory.appendingPathComponent("SwiftRecipeParser.loggerArchive").path
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
