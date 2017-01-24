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
        if Thread.isMainThread {
            context = databaseManager.returnMainManagedObjectContext()
        }
        else {
            context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.confinementConcurrencyType)
            context.persistentStoreCoordinator = databaseManager.returnPersistentStoreCoordinator()
        }
        
        //NSLog("context = \(context)")
    }
    
    func newManagedObjectOfType(managedObjectClassName:String) -> NSManagedObject {
        let entityDescription:NSEntityDescription = NSEntityDescription.entity(forEntityName: managedObjectClassName, in: context)!
        
        return NSManagedObject(entity: entityDescription, insertInto: context)
    }
    
    func saveContext() {
        if context != nil {
            do {
                try context.save()
            } catch let error as NSError {
                Logger.logDetails(msg: "Error saving context in DatabaseInterface.saveContext(): \(error)")
            }
        }
        else {
            Logger.logDetails(msg: "No context in DatabaseInterface.saveContext()")
        }
    }
    
    func entitiesOfType(entityTypeName:String, fetchRequestChangeBlock:((_ inputFetchRequest:NSFetchRequest<NSFetchRequestResult>) -> NSFetchRequest<NSFetchRequestResult>)?) -> [AnyObject] {
        var fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName:entityTypeName)
        
        if fetchRequestChangeBlock != nil {
            fetchRequest = fetchRequestChangeBlock!(fetchRequest)
        }
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let result:[AnyObject] = try context.fetch(fetchRequest)
            return result
        } catch let error as NSError {
            Logger.logDetails(msg: "entitiesOfType error = \(error)")
        }
        
        return [AnyObject]()
    }
    
    func entitiesOfType(entityTypeName:String, predicate: NSPredicate?) -> [AnyObject] {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName:entityTypeName)
        
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let result:[AnyObject] = try context.fetch(fetchRequest)
            return result
        }
        catch let error as NSError  {
            Logger.logDetails(msg: "entitiesOfType error = \(error)")
        }
        
        return [AnyObject]()
    }
    
    func countOfEntitiesOfType(entityTypeName:String, fetchRequestChangeBlock:((_ inputFetchRequest:NSFetchRequest<NSFetchRequestResult>) -> NSFetchRequest<NSFetchRequestResult>)?) -> Int {
        var fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName:entityTypeName)
        
        if fetchRequestChangeBlock != nil {
            fetchRequest = fetchRequestChangeBlock!(fetchRequest)
        }

        var result:Int = 0
        
        do {
            result = try context.count(for: fetchRequest)
        } catch let error as NSError {
            Logger.logDetails(msg: "countOfEntitiesOfType error = \(error)")
        }
        
        return result
    }
    
    func countOfEntitiesOfType(entityTypeName:String, predicate:NSPredicate?) -> Int {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName:entityTypeName)
        
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        
        var result:Int = 0
        
        do {
            result = try context.count(for: fetchRequest)
        }
        catch let error as NSError {
            Logger.logDetails(msg: "countOfEntitiesOfType error = \(error)")
        }
        
        return result
    }

    func createFetchedResultsController(entityName:String, sortKey:String, secondarySortKey:String?, sectionNameKeyPath:String?, predicate:NSPredicate?) -> NSFetchedResultsController<NSFetchRequestResult> {
        var fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        
        let sortDescriptor:NSSortDescriptor = NSSortDescriptor(key: sortKey, ascending: true)
        var sortDescriptors = [sortDescriptor]
        if let localSecondarySortKey = secondarySortKey {
            let secondarySortDescriptor:NSSortDescriptor = NSSortDescriptor(key: localSecondarySortKey, ascending: true)
            sortDescriptors = [sortDescriptor, secondarySortDescriptor]
        }
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.fetchBatchSize = 30
        fetchRequest.returnsObjectsAsFaults = false
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            Logger.logDetails(msg: "Error initializing fetchedResultsController for \(entityName): \(error)")
        }
        
        return fetchedResultsController
    }
    
    func deleteObject(coreDataObject:AnyObject)
    {
        context.delete(coreDataObject as! NSManagedObject);
        saveContext()
    }
    
    func deleteAllObjectsWithEntityName(entityName: String)
    {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        let entity = NSEntityDescription.entity(forEntityName: entityName, in:context)
        fetchRequest.entity = entity
        
        do {
            if let items:[NSManagedObject] = try context.fetch(fetchRequest) as? [NSManagedObject] {
                for managedObject:NSManagedObject in items {
                    context.delete(managedObject)
                }
                saveContext()
            }
            else {
                Logger.logDetails(msg: "Could not downcast entities named \(entityName) in deleteAllObjectsWithEntityName")
            }
        }
        catch let error as NSError {
            Logger.logDetails(msg: "Error fetching (before deleting) all entities named \(entityName): \(error)")
        }
    }
}
