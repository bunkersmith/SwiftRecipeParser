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
    
    @available(iOS 8.0, *)
    class func showOkButtonAlert(viewController:UIViewController, title: String, message:String, okButtonHandler:((UIAlertAction!) -> Void)?) -> UIAlertController {
        let okButtonAlert = UIAlertController(title:title, message:message, preferredStyle:UIAlertControllerStyle.Alert)
        okButtonAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: okButtonHandler))
        viewController.presentViewController(okButtonAlert, animated:true, completion: nil)
        return okButtonAlert
    }

    @available(iOS 8.0, *)
    class func showYesNoAlert(viewController:UIViewController, title: String, message:String, yesButtonHandler:((UIAlertAction!) -> Void)?) -> UIAlertController {
        let yesNoButtonAlert = UIAlertController(title:title, message:message, preferredStyle:UIAlertControllerStyle.Alert)
        yesNoButtonAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: yesButtonHandler))
        yesNoButtonAlert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
        viewController.presentViewController(yesNoButtonAlert, animated:true, completion: nil)
        return yesNoButtonAlert
    }
    
    @available(iOS 8.0, *)
    class func showTextFieldAlert(viewController:UIViewController,
                                           title: String, message:String?,
                            inout inputTextField:UITextField,
                                    startingText:String,
                                    keyboardType:UIKeyboardType,
                              capitalizationType:UITextAutocapitalizationType,
                                   okButtonHandler:((UIAlertAction!) -> Void)?) -> UIAlertController {
        let textFieldAlert = UIAlertController(title:title, message:message, preferredStyle:.Alert)
    
        textFieldAlert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            inputTextField = textField
            textField.keyboardType = keyboardType
            textField.autocapitalizationType = capitalizationType
            textField.text = startingText
        }
        textFieldAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: okButtonHandler))
        textFieldAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        viewController.presentViewController(textFieldAlert, animated: true, completion: nil)
        return textFieldAlert
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
        for i in 0 ..< fetchedResultsController.sectionIndexTitles.count {
            returnValue.append(fetchedResultsController.sectionIndexTitles[i] )
        }
        
        return returnValue
    }
    
    class func fileExistsAtAbsolutePath(pathname:String) -> Bool {
        var isDirectory:ObjCBool = ObjCBool(false)
        let existsAtPath:Bool = NSFileManager.defaultManager().fileExistsAtPath(pathname, isDirectory: &isDirectory)
        
        return existsAtPath && !isDirectory
    }
    
    class func directoryExistsAtAbsolutePath(pathname:String) -> Bool {
        var isDirectory:ObjCBool = ObjCBool(false)
        let existsAtPath:Bool = NSFileManager.defaultManager().fileExistsAtPath(pathname, isDirectory: &isDirectory)
        
        return existsAtPath && isDirectory
    }
    
    class func writelnToStandardOut(stringToWrite:String) {
            dispatch_async(dispatch_get_main_queue(), {
                print(stringToWrite)
            })
    }
    
    // Returns the URL to the application's Documents directory.
    class func applicationDocumentsDirectory() -> NSURL
    {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
    }
    
    class func nsFetchedResultsChangeTypeToString( nsFetchedResultsChangeType: NSFetchedResultsChangeType) -> String {
        switch nsFetchedResultsChangeType {
            case .Insert:
                return "NSFetchedResultsChangeInsert"
            case .Delete:
                return "NSFetchedResultsChangeDelete"
            case .Move:
                return "NSFetchedResultsChangeMove"
            case .Update:
                return "NSFetchedResultsChangeUpdate"
        }
    }
}