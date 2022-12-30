//
//  GroceryListItem.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/7/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit

struct GroceryListItemStruct: CustomStringConvertible {
    var name: String
    var quantity: Float
    var cost: Float
    var units: String
    var isTaxable: Bool
    var taxablePrice: Float
    var isCRV: Bool
    var crvQuantity: Int
    var crvFluidOunces: Float
    var isFSA: Bool
    var notes: String
    var imagePath: String
    var produceCode: Int32
    var locationStoreName: String
    var locationAisle: String
    var locationDetails: String
    var locationMonth: Int
    var locationDay: Int
    var locationYear: Int

    public init(name: String,
                quantity: Float,
                cost: Float,
                units: String,
                isTaxable: Bool,
                taxablePrice: Float,
                isCRV: Bool,
                crvQuantity: Int,
                crvFluidOunces: Float,
                isFSA: Bool,
                notes: String,
                imagePath: String,
                produceCode: Int32,
                locationStoreName: String,
                locationAisle: String,
                locationDetails: String,
                locationMonth: Int,
                locationDay: Int,
                locationYear: Int) {
        self.name = name
        self.quantity = quantity
        self.cost = cost
        self.units = units
        self.isTaxable = isTaxable
        self.taxablePrice = taxablePrice
        self.isCRV = isCRV
        self.crvQuantity = crvQuantity
        self.crvFluidOunces = crvFluidOunces
        self.isFSA = isFSA
        self.notes = notes
        self.imagePath = imagePath
        self.produceCode = produceCode
        self.locationStoreName = locationStoreName
        self.locationAisle = locationAisle
        self.locationDetails = locationDetails
        self.locationMonth = locationMonth
        self.locationDay = locationDay
        self.locationYear = locationYear
    }
    
    var description: String {
        var returnValue:String
        
        returnValue = "\n***** GroceryListItemStruct"
        returnValue += "\nname = \(name)"
        returnValue += "\ncost = \(cost)"
        returnValue += "\nquantity = \(quantity)"
        returnValue += "\nunits = \(units)"
        if isTaxable {
            returnValue += "\nisTaxable = \(isTaxable)"
            if taxablePrice > 0 {
                returnValue += "\ntaxablePrice = \(taxablePrice)"
            }
        }
        if isCRV {
            returnValue += "\nisCRV = \(isCRV)"
            returnValue += "\ncrvQuantity = \(crvQuantity)"
            returnValue += "\ncrvFluidOunces = \(crvFluidOunces)"
        }
        if isFSA {
            returnValue += "\nisFsa = \(isFSA)"
        }
        if !notes.isEmpty {
            returnValue += "\nnotes = \(notes)"
        }
        if !imagePath.isEmpty {
            returnValue += "\nimagePath = \(imagePath)"
        }
        if !locationStoreName.isEmpty {
            returnValue += "\nlocationStoreName = \(locationStoreName)"
        }
        if !locationAisle.isEmpty {
            returnValue += "\nlocationAisle = \(locationAisle)"
        }
        if !locationDetails.isEmpty {
            returnValue += "\nlocationDetails = \(locationDetails)"
        }
        if locationMonth != 0 {
            returnValue += "\nlocationMonth = \(locationMonth)"
        }
        if locationDay != 0 {
            returnValue += "\nlocationDay = \(locationDay)"
        }
        if locationYear != 0 {
            returnValue += "\nlocationYear = \(locationYear)"
        }

        return returnValue
    }
}

class GroceryListItem: NSManagedObject {

    @NSManaged var cost: NSNumber
    @NSManaged var totalCost: NSNumber
    @NSManaged var isBought: NSNumber
    @NSManaged var name: String
    @NSManaged var quantity: NSNumber
    @NSManaged var unitOfMeasure: String
    @NSManaged var isTaxable: NSNumber
    @NSManaged var taxablePrice: NSNumber
    @NSManaged var isFsa: NSNumber
    @NSManaged var isCrv: NSNumber
    @NSManaged var crvQuantity: NSNumber
    @NSManaged var crvFluidOunces: NSNumber
    @NSManaged var imagePath: String?
    @NSManaged var inGroceryList: GroceryList
    @NSManaged var notes: String
    @NSManaged var listPosition: NSNumber
    @NSManaged var produceCode: NSNumber
    @NSManaged var location: Location?
    
