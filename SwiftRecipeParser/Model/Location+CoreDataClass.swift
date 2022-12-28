//
//  Location+CoreDataClass.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 12/27/22.
//  Copyright © 2022 CarlSmith. All rights reserved.
//
//

import Foundation
import CoreData


public class Location: NSManagedObject {

    class func createOrReturn(databaseInterface: DatabaseInterface,
                              storeName: String,
                              aisle: String,
                              details: String,
                              month: Int,
                              day: Int,
                              year: Int) -> Location? {
        guard let locations = databaseInterface.entitiesOfType(entityTypeName: "Location",
                                                               fetchRequestChangeBlock: { inputFetchRequest in
            inputFetchRequest.sortDescriptors = []
            inputFetchRequest.predicate = NSPredicate(format: "storeName MATCHES %@ AND aisle MATCHES %@ AND details MATCHES %@ AND month == %@ AND day == %@ AND year == %@",
                                                      storeName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                                                      aisle.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                                                      details.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                                                      NSNumber(value: month),
                                                      NSNumber(value: day),
                                                      NSNumber(value: year))
            return inputFetchRequest
        }) as? Array<Location> else {
            Logger.logDetails(msg: "Error fetching Locations")
            return nil
        }
        if locations.isEmpty {
            return createLocation(databaseInterface: databaseInterface,
                                  storeName: storeName,
                                  aisle: aisle,
                                  details: details,
                                  month: month,
                                  day: day,
                                  year: year)
        } else {
            return locations.first!
        }
    }

    class func createLocation(databaseInterface: DatabaseInterface,
                              storeName: String,
                              aisle: String,
                              details: String,
                              month: Int,
                              day: Int,
                              year: Int) -> Location {
        let location:Location = databaseInterface.newManagedObjectOfType(managedObjectClassName: "Location") as! Location
        location.storeName = storeName
        location.aisle = aisle
        location.details = details
        location.month = NSNumber(integerLiteral: month)
        location.day = NSNumber(integerLiteral: day)
        location.year = NSNumber(integerLiteral: year)
        databaseInterface.saveContext()
        return location
    }
}
