//
//  DatabaseManager.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/25/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class DatabaseManager {
    class var instance: DatabaseManager {
    struct Singleton {
        static let instance = DatabaseManager()
        }
        return Singleton.instance
    }
    
    private let operationQueue:NSOperationQueue!

    private let modelURL:NSURL!
    private let storeURL:NSURL!
    private let model:NSManagedObjectModel!
    private let storeCoordinator:NSPersistentStoreCoordinator!
    private let mainContext:NSManagedObjectContext!
    
    init() {
        operationQueue = NSOperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
    
        modelURL = NSBundle.mainBundle().URLForResource("SwiftRecipeParser", withExtension: "momd")
        storeURL = appDocumentsDir().URLByAppendingPathComponent("SwiftRecipeParser.sqlite")
        NSLog("storeURL = \(storeURL)")
        
        model = NSManagedObjectModel(contentsOfURL: modelURL)
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel:model)
    
        let options = [NSMigratePersistentStoresAutomaticallyOption : 1, NSInferMappingModelAutomaticallyOption : 1]
        var error: NSError?
        
        if storeCoordinator.addPersistentStoreWithType(NSSQLiteStoreType,
            configuration: nil, URL: storeURL, options: options, error: &error) == nil {
                println("Error adding persistent store to store coordinator: \(error)")
                abort()
        }
  
        mainContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.ConfinementConcurrencyType)
        mainContext.persistentStoreCoordinator = storeCoordinator
        
/*
        var fileManager:NSFileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(storeURL.path)
        {
            NSLog("Found store URL file")
        }
*/
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
    
    func appDocumentsDir() -> NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask) as NSArray
        return urls.lastObject as NSURL
    }
}
