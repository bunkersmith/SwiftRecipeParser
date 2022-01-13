//
//  ShoppingTrip+CoreDataClass.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 1/12/22.
//  Copyright © 2022 CarlSmith. All rights reserved.
//
//

import Foundation
import CoreData


public class ShoppingTrip: NSManagedObject {

    class func create(databaseInterface: DatabaseInterface) -> ShoppingTrip {
        let shoppingTrip = databaseInterface.newManagedObjectOfType(managedObjectClassName: "ShoppingTrip") as! ShoppingTrip
        return shoppingTrip
    }
    
    class func createOrReturn(databaseInterface: DatabaseInterface) -> ShoppingTrip {
        let shoppingTrips = databaseInterface.entitiesOfType(entityTypeName: "ShoppingTrip", predicate: nil)
        if shoppingTrips.count == 0 {
            return create(databaseInterface: databaseInterface)
        } else {
            return shoppingTrips.first as! ShoppingTrip
        }
    }

}
