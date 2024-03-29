//
//  GroceryList.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 6/1/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import Foundation
import CoreData

class GroceryList: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var isCurrent: NSNumber
    @NSManaged var isSelected: NSNumber
    @NSManaged var totalCost: NSNumber
    @NSManaged var projectedCost: NSNumber
    @NSManaged var hasItems: NSOrderedSet
    @NSManaged var stopNumber: NSNumber
    @NSManaged var inShoppingTrip: ShoppingTrip
    
    func addHasItemsObject(value:GroceryListItem)
    {
        value.listPosition = NSNumber(value: self.hasItems.count)

        self.willChangeValue(forKey: "hasItems")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.hasItems)
        tempSet.add(value)
        self.hasItems = tempSet
        self.didChangeValue(forKey: "hasItems")
    }
    
    func addHasItemsObjects(values:[GroceryListItem])
    {
        self.willChangeValue(forKey: "hasItems")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.hasItems)
        let startingPosition = tempSet.count
        tempSet.addObjects(from: values)
        adjustListPositionsForAddition(startingPosition: startingPosition, tempSet: tempSet)
        self.hasItems = tempSet
        self.didChangeValue(forKey: "hasItems")
    }
    
    func adjustListPositionsForAddition(startingPosition: Int, tempSet: NSMutableOrderedSet) {
        for index in startingPosition..<tempSet.count {
            if let groceryListItem = tempSet[index] as? GroceryListItem {
                groceryListItem.listPosition = NSNumber(value: index)
            }
        }
    }
    
    func removeHasItemsObject(value:GroceryListItem)
    {
        self.willChangeValue(forKey: "hasItems")
        let tempSet:NSMutableOrderedSet = NSMutableOrderedSet(orderedSet:self.hasItems)
        let deletedPosition = tempSet.index(of: value)
        tempSet.remove(value)
        adjustListPositionsForDeletion(deletedPosition: deletedPosition, tempSet: tempSet)
        self.hasItems = tempSet
        self.didChangeValue(forKey: "hasItems")
    }
    
    func adjustListPositionsForDeletion(deletedPosition: Int, tempSet: NSMutableOrderedSet) {
        for index in deletedPosition..<tempSet.count {
            if let groceryListItem = tempSet[index] as? GroceryListItem {
                groceryListItem.listPosition = NSNumber(value: groceryListItem.listPosition.int16Value - 1)
            }
        }
    }
    
    func removeAllHasItemsObjects()
    {
        self.willChangeValue(forKey: "hasItems")
        self.hasItems = NSMutableOrderedSet()
        self.didChangeValue(forKey: "hasItems")
        DatabaseInterface(concurrencyType: .mainQueueConcurrencyType).saveContext()
    }
    
    func clearAllItems() {
        clearBoughtFlags(withDelete: false)
        removeAllHasItemsObjects()
        DatabaseInterface(concurrencyType: .mainQueueConcurrencyType).saveContext()
    }
    
    func clearBoughtItems() {
        clearBoughtFlags(withDelete: true)
        DatabaseInterface(concurrencyType: .mainQueueConcurrencyType).saveContext()
    }

    func clearBoughtFlags(withDelete: Bool) {
        hasItems.enumerateObjects ({ (groceryListObject, idx, stop) -> Void in
            let groceryListItem = groceryListObject as! GroceryListItem
            if groceryListItem.isBought.boolValue {
                groceryListItem.isBought = NSNumber(value: false)
                if withDelete {
                    removeHasItemsObject(value: groceryListItem)
                }
            }
        })
    }
    
    class func create(name: String) {
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        
        let groceryList:GroceryList = databaseInterface.newManagedObjectOfType(managedObjectClassName: "GroceryList") as! GroceryList
        groceryList.name = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        groceryList.totalCost = NSNumber(value:0.0)
        
        databaseInterface.saveContext()
    }
    
    class func delete(groceryList: GroceryList) {
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        
        databaseInterface.deleteObject(coreDataObject: groceryList)
        databaseInterface.saveContext()
    }
    
    class func setCurrentGroceryList(groceryListName:String)
    {
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        let groceryLists:Array<GroceryList> = databaseInterface.entitiesOfType(entityTypeName:"GroceryList", predicate:nil) as! Array<GroceryList>
        for groceryList:GroceryList in groceryLists {
            if groceryList.name == groceryListName {
                groceryList.isCurrent = NSNumber(value: true)
            }
            else {
                groceryList.isCurrent = NSNumber(value: false)
            }
        }
        databaseInterface.saveContext()
    }
    
    class func returnAll() -> Array<GroceryList> {
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
            
        guard let returnValue = databaseInterface.entitiesOfType(entityTypeName: "GroceryList",
                                                                 fetchRequestChangeBlock: { inputFetchRequest in
            let sortDescriptor:NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            inputFetchRequest.sortDescriptors = [sortDescriptor]
            return inputFetchRequest
        }) as? Array<GroceryList> else {
            return []
        }
        return returnValue
    }

    class func returnAllButCurrent() -> Array<GroceryList> {
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
            
        guard let returnValue = databaseInterface.entitiesOfType(entityTypeName: "GroceryList",
                                                                 fetchRequestChangeBlock: { inputFetchRequest in
            let sortDescriptor:NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            inputFetchRequest.sortDescriptors = [sortDescriptor]
            inputFetchRequest.predicate = NSPredicate(format:"isCurrent == %@", NSNumber(value: false))
            return inputFetchRequest
        }) as? Array<GroceryList> else {
            return []
        }
        return returnValue
    }
    
    class func returnAllNotInShoppingTrip() -> Array<GroceryList> {
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
            
        guard let returnValue = databaseInterface.entitiesOfType(entityTypeName: "GroceryList",
                                                                 fetchRequestChangeBlock: { inputFetchRequest in
            let sortDescriptor:NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            inputFetchRequest.sortDescriptors = [sortDescriptor]
            inputFetchRequest.predicate = NSPredicate(format: "inShoppingTrip == nil")

            return inputFetchRequest
        }) as? Array<GroceryList> else {
            return []
        }
        return returnValue
    }
    
    class func returnCurrentGroceryList() -> GroceryList?
    {
        var returnValue:GroceryList? = nil
    
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        let groceryLists:Array<GroceryList> = databaseInterface.entitiesOfType(entityTypeName:"GroceryList", predicate:NSPredicate(format:"isCurrent == %@", NSNumber(value: true))) as! Array<GroceryList>
    
        if (groceryLists.count == 1) {
            returnValue = groceryLists.first    
        }
    
        return returnValue
    }

    class func returnGroceryListWithName(name: String) -> GroceryList? {
        var returnValue:GroceryList? = nil
        
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        let groceryLists:Array<GroceryList> = databaseInterface.entitiesOfType(entityTypeName:"GroceryList", predicate:NSPredicate(format:"name == %@", name)) as! Array<GroceryList>
        
        if (groceryLists.count == 1) {
            returnValue = groceryLists.first
        }
        
        return returnValue
    }
    
    func projectedCostString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.roundingMode = NumberFormatter.RoundingMode.halfUp
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        return "$\(formatter.string(from: projectedCost)!)"
    }

    func totalCostString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.roundingMode = NumberFormatter.RoundingMode.halfUp
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        return "$\(formatter.string(from: totalCost)!)"
    }
    
    func updateProjectedCost() {
        projectedCost = NSNumber(value: 0.0)
        
        for item in hasItems {
            if let groceryListItem = item as? GroceryListItem {
                //Logger.logDetails(msg:"groceryListItem.name = \(groceryListItem.name)")
                projectedCost = NSNumber(value:projectedCost.floatValue + groceryListItem.totalCost.floatValue)
                //Logger.logDetails(msg:"projectedCost = \(projectedCost)")
            }
        }
        
        DatabaseInterface(concurrencyType: .mainQueueConcurrencyType).saveContext()
    }
    
    func updateAndReturnTotalCost() -> Float {
        totalCost = NSNumber(value: 0.0)
        
        for item in hasItems {
            if let groceryListItem = item as? GroceryListItem {
                if groceryListItem.isBought.boolValue {
                    //Logger.logDetails(msg:"groceryListItem.name = \(groceryListItem.name)")
                    totalCost = NSNumber(value:totalCost.floatValue + groceryListItem.totalCost.floatValue)
                    //Logger.logDetails(msg:"totalCost = \(totalCost)")
                }
            }
        }
        
        DatabaseInterface(concurrencyType: .mainQueueConcurrencyType).saveContext()

        return totalCost.floatValue
    }
    
    class func findGroceryListWithName(name: String) -> GroceryList? {
        
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        guard let groceryLists = databaseInterface.entitiesOfType(entityTypeName: "GroceryList", predicate: NSPredicate(format: "name MATCHES %@", name)) as? Array<GroceryList> else {
            return nil
        }
        
        guard groceryLists.count == 1 else {
            return nil
        }
        
        guard let groceryList = groceryLists.first else {
            return nil
        }
        
        return groceryList
    }
    
    func findGroceryListItemWithName(name: String) -> GroceryListItem? {
        
        var finalName = name
        
        let tRange = name.range(of: "t-")
        if tRange != nil {
//            finalName = name.substring(from:tRange!.upperBound)
            finalName = String(name[tRange!.upperBound...])
        } else {
            let parenRange = name.range(of: ") ")
            if parenRange != nil {
//                finalName = name.substring(from:parenRange!.upperBound)
                finalName = String(name[parenRange!.upperBound...])
            }
        }
        
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        guard let groceryListItems = databaseInterface.entitiesOfType(entityTypeName: "GroceryListItem", predicate: NSPredicate(format: "name MATCHES %@", finalName)) as? Array<GroceryListItem> else {
            return nil
        }
        
        guard groceryListItems.count == 1 else {
            return nil
        }
        
        guard let groceryListItem = groceryListItems.first else {
            return nil
        }
        
        guard groceryListItem.inGroceryList == self else {
            return nil
        }
        
        return groceryListItem
    }
    
    func buyItem(item: GroceryListItem,
                 quantity: Float,
                 units: String,
                 cost: Float,
                 taxableStatus: Bool,
                 writeToIcloudNeeded: Bool) {
        item.isBought = NSNumber(value: true)
        item.isTaxable = NSNumber(value: taxableStatus)
        item.quantity = NSNumber(value: quantity)
        item.unitOfMeasure = units
        item.cost = NSNumber(value:cost)
        item.calculateTotalCost()
        DatabaseInterface(concurrencyType: .mainQueueConcurrencyType).saveContext()
        
        if writeToIcloudNeeded {
            item.writeToIcloud()
        }
    }
    
    func addItem(item: GroceryListItem,
                 itemQuantity: Float,
                 itemUnits: String,
                 itemPrice: Float,
                 itemNotes: String?) {
        item.quantity = NSNumber(value: itemQuantity)
        item.unitOfMeasure = itemUnits
        item.cost = NSNumber(value: itemPrice)
        if itemNotes != nil {
            item.notes = itemNotes!
        }
        item.calculateTotalCost()
        item.isBought = NSNumber(value: false)
        addHasItemsObject(value: item)
        
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        databaseInterface.saveContext()
        
        updateProjectedCost()

        item.writeToIcloud()
    }
    
    class func addItemsToCurrent(items: [GroceryListItem]) {
        
        guard let groceryList = returnCurrentGroceryList() else {
            return
        }
        
        for item in items {
            item.isBought = NSNumber(value: false)
        }
        
        groceryList.addHasItemsObjects(values: items)
        
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        databaseInterface.saveContext()
    }
    
    class func addItemToCurrent(itemName: String, quantity: Float, unitOfMeasure: String) {
        
        guard let groceryList = returnCurrentGroceryList() else {
            return
        }
        
        guard let groceryListItem = GroceryListItem.createOrReturn(name: itemName, cost: 0.0, quantity: quantity, unitOfMeasure: unitOfMeasure, databaseInterface: nil) else {
            return
        }
        
        groceryListItem	.isBought = NSNumber(value: false)

        groceryList.addHasItemsObject(value: groceryListItem)
        
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        databaseInterface.saveContext()
    }
    
    class func groceryListNameToTextString(groceryListName: String) -> String {
        
        var returnValue = ""
        
        guard let groceryList = findGroceryListWithName(name: groceryListName) else {
            return returnValue
        }
        
        groceryList.hasItems.enumerateObjects({ (groceryListObject, idx, stop) -> Void in
            let groceryListItem = groceryListObject as! GroceryListItem
            if !groceryListItem.isBought.boolValue {
                returnValue += groceryListItem.convertToShortOneLineString()
            }
        })
        
        returnValue = String(returnValue.dropLast())
        
        return returnValue
    }
    
    func unboughtItems(databaseInterface: DatabaseInterface) -> [GroceryListItem] {
        
        guard let unboughtItems = databaseInterface.entitiesOfType(entityTypeName: "GroceryListItem", predicate: NSPredicate(format: "inGroceryList.name MATCHES %@ AND isBought == NO", name)) as? [GroceryListItem] else {
            return []
        }
        
        return unboughtItems
    }
    
    func stringForPrinting() -> String {
        var returnValue = ""
        var totalTax: Float = 0

        hasItems.enumerateObjects({ (groceryListObject, idx, stop) -> Void in
            let groceryListItem = groceryListObject as! GroceryListItem
            returnValue += groceryListItem.stringForPrinting()
            
            if groceryListItem.isTaxable.boolValue {
                totalTax += groceryListItem.calculateTax()
            }
        })
        
        if totalTax > 0 {
            returnValue += String(format: "Tax: $%.2f\n", totalTax)
        }
        
        returnValue += "Total: " + totalCostString() + "\n"
        
        return returnValue
    }
}
