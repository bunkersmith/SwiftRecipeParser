//
//  DatabaseInterface.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/25/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class DatabaseInterface: NSObject {
    private var context:NSManagedObjectContext!
    
    init() {
        let databaseManager:DatabaseManager = DatabaseManager.instance;
        if NSThread.isMainThread() {
            context = databaseManager.returnMainManagedObjectContext()
        }
        else {
            context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.ConfinementConcurrencyType)
            context.persistentStoreCoordinator = databaseManager.returnPersistentStoreCoordinator()
        }
        
        //NSLog("context = \(context)")
    }
    
    func newManagedObjectOfType(managedObjectClassName:String) -> NSManagedObject {
        let entityDescription:NSEntityDescription = NSEntityDescription.entityForName(managedObjectClassName, inManagedObjectContext: context)
        
        return NSManagedObject(entity: entityDescription, insertIntoManagedObjectContext: context)
    }
    
    func saveContext() {
        var error:NSError?
        if context {
            if !context.save(&error) {
                NSLog("Error saving context in DatabaseInterface.saveContext(): \(error)")
            }
        }
        else {
            NSLog("No context in DatabaseInterface.saveContext()")
        }
    }
    
    func entitiesOfType(entityTypeName:String, fetchRequestChangeBlock:(inputFetchRequest:NSFetchRequest) -> NSFetchRequest) -> [AnyObject] {
        var fetchRequest:NSFetchRequest = NSFetchRequest(entityName:entityTypeName)
        
        fetchRequest = fetchRequestChangeBlock(inputFetchRequest: fetchRequest)
        fetchRequest.returnsObjectsAsFaults = false
        
        var error:NSError?
        var result:[AnyObject] = context.executeFetchRequest(fetchRequest, error: &error)
        
        if error {
            NSLog("entitiesOfType error = \(error)")
        }
        
        return result
    }
    
    func countOfEntitiesOfType(entityTypeName:String, fetchRequestChangeBlock:((inputFetchRequest:NSFetchRequest) -> NSFetchRequest)?) -> Int {
        var fetchRequest:NSFetchRequest = NSFetchRequest(entityName:entityTypeName)
        
        if fetchRequestChangeBlock {
            fetchRequest = fetchRequestChangeBlock!(inputFetchRequest: fetchRequest)
        }
        
        var error:NSError?
        var result:Int = context.countForFetchRequest(fetchRequest, error: &error)
        
        if error {
            NSLog("countOfEntitiesOfType error = \(error)")
        }

        return result
    }
}