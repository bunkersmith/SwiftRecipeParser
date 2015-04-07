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
    
    class var instance: Utilities {
    struct Singleton {
        static let instance = Utilities()
        }
        return Singleton.instance
    }
    
    var appStartupTime:CFAbsoluteTime!
    
    class func currentTickCount() -> CFAbsoluteTime {
        return CFAbsoluteTimeGetCurrent()
    }
    
    class func convertSectionTitles(fetchedResultsController:NSFetchedResultsController) -> Array<String> {
        var returnValue:Array<String> = [" "]
        var sections:Array = fetchedResultsController.sections!
        
        for i in 0 ..< sections.count {
            returnValue.append(sections[i].name)
        }
        
        return returnValue
    }
    
    class func convertSectionIndexTitles(fetchedResultsController:NSFetchedResultsController) -> Array<String> {
        var returnValue:Array<String> = [UITableViewIndexSearch]
        returnValue += fetchedResultsController.sectionIndexTitles as Array<String>
        
        return returnValue
    }
    
    class func fileExistsAtAbsolutePath(pathname:String) -> Bool {
        var isDirectory:ObjCBool = ObjCBool(false)
        var existsAtPath:Bool = NSFileManager.defaultManager().fileExistsAtPath(pathname, isDirectory: &isDirectory)
        
        return existsAtPath && !isDirectory
    }
    
    class func directoryExistsAtAbsolutePath(pathname:String) -> Bool {
        var isDirectory:ObjCBool = ObjCBool(false)
        var existsAtPath:Bool = NSFileManager.defaultManager().fileExistsAtPath(pathname, isDirectory: &isDirectory)
        
        return existsAtPath && isDirectory
    }
    
    class func writelnToStandardOut(stringToWrite:String) {
            dispatch_async(dispatch_get_main_queue(), {
                println(stringToWrite)
            })
    }
    
    // Returns the URL to the application's Documents directory.
    class func applicationDocumentsDirectory() -> NSURL
    {
        let directoryURLs:Array<NSURL> = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask) as Array<NSURL>
        return directoryURLs[directoryURLs.endIndex - 1]
    }
}