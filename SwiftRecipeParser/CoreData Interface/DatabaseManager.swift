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
        operationQueue.addOperation(block)
    }

    func returnPersistentStoreCoordinator() -> NSPersistentStoreCoordinator {
        return storeCoordinator
    }
    
    func returnMainManagedObjectContext() -> NSManagedObjectContext {
        return mainContext
    }
    
    func contextSaved(notification: NSNotification) {
        if Thread.isMainThread {
            mainContext.mergeChanges(fromContextDidSave: notification as Notification)
        }
        else {
            DispatchQueue.main.sync(execute: { () -> Void in
                self.mainContext.mergeChanges(fromContextDidSave: notification as Notification)
            })
        }
    }
    
    lazy private var operationQueue:OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
        }()
    
    lazy private var storeURL:URL = {
        return self.applicationDocumentsDirectory.appendingPathComponent("SwiftRecipeParser.sqlite")!
    }()
    
    lazy private var modelURL:URL = {
        return Bundle.main.url(forResource: "SwiftRecipeParser", withExtension: "momd")!
    }()

    lazy private var model:NSManagedObjectModel = {
        return NSManagedObjectModel(contentsOf: self.modelURL as URL)!
    }()

    lazy private var storeCoordinator:NSPersistentStoreCoordinator = {
        let storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel:self.model)
        
        let options = [NSMigratePersistentStoresAutomaticallyOption : 1, NSInferMappingModelAutomaticallyOption : 1]
        
        do {
            let _ = try storeCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                    configurationName: nil, at: self.storeURL, options: options)
        } catch var error as NSError {
            print("Error adding persistent store to store coordinator: \(error)")
            abort()
        } catch {
            fatalError()
        }
        
        return storeCoordinator
    }()
    
    lazy private var mainContext:NSManagedObjectContext = {
        let mainContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.confinementConcurrencyType)
        mainContext.persistentStoreCoordinator = self.storeCoordinator
        NotificationCenter.default.addObserver(self, selector:#selector(DatabaseManager.contextSaved(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
        return mainContext
    }()
    
    lazy private var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.carlsmithswdev.SwiftRecipeParser" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL 
        }()
}
