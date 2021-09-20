//
//  Utilities.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/27/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Utilities {
    
    class func convertSectionTitles(fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>) -> Array<String> {
        var returnValue:Array<String> = [" "]
        let sections:Array = fetchedResultsController.sections!
        
        for i in 0 ..< sections.count {
            returnValue.append(sections[i].name)
        }
        
        return returnValue
    }
    
    class func convertSectionIndexTitles(fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>) -> Array<String> {
        var returnValue:Array<String> = [UITableViewIndexSearch]
        for i in 0 ..< fetchedResultsController.sectionIndexTitles.count {
            returnValue.append(fetchedResultsController.sectionIndexTitles[i] )
        }
        
        return returnValue
    }
    
    class func fileExistsAtAbsolutePath(pathname:String) -> Bool {
        var isDirectory:ObjCBool = ObjCBool(false)
        let existsAtPath:Bool = FileManager.default.fileExists(atPath: pathname, isDirectory: &isDirectory)
        
        return existsAtPath && !isDirectory.boolValue
    }
    
    class func directoryExistsAtAbsolutePath(pathname:String) -> Bool {
        var isDirectory:ObjCBool = ObjCBool(false)
        let existsAtPath:Bool = FileManager.default.fileExists(atPath: pathname, isDirectory: &isDirectory)
        
        return existsAtPath && isDirectory.boolValue
    }
    
    class func writelnToStandardOut(stringToWrite:String) {
        DispatchQueue.main.async {
            print(stringToWrite)
        }
    }
    
    class func nsFetchedResultsChangeTypeToString( nsFetchedResultsChangeType: NSFetchedResultsChangeType) -> String {
        switch nsFetchedResultsChangeType {
            case .insert:
                return "NSFetchedResultsChangeInsert"
            case .delete:
                return "NSFetchedResultsChangeDelete"
            case .move:
                return "NSFetchedResultsChangeMove"
            case .update:
                return "NSFetchedResultsChangeUpdate"
        }
    }
    
    class func forceLoadDatabase() -> Bool {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist") else {
            return false
        }
        guard let dict = NSDictionary(contentsOfFile: path) else {
            return false
        }
        guard let obj = dict.object(forKey: "forceLoadDatabase") as? NSNumber else {
            return false
        }
        /*
         guard let bool = obj.boolValue else {
         return false
         }
         */
        return obj.boolValue
    }
    
/*
    class func updateGroceryListItems() -> Bool {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist") else {
            return false
        }
        guard let dict = NSDictionary(contentsOfFile: path) else {
            return false
        }
        guard let obj = dict.object(forKey: "updateGroceryListItems") as? NSNumber else {
            return false
        }
        /*
        guard let bool = obj.boolValue else {
            return false
        }
        */
        return obj.boolValue
    }
*/
    
}
