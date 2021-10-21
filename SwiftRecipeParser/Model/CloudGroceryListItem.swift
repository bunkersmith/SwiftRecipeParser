//
//  CloudGroceryListItem.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 10/20/21.
//  Copyright © 2021 CarlSmith. All rights reserved.
//

import Foundation
import CloudKit

public class CloudGroceryListItem {
    
    static let recordType = "CloudGroceryListItem"
    private let id: CKRecord.ID
    public let cost: Double
    public let crvFluidOunces: Double
    public let crvQuantity: Int64
    public let imagePath: String
    public let isCrv: Int64
    public let isFsa: Int64
    public let isTaxable: Int64
    public let name: String
    public let notes: String
    public let quantity: Double
    public let taxablePrice: Double
    public let unitOfMeasure: String

    public init?(record: CKRecord, database: CKDatabase) {
        guard
          let cost = record["cost"] as? Double,
          let crvFluidOunces = record["crvFluidOunces"] as? Double,
          let crvQuantity = record["crvQuantity"] as? Int64,
          let imagePath = record["imagePath"] as? String,
          let isCrv = record["isCrv"] as? Int64,
          let isFsa = record["isFsa"] as? Int64,
          let isTaxable = record["isTaxable"] as? Int64,
          let name = record["name"] as? String,
          let notes = record["notes"] as? String,
          let quantity = record["quantity"] as? Double,
          let taxablePrice = record["taxablePrice"] as? Double,
          let unitOfMeasure = record["unitOfMeasure"] as? String else {
              return nil
        }
        
        id = record.recordID
        self.cost = cost
        self.crvFluidOunces = crvFluidOunces
        self.crvQuantity = crvQuantity
        self.imagePath = imagePath
        self.isCrv = isCrv
        self.isFsa = isFsa
        self.isTaxable = isTaxable
        self.name = name
        self.notes = notes
        self.quantity = quantity
        self.taxablePrice = taxablePrice
        self.unitOfMeasure = unitOfMeasure
    }
}

extension CloudGroceryListItem: Hashable {
    public static func == (lhs: CloudGroceryListItem, rhs: CloudGroceryListItem) -> Bool {
    return lhs.id == rhs.id
  }
  
    public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension CloudGroceryListItem: CustomStringConvertible {
    public var description: String {
    return "name: \(name)\nquantity: \(quantity)\nunits: \(unitOfMeasure)\ncost: \(cost)\nisTaxable: \(isTaxable)\ntaxablePrice: \(taxablePrice)\nisCrv: \(isCrv)\ncrvQuantity: \(crvQuantity)\ncrvFluidOunces: \(crvFluidOunces)\nisFsa: \(isFsa)\nnotes: \(notes)\nisFsa: \(imagePath)"
  }
}
