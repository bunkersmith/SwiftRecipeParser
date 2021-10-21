/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import CloudKit

public class CKModel {
  // MARK: - iCloud Info
  let container: CKContainer
  let publicDB: CKDatabase
  let privateDB: CKDatabase
  
  // MARK - Errors
    enum CKModelError: Error {
        case nilSavedRecords
        case nilDeletedRecords
        case nilQueryResults
    }
    
  // MARK: - Properties
  private(set) var groceryListItems: [CloudGroceryListItem] = []
  public static var currentModel = CKModel()
  
  init() {
    container = CKContainer(identifier: "iCloud.com.carlsoft.SwiftRecipeParser.iCloudContainer")
    publicDB = container.publicCloudDatabase
    privateDB = container.privateCloudDatabase
  }
  
  // MARK: - Functions
  func findBy(name: String, completion: @escaping (CKRecord?) -> Void) {
    let predicate = NSPredicate(format: "name == %@", name)
    let query = CKQuery(recordType: "CloudGroceryListItem", predicate: predicate)

    publicDB.perform(query, inZoneWith: CKRecordZone.default().zoneID) { (records, error) in
        if let error = error {
            Logger.logDetails(msg: "Query error: \(error)")
            completion(nil)
            return
        }
        
        guard let records = records else {
            Logger.logDetails(msg: "Nil query return")
            completion(nil)
            return
        }
        
        completion(records.first)
    }
  }
  
  func populateCloudGroceryListItems(_ completion: @escaping ([CloudGroceryListItem], Error?) -> Void) {
        let startTime = MillisecondTimer.currentTickCount()
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "CloudGroceryListItem", predicate: predicate)

