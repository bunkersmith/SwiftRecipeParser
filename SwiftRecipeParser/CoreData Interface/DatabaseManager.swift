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

    // Singleton instance
    static let instance = DatabaseManager()
    
    func returnPersistentStoreCoordinator() -> NSPersistentStoreCoordinator {
        return storeCoordinator
    }
    
    func returnMainManagedObjectContext() -> NSManagedObjectContext {
        return mainContext
    }
    
    lazy fileprivate var storeURL:URL = {
        return self.applicationDocumentsDirectory.appendingPathComponent("SwiftRecipeParser.sqlite")
    }()
    
    lazy fileprivate var modelURL:URL = {
        return Bundle.main.url(forResource: "SwiftRecipeParser", withExtension: "momd")
        }()!
    
    lazy fileprivate var model:NSManagedObjectModel = {
        if var returnValue = NSManagedObjectModel(contentsOf: self.modelURL) {
            return returnValue
        }
        else {
            Logger.writeToLogFile("Could not retrieve managed object model")
            return NSManagedObjectModel()
        }
    }()
    
    lazy fileprivate var storeCoordinator:NSPersistentStoreCoordinator = {
        let storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel:self.model)
        
        let options = [NSMigratePersistentStoresAutomaticallyOption : 1, NSInferMappingModelAutomaticallyOption : 1]
        var error: NSError?
        
        do {
            try storeCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                    configurationName: nil, at: self.storeURL, options: options)
        } catch var error1 as NSError {
            error = error1
            Logger.writeToLogFile("Error adding persistent store to store coordinator: \(String(describing: error))")
            abort()
        } catch {
            fatalError()
        }
        
        return storeCoordinator
    }()
    
    lazy fileprivate var mainContext:NSManagedObjectContext = {
        let mainContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        mainContext.persistentStoreCoordinator = self.storeCoordinator
        return mainContext
    }()
    
    lazy fileprivate var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
}