    override var description: String {
        var returnValue:String
        
        returnValue = "\n***** GroceryListItem"
        returnValue += "\nname = \(name)"
        returnValue += "\ncost = \(cost)"
        returnValue += "\nquantity = \(quantity)"
        returnValue += "\nunitOfMeasure = \(unitOfMeasure)"
        if isBought.boolValue {
            returnValue += "\nisBought = \(isBought)"
        }
        if isTaxable.boolValue {
            returnValue += "\nisTaxable = \(isTaxable)"
            if taxablePrice.floatValue > 0 {
                returnValue += "\ntaxablePrice = \(taxablePrice)"
            }
        }
        if isCrv.boolValue {
            returnValue += "\nisCrv = \(isCrv)"
            returnValue += "\ncrvQuantity = \(crvQuantity.intValue)"
            returnValue += "\ncrvFluidOunces = \(crvFluidOunces.floatValue)"
        }
        if isFsa.boolValue {
            returnValue += "\nisFsa = \(isFsa)"
        }
        if let imagePath = imagePath {
            returnValue += "\nimagePath = \(imagePath)"
        }
        if !notes.isEmpty {
            returnValue += "\nnotes = \(notes)"
        }
        if produceCode.int32Value > 0 {
            returnValue += "\nproduceCode = \(produceCode.int32Value)"
        }
        if let descLocation = location {
            if !descLocation.storeName!.isEmpty {
                returnValue += "\nstoreName = \(descLocation.storeName ?? "None")"
            }
            if !descLocation.aisle!.isEmpty {
                returnValue += "\naisle = \(descLocation.aisle ?? "None")"
            }
            if !descLocation.details!.isEmpty {
                returnValue += "\ndetails = \(descLocation.details ?? "None")"
            }
            if descLocation.month != 0 {
                returnValue += "\nmonth = \(descLocation.month ?? 0)"
            }
            if descLocation.day != 0 {
                returnValue += "\nday = \(descLocation.day ?? 0)"
            }
            if descLocation.year != 0 {
                returnValue += "\nyear = \(descLocation.year ?? 0)"
            }
        }
        
        returnValue += "\nlistPosition = \(listPosition)"
        
        return returnValue
    }
    
    class func findGroceryListItemWithName(name: String) -> GroceryListItem? {
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        if let groceryListItems = databaseInterface.entitiesOfType(entityTypeName: "GroceryListItem", predicate: NSPredicate(format: "name MATCHES %@", name)) as? Array<GroceryListItem> {
            if groceryListItems.count == 1 {
                return groceryListItems.first
            }
        }
        return nil
    }
    
    class func findGroceryListItemWithName(name: String, inListNamed: String) -> GroceryListItem? {
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        if let groceryListItems = databaseInterface.entitiesOfType(entityTypeName: "GroceryListItem", predicate: NSPredicate(format: "name MATCHES %@ AND inGroceryList.name MATCHES %@", name, inListNamed)) as? Array<GroceryListItem> {
            if groceryListItems.count == 1 {
                return groceryListItems.first
            }
        }
        return nil
    }

    class func create(name: String, cost: Float, quantity: Float, unitOfMeasure: String) -> GroceryListItem? {
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        
        if let groceryListItem:GroceryListItem = databaseInterface.newManagedObjectOfType(managedObjectClassName: "GroceryListItem") as? GroceryListItem {
            groceryListItem.name = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).capitalized
            groceryListItem.isBought = NSNumber(value: false)
            groceryListItem.cost = NSNumber(value: cost)
            groceryListItem.quantity = NSNumber(value: quantity)
            groceryListItem.unitOfMeasure = unitOfMeasure
            groceryListItem.isTaxable = NSNumber(value: false)
            groceryListItem.isFsa = NSNumber(value: false)
            groceryListItem.isCrv = NSNumber(value: false)

            groceryListItem.calculateTotalCost()
            
            databaseInterface.saveContext()
            
            groceryListItem.writeToIcloud()
            
            return groceryListItem
        }
        