        queryCloudGroceryListItems(forQuery: query) { [unowned self] (error) in
            
            Logger.logDetails(msg: "populateCloudGroceryListItems count: \(self.groceryListItems.count)")
            Logger.logDetails(msg: "populateCloudGroceryListItems time: \(MillisecondTimer.secondsSince(startTime: startTime))")
            
            completion(self.groceryListItems, nil)
        }
    }
    
    func populateCloudGroceryListItemsAsText(_ completion: @escaping (String?, Error?) -> Void) {
        let startTime = MillisecondTimer.currentTickCount()
        
        CKModel.currentModel.populateCloudGroceryListItems { (lastCloudGroceryListItems, error) in
            var returnString:String = ""
            
            if (error == nil && lastCloudGroceryListItems.count > 0) {
                for song in lastCloudGroceryListItems {
                    returnString += song.description + "\n"
                    returnString += "\n"
                }
                
                Logger.logDetails(msg: "populateCloudGroceryListItemsAsText time: \(MillisecondTimer.secondsSince(startTime: startTime))")

                completion(returnString, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func populateCloudGroceryListItemsAsData(_ completion: @escaping (Data?, Error?) -> Void) {
        let startTime = MillisecondTimer.currentTickCount()
        
        populateCloudGroceryListItemsAsText { (songString, error) in
            if error == nil {
                let returnData = songString?.data(using: .utf8)
                
                Logger.logDetails(msg: "populateCloudGroceryListItemsAsData time: \(MillisecondTimer.secondsSince(startTime: startTime))")
                
                completion(returnData, nil)
            } else {
                completion(nil, error)
            }
        }
    }
        
    private func queryCloudGroceryListItems(forQuery query: CKQuery, _ completion: @escaping (Error?) -> Void) {

        queryRecords(query: query) { [unowned self] results, error in
            
            if let error = error {
                Logger.logDetails(msg: "cloudGroceryListItems query error: \(error)")
                completion(error)
                return
            }
                
            guard let results = results else {
                Logger.logDetails(msg: "cloudGroceryListItems results error")
                completion(CKModelError.nilQueryResults)
                return
            }
                
            self.groceryListItems = results.compactMap {
                CloudGroceryListItem(record: $0, database: self.publicDB)
            }

            completion(nil)
        }
    }
 
    func fetchAllIds(_ completion: @escaping ([CKRecord.ID]) -> Void) {
        //let startTime = MillisecondTimer.currentTickCount()
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "CloudGroceryListItem", predicate: predicate)
        
        var recordIDs = [CKRecord.ID]()
        
        let queryOp = CKQueryOperation(query: query)
        queryOp.desiredKeys = nil

        queryRecords(query: query) { (records, error) in
            guard error == nil else {
                Logger.logDetails(msg: "Error querying records: \(error!)")
                completion([])
                return
            }
            
            guard records != nil else {
                Logger.logDetails(msg: "Nil records pointer")
                completion([])
                return
            }
            
            Logger.logDetails(msg: "Record count: \(records!.count)")
            
            for record in records! {
                recordIDs.append(record.recordID)
            }
            
            //Logger.logDetails(msg: "Elapsed time: \(MillisecondTimer.secondsSince(startTime))")
            completion(recordIDs)
        }
    }

    func deleteAll(_ completion: @escaping(Error?, Int) -> Void)
    {
        // fetch records from iCloud, get their recordID and then delete them

        let startTime = MillisecondTimer.currentTickCount()
        
        var allDeletedIDs = [CKRecord.ID]()
        
        fetchAllIds { [unowned self] (recordIDsArray) in
            Logger.logDetails(msg: "Fetch time: \(MillisecondTimer.secondsSince(startTime: startTime))")
            
            guard recordIDsArray.count > 0 else {
                completion(nil, 0)
                return
            }
            
            self.deleteGroceryListItemRecords(recordIDs: recordIDsArray) { (deletedRecordIDs, error) in
                guard error == nil else {
                    completion(error, 0)
                    return
                }
                
                allDeletedIDs.append(contentsOf: deletedRecordIDs)
                
                if (allDeletedIDs.count == recordIDsArray.count) {
                    Logger.logDetails(msg: "deleteAll deleted \(allDeletedIDs.count) songs")
                    completion(nil, allDeletedIDs.count)
                    
                    Logger.logDetails(msg: "Elapsed time: \(MillisecondTimer.secondsSince(startTime: startTime))")
                }
            }
        }
    }

    func deleteGroceryListItemRecords(recordIDs: [CKRecord.ID], completion: @escaping([CKRecord.ID], Error?) -> Void) {
        let deleteOp = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDs)
        deleteOp.database = self.publicDB
        
        deleteOp.modifyRecordsCompletionBlock = { (savedRecords, deletedRecordIDs, error) in
            guard error == nil else {
                if (error!._code == CKError.Code.limitExceeded.rawValue) {
                    var splitIndex = recordIDs.count/2
                    
                    Logger.logDetails(msg: "\(splitIndex)")
                    let firstHalf = Array(recordIDs.prefix(splitIndex))
                    Logger.logDetails(msg: "Prefix count: \(firstHalf.count)")

                    // Be sure to catch all the records if there are an odd number, since /2 rounds down
                    if (recordIDs.count % 2 == 1) {
                        splitIndex += 1
                    }
                    
                    let secondHalf = Array(recordIDs.suffix(splitIndex))
                    Logger.logDetails(msg: "Suffix count: \(secondHalf.count)")
                    
                    self.deleteGroceryListItemRecords(recordIDs: firstHalf, completion: completion)
                    self.deleteGroceryListItemRecords(recordIDs: secondHalf, completion: completion)
                    completion([], nil)
                    return
                }
                Logger.logDetails(msg: "deleteSongs modify error: \(String(describing: error))")
                return
            }
            
            guard let deletedRecordIDs = deletedRecordIDs else {
                Logger.logDetails(msg: "Nil deletedRecordIDs")
                completion([], CKModelError.nilDeletedRecords)
                return
            }
            
            Logger.logDetails(msg: "Recursive routine saved \(savedRecords?.count ?? 0) songs, deleted \(deletedRecordIDs.count) songs")
            completion(deletedRecordIDs, nil)
        }
        
        deleteOp.start()
    }
    
// FIGURE OUT WHICH FIELDS ARE NEEDED TO UNIQUELY IDENTIFY A GroceryListItem (just name, right?)
    
    func writeOrUpdateGroceryListItem(groceryListItem: GroceryListItem,
                           completion: @escaping(Error?) -> Void) {
//        findBy(persistentKey: song.summary.persistentKey) { [unowned self] (record) in
//
//            if record == nil {
//                self.writeSong(song: song, lastPlayedTime: lastPlayedTime) { (record, error) in
//                    guard error == nil else {
//                        Logger.logDetails(msg: "Error writing new played song record for \(MediaObjectUtilities.titleAndArtistStringForSong(song)): \(String(describing: error))")
//                        return
//                    }
//                    Logger.logDetails(msg: "Wrote new played song record for \(MediaObjectUtilities.titleAndArtistStringForSong(song))")
//                    completion(error)
//                }
//            } else {
//                record!.setValue(lastPlayedTime, forKey: "lastPlayedTime")
//                let lastPlayedTimeDisplayString = DateTimeUtilities.timeIntervalToString(lastPlayedTime)
//                record!.setValue(lastPlayedTimeDisplayString, forKey: "lastPlayedTimeDisplayString")
//                let records = [record!]
//                self.writeSongRecords(songRecords: records) { (records, error) in
//                    guard error == nil else {
//                        Logger.logDetails(msg: "Error updating existing played song record for \(MediaObjectUtilities.titleAndArtistStringForSong(song)): \(String(describing: error))")
//                        return
//                    }
//                    Logger.logDetails(msg: "Updated existing played song record for \(MediaObjectUtilities.titleAndArtistStringForSong(song))")
//                    completion(error)
//                }
//            }
//        }
    }
    
    func writeGroceryListItem(groceryListItem: GroceryListItem,
                   completion: @escaping(CKRecord?, Error?) -> Void) {
        let record = CKRecord(recordType: CloudGroceryListItem.recordType)
        record.setValue(groceryListItem.cost, forKey: "cost")
        record.setValue(groceryListItem.crvFluidOunces, forKey: "crvFluidOunces")
        record.setValue(groceryListItem.crvQuantity, forKey: "crvQuantity")
        record.setValue(groceryListItem.imagePath, forKey: "imagePath")
        record.setValue(groceryListItem.isCrv, forKey: "isCrv")
        record.setValue(groceryListItem.isFsa, forKey: "isFsa")
        record.setValue(groceryListItem.isTaxable, forKey: "isTaxable")
        record.setValue(groceryListItem.name, forKey: "name")
        record.setValue(groceryListItem.notes, forKey: "notes")
        record.setValue(groceryListItem.quantity, forKey: "quantity")
        record.setValue(groceryListItem.taxablePrice, forKey: "taxablePrice")
        record.setValue(groceryListItem.unitOfMeasure, forKey: "taxablePrice")

        publicDB.save(record) { (savedRecord, error) in
            guard error == nil else {
                Logger.logDetails(msg: "Error saving cloudGroceryListItem \(groceryListItem): \(error!)")
                completion(nil, error)
                return
            }
            
            guard savedRecord != nil else {
                Logger.logDetails(msg: "Nil savedRecord")
                completion(savedRecord, nil)
                return
            }
            completion(savedRecord, error)
        }
    }

    func writeGroceryListItemRecords(groceryListItemRecords: [CKRecord], completion: @escaping([CKRecord], Error?) -> Void) {
        let writeOp = CKModifyRecordsOperation(recordsToSave: groceryListItemRecords, recordIDsToDelete: [])
        writeOp.database = publicDB

        writeOp.modifyRecordsCompletionBlock = { [unowned self] (savedRecords, deletedRecordIDs, error) in
            
            guard error == nil else {
                if (error!._code == CKError.Code.limitExceeded.rawValue) {
                    var splitIndex = groceryListItemRecords.count/2
                    
                    //Logger.logDetails(msg: "\(splitIndex)")
                    let firstHalf = Array(groceryListItemRecords.prefix(splitIndex))
                    //Logger.logDetails(msg: "Prefix count: \(firstHalf.count)")

                    // Be sure to catch all the records if there are an odd number, since /2 rounds down
                    if (groceryListItemRecords.count % 2 == 1) {
                        splitIndex += 1
                    }
                    
                    let secondHalf = Array(groceryListItemRecords.suffix(splitIndex))
                    //Logger.logDetails(msg: "Suffix count: \(secondHalf.count)")
                    
                    self.writeGroceryListItemRecords(groceryListItemRecords: firstHalf, completion: completion)
                    self.writeGroceryListItemRecords(groceryListItemRecords: secondHalf, completion: completion)
                    completion([], nil)
                    return
                }
                
                Logger.logDetails(msg: "writeSongs modify error: \(String(describing: error))")
                completion([], error)
                return
            }
            
            guard let savedRecords = savedRecords else {
                Logger.logDetails(msg: "Nil savedRecords")
                completion([], CKModelError.nilSavedRecords)
                return
            }
            
            Logger.logDetails(msg: "Recursive routine saved \(savedRecords.count) songs, deleted \(deletedRecordIDs?.count ?? 0) songs")
            completion(savedRecords, nil)
        }
        
        writeOp.start()
    }
    
    func queryRecords(query: CKQuery, completion: @escaping ([CKRecord]?, Error?) -> Void) {
        let operation = CKQueryOperation(query: query)
        var results = [CKRecord]()
        
        operation.recordFetchedBlock = { record in
            results.append(record)
        }
        
        operation.queryCompletionBlock = { [unowned self] cursor, error in
            guard error == nil else {
                completion([], error)
                return
            }
            if cursor == nil {
                completion(results, nil)
            } else {
                self.queryRecords(cursor: cursor!, continueWithResults: results, completion: completion)
            }
        }
        
        publicDB.add(operation)
    }

    private func queryRecords(cursor: CKQueryOperation.Cursor, continueWithResults:[CKRecord], completion: @escaping ([CKRecord]?, Error?) -> Void) {
        var results = continueWithResults
        let operation = CKQueryOperation(cursor: cursor)
        
        operation.recordFetchedBlock = { record in
            results.append(record)
        }
        
        operation.queryCompletionBlock = { [unowned self] cursor, error in
            if cursor == nil {
                completion(results, nil)
            } else {
                self.queryRecords(cursor: cursor!, continueWithResults: results, completion: completion)
            }
        }

        publicDB.add(operation)
    }
}
