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
    
    override init() {
        super.init()
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
        let entityDescription:NSEntityDescription = NSEntityDescription.entityForName(managedObjectClassName, inManagedObjectContext: context)!
        
        return NSManagedObject(entity: entityDescription, insertIntoManagedObjectContext: context)
    }
    
    func saveContext() {
        var error:NSError?
        if context != nil {
            if !context.save(&error) {
                NSLog("Error saving context in DatabaseInterface.saveContext(): \(error)")
            }
        }
        else {
            NSLog("No context in DatabaseInterface.saveContext()")
        }
    }
    
    func entitiesOfType(entityTypeName:String, fetchRequestChangeBlock:((inputFetchRequest:NSFetchRequest) -> NSFetchRequest)?) -> [AnyObject] {
        var fetchRequest:NSFetchRequest = NSFetchRequest(entityName:entityTypeName)
        
        if fetchRequestChangeBlock != nil {
            fetchRequest = fetchRequestChangeBlock!(inputFetchRequest: fetchRequest)
        }
        fetchRequest.returnsObjectsAsFaults = false
        
        var error:NSError?
        var result:[AnyObject] = context.executeFetchRequest(fetchRequest, error: &error)!
        
        if error != nil {
            NSLog("entitiesOfType error = \(error)")
        }
        
        return result
    }
    
    func entitiesOfType(entityTypeName:String, predicate: NSPredicate?) -> [AnyObject] {
        var fetchRequest:NSFetchRequest = NSFetchRequest(entityName:entityTypeName)
        
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        fetchRequest.returnsObjectsAsFaults = false
        
        var error:NSError?
        var result:[AnyObject] = context.executeFetchRequest(fetchRequest, error: &error)!
        
        if error != nil {
            NSLog("entitiesOfType error = \(error)")
        }
        
        return result
    }
    
    func countOfEntitiesOfType(entityTypeName:String, fetchRequestChangeBlock:((inputFetchRequest:NSFetchRequest) -> NSFetchRequest)?) -> Int {
        var fetchRequest:NSFetchRequest = NSFetchRequest(entityName:entityTypeName)
        
        if fetchRequestChangeBlock != nil {
            fetchRequest = fetchRequestChangeBlock!(inputFetchRequest: fetchRequest)
        }
        
        var error:NSError?
        var result:Int = context.countForFetchRequest(fetchRequest, error: &error)
        
        if error != nil {
            NSLog("countOfEntitiesOfType error = \(error)")
        }

        return result
    }
    
    func countOfEntitiesOfType(entityTypeName:String, predicate:NSPredicate?) -> Int {
        var fetchRequest:NSFetchRequest = NSFetchRequest(entityName:entityTypeName)
        
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        
        var error:NSError?
        var result:Int = context.countForFetchRequest(fetchRequest, error: &error)
        
        if error != nil {
            NSLog("countOfEntitiesOfType error = \(error)")
        }
        
        return result
    }

    func createFetchedResultsController(entityName:String, sortKey:String, secondarySortKey:String?, sectionNameKeyPath:String?, predicate:NSPredicate?) -> NSFetchedResultsController {
        var fetchedResultsController:NSFetchedResultsController
        var fetchRequest:NSFetchRequest = NSFetchRequest(entityName: entityName)
        
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        
        var sortDescriptor:NSSortDescriptor = NSSortDescriptor(key: sortKey, ascending: true)
        var sortDescriptors = [sortDescriptor]
        if var localSecondarySortKey = secondarySortKey {
            var secondarySortDescriptor:NSSortDescriptor = NSSortDescriptor(key: localSecondarySortKey, ascending: true)
            sortDescriptors = [sortDescriptor, secondarySortDescriptor]
        }
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.fetchBatchSize = 30
        fetchRequest.returnsObjectsAsFaults = false
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        
        var error:NSError?
        if !fetchedResultsController.performFetch(&error) {
            NSLog("Error initializing fetchedResultsController for \(entityName): \(error)")
        }
        
        return fetchedResultsController
    }
    
    func deleteObject(coreDataObject:AnyObject)
    {
        context.deleteObject(coreDataObject as! NSManagedObject);
        saveContext()
    }
}