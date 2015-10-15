//
//  DatabaseManager.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/25/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class DatabaseManager : NSObject {
    class var instance: DatabaseManager {
    struct Singleton {
        static let instance = DatabaseManager()
        }
        return Singleton.instance
    }
    
    func backgroundOperation(block: (() -> Void)!)
    {
        operationQueue.addOperationWithBlock(block)
    }

    func returnPersistentStoreCoordinator() -> NSPersistentStoreCoordinator {
        return storeCoordinator
    }
    
    func returnMainManagedObjectContext() -> NSManagedObjectContext {
        return mainContext
    }
    
    func contextSaved(notification: NSNotification) {
        if NSThread.isMainThread() {
            mainContext.mergeChangesFromContextDidSaveNotification(notification)
        }
        else {
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                self.mainContext.mergeChangesFromContextDidSaveNotification(notification)
            })
        }
    }
    
    lazy private var operationQueue:NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
        }()
    
    lazy private var storeURL:NSURL = {
        return self.applicationDocumentsDirectory.URLByAppendingPathComponent("SwiftRecipeParser.sqlite")
    }()
    
    lazy private var modelURL:NSURL = {
        return NSBundle.mainBundle().URLForResource("SwiftRecipeParser", withExtension: "momd")!
    }()

    lazy private var model:NSManagedObjectModel = {
        return NSManagedObjectModel(contentsOfURL: self.modelURL)!
    }()

    lazy private var storeCoordinator:NSPersistentStoreCoordinator = {
        let storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel:self.model)
        
        let options = [NSMigratePersistentStoresAutomaticallyOption : 1, NSInferMappingModelAutomaticallyOption : 1]
        
        do {
            try storeCoordinator.addPersistentStoreWithType(NSSQLiteStoreType,
                        configuration: nil, URL: self.storeURL, options: options)
        } catch var error as NSError {
            print("Error adding persistent store to store coordinator: \(error)")
            abort()
        } catch {
            fatalError()
        }
        
        return storeCoordinator
    }()
    
    lazy private var mainContext:NSManagedObjectContext = {
        let mainContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.ConfinementConcurrencyType)
        mainContext.persistentStoreCoordinator = self.storeCoordinator
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"contextSaved:", name: NSManagedObjectContextDidSaveNotification, object: nil)
        return mainContext
    }()
    
    lazy private var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.carlsmithswdev.SwiftRecipeParser" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
        }()
}