        return nil
    }

    class func createOrReturn(name: String, cost: Float, quantity: Float, unitOfMeasure: String, databaseInterface: DatabaseInterface?) -> GroceryListItem? {
        var localDatabaseInterface: DatabaseInterface
        
        if databaseInterface == nil {
            localDatabaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        } else {
            localDatabaseInterface = databaseInterface!
        }
        
        let localName = name.trimmingCharacters(in: .whitespaces)
        
        let groceryListItems = localDatabaseInterface.entitiesOfType(entityTypeName: "GroceryListItem", predicate: NSPredicate(format: "name MATCHES %@", localName))
        
        if groceryListItems.count == 0 {
            //Logger.logDetails(msg: "Returning created item")
            return create(name: localName, cost: cost, quantity: quantity, unitOfMeasure: unitOfMeasure)
        }
        
        if groceryListItems.count >= 1 {
            if let groceryListItem = groceryListItems.first as? GroceryListItem {
                //Logger.logDetails(msg: "Returning existing item")
                
                if cost != 0 {
                    groceryListItem.cost = NSNumber(value: cost)
                }
                groceryListItem.unitOfMeasure = unitOfMeasure
                groceryListItem.quantity = NSNumber(value: quantity)
                localDatabaseInterface.saveContext()
                
                return groceryListItem
            }
        }
        
        return nil
    }
    
    class func rename(oldName: String, newName: String, databaseInterface: DatabaseInterface) {
        guard let oldItem = findGroceryListItemWithName(name: oldName) else {
            Logger.logDetails(msg: "Could not find old grocery list item")
            return
        }

        oldItem.name = newName
        databaseInterface.saveContext()
    }
    
    class func readAllFromIcloud(viewController: UIViewController, completionHandler:@escaping ((Bool) -> Void)) {
        
        let model = CKModel.currentModel

        model.readAllIcloudGroceryListItems { cloudGroceryListItems, error in
            if error != nil {
                completionHandler(false)
                return
            }
            
            let databaseInterface = DatabaseInterface(concurrencyType: .privateQueueConcurrencyType)
            
            databaseInterface.performInBackground {
                
                for cloudGroceryListItem in cloudGroceryListItems {
                    if !cloudGroceryListItem.name.isEmpty {
                        let item = GroceryListItem.createOrReturn(name: cloudGroceryListItem.name,
                                                                  cost: Float(cloudGroceryListItem.cost),
                                                                  quantity: Float(cloudGroceryListItem.quantity),
                                                                  unitOfMeasure: cloudGroceryListItem.unitOfMeasure,
                                                                  databaseInterface: databaseInterface)
                        if item != nil {
                            item!.update(fsa: cloudGroceryListItem.isFsa != 0)
                            item!.update(crv: cloudGroceryListItem.isCrv != 0)
                            item!.update(crvFluidOunces: Float(cloudGroceryListItem.crvFluidOunces))
                            item!.update(crvQuantity: Int(cloudGroceryListItem.crvQuantity))
                            item!.update(taxable: cloudGroceryListItem.isTaxable != 0)
                            item!.update(taxablePrice: Float(cloudGroceryListItem.taxablePrice))
                            item!.update(notes: cloudGroceryListItem.notes)
                            databaseInterface.saveContext()
                        } else {
                            completionHandler(false)
                            return
                        }
                    }
                }
                    
                completionHandler(true)
            }
        }
    }

    class func writeAllToIcloud(viewController: UIViewController) {
        var startTime = MillisecondTimer.currentTickCount()
        
        guard let groceryListItems = fetchAll() else {
            Logger.logDetails(msg: "Error fetching Grocery List Items")
            return
        }
        
        Logger.logDetails(msg: "Fetch request time: \(MillisecondTimer.secondsSince(startTime: startTime)) for \(groceryListItems.count) items")
        
        startTime = MillisecondTimer.currentTickCount()
        
        let model = CKModel.currentModel
        var records = [CKRecord]()
        
//        Logger.logDetails(msg: "Count of groceryListItems = \(groceryListItems.count)")
        
        for groceryListItem in groceryListItems {
            let record = CKRecord(recordType: CloudGroceryListItem.recordType)
            model.updateCKRecordFromGroceryListItem(groceryListItem: groceryListItem, record: record)
            records.append(record)
        }
        
        var totalRecordsWritten = 0
        
        IToast().showToast(viewController, alertTitle: "SwiftRecipeParser Alert", alertMessage: "iCloud write beginning", duration: 2, completionHandler: nil)
        
        model.writeGroceryListItemRecords(groceryListItemRecords: records) { records, error in
            if error != nil {
                Logger.logDetails(msg: "Error writing GroceryListItemRecords: \(error!)")
            } else {
                let totalWriteTime = MillisecondTimer.secondsSince(startTime: startTime)
                if records.count > 0 {
                    totalRecordsWritten += records.count
                    if totalRecordsWritten == groceryListItems.count {
                        Logger.logDetails(msg: String(format: "Wrote \(records.count) GroceryListItemRecords successfully in %.3f seconds (%.3f) per record", totalWriteTime, totalWriteTime/Double(records.count)))
                        DispatchQueue.main.async {
                            IToast().showToast(viewController, alertTitle: "SwiftRecipeParser Alert", alertMessage: "\(totalRecordsWritten) total records written", duration: 2, completionHandler: nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            IToast().showToast(viewController, alertTitle: "SwiftRecipeParser Alert", alertMessage: "\(totalRecordsWritten) of \(groceryListItems.count) records written", duration: 2, completionHandler: nil)
                        }
                    }
                }
            }
        }
    }
    
    func writeToIcloud() {
        CKModel.currentModel.writeOrUpdateGroceryListItem(groceryListItem: self) { error in
            if error != nil {
                Logger.logDetails(msg: "Error writing \(self.name) to iCloud: \(String(describing: error))")
            }
        }
    }
    
    class func fetchAll() -> Array<GroceryListItem>? {
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        
        let groceryListItems = databaseInterface.entitiesOfType(entityTypeName: "GroceryListItem") { inputFetchRequest in
            let sortDescriptor:NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            inputFetchRequest.sortDescriptors = [sortDescriptor]
            
            return inputFetchRequest
        } as? Array<GroceryListItem>
        
        if groceryListItems != nil {
            Logger.logDetails(msg: "Count of groceryListItems = \(groceryListItems!.count)")
        }
        
        return groceryListItems
    }
    
    class func writeItemImagePaths() {
        
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        
        for groceryItem in fetchAll()! {
            if groceryItem.imagePath != nil {
                // The accepted answer to the SO question below indicates that:
                
                // URL.path is appropriate for local files
                // URL.absoluteString is appropriate for remote URLs
                
                // https://stackoverflow.com/questions/16176911/nsurl-path-vs-absolutestring
                groceryItem.imagePath = "\(groceryItem.name).jpg"
                databaseInterface.saveContext()
            }
        }
        
    }
    
    class func calculateAllTotalCosts() {
        
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        
        for groceryItem in fetchAll()! {
            groceryItem.calculateTotalCost()
            databaseInterface.saveContext()
        }
    }
    
    class func allItemsToData() -> Data? {
        guard let allItems = fetchAll() else {
            Logger.logDetails(msg: "Error fetching all Grocery List Items")
            return nil
        }
        
        var fileString = ""
        
        for item in allItems {
            fileString += item.convertToShortOneLineString()
        }
        
        return Data(fileString.utf8)
    }
    
    func writeImageDataToJpeg(imageData: Data) {
        guard let image = UIImage(data: imageData) else {
            return
        }
        
        guard let data = UIImageJPEGRepresentation(image, 0.8) else {
            return
        }
        
        let filename = FileUtilities.applicationDocumentsDirectory().appendingPathComponent("\(name).jpg")
        
        do {
            try data.write(to: filename)
        } catch let error as NSError {
            Logger.logDetails(msg: "File write error: \(error)")
        }
    }
    
    func readItemImage() -> UIImage? {
        let filename = FileUtilities.applicationDocumentsDirectory().appendingPathComponent("\(name).jpg")

        do {
            let imageData = try Data(contentsOf: filename)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
            return nil
        }
    }
    
    class func addItemToString(groceryListItem:GroceryListItem, string: String) -> String {
        let itemString = groceryListItem.convertToShortOneLineString().trimmingCharacters(in: .newlines) + "\timagePath:\(groceryListItem.imagePath ?? "")"
        
        return "\(string)\n\(itemString)"
    }
    
    func convertToShortOneLineString() -> String {
        var returnValue = "name:\t" + name
        returnValue += "\tquantity:\t\(quantity.floatValue)"
        returnValue += "\tunits:\t" + unitOfMeasure
        returnValue += String(format: "\tcost:\t%.2f", cost.floatValue)
        if isTaxable.boolValue {
            returnValue += "\tisTaxable:\t\(isTaxable.boolValue)"
            let taxablePrice = taxablePrice.floatValue
            if taxablePrice > 0 {
                returnValue += String(format: "\ttaxablePrice:\t%.2f", taxablePrice)
            }
        }
        if isCrv.boolValue {
            returnValue += "\tisCRV:\t\(isCrv.boolValue)"
            returnValue += "\tcrvQuantity:\t\(crvQuantity.intValue)"
            returnValue += "\tcrvFluidOunces:\t\(crvFluidOunces.floatValue)"
        }
        if isFsa.boolValue {
            returnValue += "\tisFSA:\t\(isFsa.boolValue)"
        }
        if !notes.isEmpty {
            returnValue += "\tnotes:\t" + notes
        }
        let produceCode = produceCode.int32Value
        if produceCode != 0 {
            returnValue += "\tproduceCode:\t" + String(produceCode)
        }

        if location != nil {
            returnValue += "\tlocStoreName:\t\(location!.storeName!)"
            returnValue += "\tlocAisle:\t\(location!.aisle!)"
            returnValue += "\tlocDetails:\t\(location!.details!)"
// ANDROID MONTHS ARE 0..11. THE ANDROID APP TAKES CARE OF CONVERTING THEM.
            returnValue += "\tlocMonth:\t\(location!.month!)"
            returnValue += "\tlocDay:\t\(location!.day!)"
            returnValue += "\tlocYear:\t\(location!.year!)"
        }
        
        returnValue += "\n"
        return returnValue
    }

    class func parseGroceryListItemString(string: String, databaseInterface: DatabaseInterface?) -> GroceryListItem? {
        
        var localDatabaseInterface: DatabaseInterface
        
        if databaseInterface == nil {
            localDatabaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        } else {
            localDatabaseInterface = databaseInterface!
        }
        
        let tokens = string.components(separatedBy: "\t")
        
        var i = 0
        
        var groceryListItemStruct = GroceryListItemStruct(name: "",
                                                          quantity: 0,
                                                          cost: 0,
                                                          units: "",
                                                          isTaxable: false,
                                                          taxablePrice: 0,
                                                          isCRV: false,
                                                          crvQuantity: 0,
                                                          crvFluidOunces: 0,
                                                          isFSA: false,
                                                          notes: "",
                                                          imagePath: "",
                                                          produceCode: 0,
                                                          locationStoreName: "",
                                                          locationAisle: "",
                                                          locationDetails: "",
                                                          locationMonth: -1,
                                                          locationDay: 0,
                                                          locationYear: 0)
        
        while i < tokens.count {
            
            switch tokens[i] {
                case "name:":
                    groceryListItemStruct.name = tokens[i+1]
                break
                case "quantity:":
                    groceryListItemStruct.quantity = Float(tokens[i+1])!
                break
                case "units:":
                    groceryListItemStruct.units = tokens[i+1]
                break
                case "cost:":
                    groceryListItemStruct.cost = Float(tokens[i+1])!
                break
                case "isTaxable:":
                    groceryListItemStruct.isTaxable = tokens[i+1] == "true" ? true : false
                break
                case "taxablePrice:":
                    groceryListItemStruct.taxablePrice = Float(tokens[i+1])!
                break
                case "isCRV:":
                    groceryListItemStruct.isCRV = tokens[i+1] == "true" ? true : false
                break
                case "crvQuantity:":
                    groceryListItemStruct.crvQuantity = Int(tokens[i+1])!
                break
                case "crvFluidOunces:":
                    groceryListItemStruct.crvFluidOunces = Float(tokens[i+1])!
                break
                case "isFSA:":
                    groceryListItemStruct.isFSA = tokens[i+1] == "true" ? true : false
                break
                case "notes:":
                    groceryListItemStruct.notes = tokens[i+1]
                break
                case "imagePath:":
                    if i + 1 < tokens.count {
                        groceryListItemStruct.imagePath = tokens[i+1]
                    }
                break
                case "produceCode:":
                    groceryListItemStruct.produceCode = Int32(tokens[i+1])!
                break
                case "locStoreName:":
                    Logger.logDetails(msg:"Location Store Name - " + tokens[i + 1])
                    groceryListItemStruct.locationStoreName = tokens[i+1]
                break
                case "locAisle:":
                    Logger.logDetails(msg:"Location Aisle - " + tokens[i + 1])
                    groceryListItemStruct.locationAisle = tokens[i+1]
                break
                case "locDetails:":
                    Logger.logDetails(msg:"Location Details - " + tokens[i + 1])
                    groceryListItemStruct.locationDetails = tokens[i+1]
                break
                case "locMonth:":
// ANDROID MONTHS ARE 0..11. THE ANDROID APP TAKES CARE OF CONVERTING THEM.
                    Logger.logDetails(msg:"Location Month - " + tokens[i + 1])
                    groceryListItemStruct.locationMonth = Int(tokens[i+1])!
                break
                case "locDay:":
                    Logger.logDetails(msg:"Location Day - " + tokens[i + 1])
                    groceryListItemStruct.locationDay = Int(tokens[i+1])!
                break
                case "locYear:":
                    Logger.logDetails(msg:"Location Year - " + tokens[i + 1])
                    groceryListItemStruct.locationYear = Int(tokens[i+1])!
                break
//                case "webLink:":
//                groceryListItemStruct.webLink = tokens[i+1].replacingOccurrences(of: "%3A", with: ":")
//                break
                default:
                break
            }
            i += 2
        }
        
        print(groceryListItemStruct)
        
        guard let groceryListItem = createOrReturn(name: groceryListItemStruct.name,
                                                   cost: groceryListItemStruct.cost,
                                                   quantity: groceryListItemStruct.quantity,
                                                   unitOfMeasure: groceryListItemStruct.units,
                                                   databaseInterface: localDatabaseInterface) else {
            return nil
        }
        
        groceryListItem.update(quantity: groceryListItemStruct.quantity)
        
        groceryListItem.update(unitOfMeasure: groceryListItemStruct.units)
        
        print(groceryListItem)
        
        if groceryListItemStruct.isTaxable {
            groceryListItem.update(taxable: true)
            if groceryListItemStruct.taxablePrice > 0 {
                groceryListItem.update(taxablePrice: groceryListItemStruct.taxablePrice)
            }
        }
        
        if groceryListItemStruct.isCRV {
            groceryListItem.update(crv: true)
            groceryListItem.update(crvQuantity: groceryListItemStruct.crvQuantity)
            groceryListItem.update(crvFluidOunces: groceryListItemStruct.crvFluidOunces)
        }
        
        if groceryListItemStruct.isFSA {
            groceryListItem.update(fsa: true)
        }
        
        if !groceryListItemStruct.notes.isEmpty {
            groceryListItem.update(notes: groceryListItemStruct.notes)
        }
        
        if !groceryListItemStruct.imagePath.isEmpty {
            groceryListItem.update(imagePath: groceryListItemStruct.imagePath)
        }

        groceryListItem.calculateTotalCost()
        
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        
        groceryListLocationFromStruct(databaseInterface: databaseInterface,
                                      groceryListItem: groceryListItem,
                                      groceryListItemStruct: groceryListItemStruct)
        
        databaseInterface.saveContext()
        
        print(groceryListItem)
        
        return groceryListItem
    }

    class func groceryListLocationFromStruct(databaseInterface: DatabaseInterface,
                                             groceryListItem: GroceryListItem,
                                             groceryListItemStruct: GroceryListItemStruct) {
        if (!groceryListItemStruct.locationStoreName.isEmpty ||
            !groceryListItemStruct.locationAisle.isEmpty ||
            !groceryListItemStruct.locationDetails.isEmpty ||
            groceryListItemStruct.locationMonth != -1 ||
            groceryListItemStruct.locationDay != 0 ||
            groceryListItemStruct.locationYear != 0 ) {
            var locationMonth = groceryListItemStruct.locationMonth
            if (locationMonth == -1) {
                locationMonth = 1
            }
            groceryListItem.setLocation(databaseInterface: databaseInterface,
                                        storeName: groceryListItemStruct.locationStoreName,
                                        aisle: groceryListItemStruct.locationAisle,
                                        details: groceryListItemStruct.locationDetails,
                                        month: locationMonth,
                                        day: groceryListItemStruct.locationDay,
                                        year: groceryListItemStruct.locationYear)
        }
    }

    func setLocation(databaseInterface: DatabaseInterface,
                    storeName: String,
                    aisle: String,
                    details: String,
                    month: Int,
                    day: Int,
                    year: Int) {
        let location = Location.createOrReturn(databaseInterface: databaseInterface,
                                               storeName: storeName,
                                               aisle: aisle,
                                               details: details,
                                               month: month,
                                               day: day,
                                               year: year)
        self.location = location
        databaseInterface.saveContext()
    }

    func calculateTotalCost() {
        var localTotalCost = cost.floatValue
        
        if isFsa.boolValue {
            localTotalCost = 0.0
        } else {
            if isCrv.boolValue {
                localTotalCost += calculateCrvCharge()
            }
            
            if isTaxable.boolValue {
                if taxablePrice.floatValue > 0 {
                    localTotalCost += taxablePrice.floatValue * 0.0775
                } else {
                    localTotalCost *= 1.0775
                }
            }
            
            if ((unitOfMeasure == "ea") || (unitOfMeasure == "lb") || (unitOfMeasure == "lbs")) && quantity.doubleValue != 1 {
                localTotalCost *= Float(quantity.doubleValue)
            }
        }
        
        totalCost = NSNumber(value: localTotalCost)
    }
    
    func calculateTax() -> Float {
        var totalTax: Float = 0
        
        
        if isCrv.boolValue {
            totalTax += calculateCrvCharge() * 0.0775
        }
        
        if isTaxable.boolValue {
            if taxablePrice.floatValue > 0 {
                totalTax += taxablePrice.floatValue * 0.0775
            } else {
                totalTax += cost.floatValue * 0.0775
            }
        }

        return totalTax
    }
    
    func stringForPrinting() -> String {
        var returnValue = ""
        
        returnValue += String(format: "\(name) $%.2f", cost.floatValue * quantity.floatValue)
        
        returnValue += isTaxable.boolValue ? "T\n" : "\n"
        
        if isCrv.boolValue {
            returnValue += String(format: "CRV $%.2f\n", calculateCrvCharge())
        }

        if quantity.floatValue != 1.0 {
            returnValue += String(format: "%.2f @ $%.2f / \(unitOfMeasure)\n", quantity.floatValue, cost.floatValue)
        }
        
        return returnValue
    }
    
    func totalCostString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.roundingMode = NumberFormatter.RoundingMode.halfUp
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        return "$\(formatter.string(from: totalCost)!)"
    }
    
    func calculateCrvCharge() -> Float {
        let crvCharge:Float = (crvFluidOunces.floatValue < 24.0) ? 0.05 : 0.1
        return crvCharge * Float(crvQuantity.intValue)
    }
    
    fileprivate func update(cost: Float) {
        self.cost = NSNumber(value: cost)
    }

    fileprivate func update(unitOfMeasure: String) {
        self.unitOfMeasure = unitOfMeasure
    }

    fileprivate func update(quantity: Float) {
        self.quantity = NSNumber(value: quantity)
    }

    fileprivate func update(bought: Bool) {
        isBought = NSNumber(value: bought)
    }

    fileprivate func update(taxable: Bool) {
        isTaxable = NSNumber(value: taxable)
    }

    fileprivate func update(taxablePrice: Float) {
        self.taxablePrice = NSNumber(value: taxablePrice)
    }

    fileprivate func update(fsa: Bool) {
        isFsa = NSNumber(value: fsa)
    }

    fileprivate func update(crv: Bool) {
        isCrv = NSNumber(value: crv)
    }

    fileprivate func update(crvQuantity: Int) {
        self.crvQuantity = NSNumber(value: crvQuantity)
    }

    fileprivate func update(crvFluidOunces: Float) {
        self.crvFluidOunces = NSNumber(value: crvFluidOunces)
    }

    fileprivate func update(notes: String) {
        self.notes = notes
    }

    fileprivate func update(imagePath: String) {
        self.imagePath = imagePath
    }

    func createImage(image: UIImage, thumbnailSize: CGSize) -> (error: Error?, imageData: NSData?) {
        
        // create Data from UIImage
        guard let imageData = UIImageJPEGRepresentation(image, 1) else {
            Logger.logDetails(msg: "jpg error")
            return (SRPError.jpegError, nil)
        }
        
        return (nil, imageData as NSData)
        
    }
    
    func saveImage(imageData: NSData, databaseInterface: DatabaseInterface) -> Error? {
        
        imagePath = "\(name).jpg"
            
        writeImageDataToJpeg(imageData: imageData as Data)
        
        databaseInterface.saveContext()
        
        return nil
    }

    func deleteImage(databaseInterface: DatabaseInterface) -> Error? {

        let fullImagePath = FileUtilities.applicationDocumentsDirectory().appendingPathComponent("\(imagePath!)")

        do {
            try FileManager.default.removeItem(at: fullImagePath)
            
            imagePath = nil
            databaseInterface.saveContext()
            
            return nil
        } catch let error as NSError {
            Logger.logDetails(msg: "Error deleting image file: \(error)")
            return error
        }
    }
}
