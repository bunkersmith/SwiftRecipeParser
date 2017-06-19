//
//  GroceryListItemTableViewCell.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 6/5/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit

class GroceryListItemTableViewCell: UITableViewCell {

    static let fullNameWidth:CGFloat = 200
    
    @IBOutlet weak var groceryListItemName: UILabel!
    @IBOutlet weak var groceryListItemCost: UILabel!
    @IBOutlet weak var groceryListItemBuyButton: UIButton!
    @IBOutlet weak var groceryListItemQuantityLabel: UILabel!
    @IBOutlet weak var groceryListItemTaxableLabel: UILabel!
    
    @IBOutlet weak var nameWidthConstraint: NSLayoutConstraint!
    
    func modifyQuantity(increase: Bool) {
        guard var quantity = returnItemQuantity() else {
            return
        }
        
        quantity = increase ? quantity + 1 : quantity - 1
        
        if quantity.truncatingRemainder(dividingBy: 1) != 0.0 {
            groceryListItemQuantityLabel.text = "(\(quantity)) "
        } else {
            groceryListItemQuantityLabel.text = "(\(Int(quantity))) "
        }
        
        let itemDictionary: [String: Any] = ["itemName": groceryListItemName.text ?? ""]
        
        if increase {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SwiftRecipeParser.QuantityIncreasedNotification"), object: self, userInfo: itemDictionary)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SwiftRecipeParser.QuantityDecreasedNotification"), object: self, userInfo: itemDictionary)
        }
    }
    
    func configure(item: GroceryListItem) {
        
        groceryListItemName.text = item.name
        groceryListItemCost.text = String(format: "%.2f", item.cost.floatValue)
        
        if item.isBought.boolValue {
            groceryListItemBuyButton.setTitle("Return", for: .normal)
            groceryListItemName.textColor = UIColor.red
        }
        else {
            groceryListItemBuyButton.setTitle("Buy", for: .normal)
            groceryListItemName.textColor = UIColor.black
        }
        
        if item.quantity == 1.0 {
            groceryListItemQuantityLabel.text = ""
            if item.isTaxable.boolValue {
                configureForTaxable()
            } else {
                groceryListItemTaxableLabel.text = ""
                nameWidthConstraint.constant = GroceryListItemTableViewCell.fullNameWidth
            }
        } else {
            if item.isTaxable.boolValue {
                configureForQuantityAndTaxable(quantity: item.quantity.floatValue)
            } else {
                groceryListItemTaxableLabel.text = ""
                configureForQuantity(quantity: item.quantity.floatValue)
            }
        }
    }

    func configureForQuantity(quantity: Float) {
        groceryListItemQuantityLabel.text = "(\(Int(quantity))) "
        
        let widthToSubtract = groceryListItemQuantityLabel.text!.widthOfString(usingFont: groceryListItemQuantityLabel.font)
        
        nameWidthConstraint.constant = GroceryListItemTableViewCell.fullNameWidth - widthToSubtract
    }
    
    func configureForTaxable() {
        groceryListItemTaxableLabel.text = "t-"
        
        let widthToSubtract = groceryListItemTaxableLabel.text!.widthOfString(usingFont: groceryListItemTaxableLabel.font)
        
        nameWidthConstraint.constant = GroceryListItemTableViewCell.fullNameWidth - widthToSubtract
    }
    
    func configureForQuantityAndTaxable(quantity: Float) {
        groceryListItemQuantityLabel.text = "(\(Int(quantity))) "
        groceryListItemTaxableLabel.text = "t-"
        
        var widthToSubtract = groceryListItemQuantityLabel.text!.widthOfString(usingFont: groceryListItemQuantityLabel.font)
        widthToSubtract += groceryListItemTaxableLabel.text!.widthOfString(usingFont: groceryListItemTaxableLabel.font)
        
        nameWidthConstraint.constant = GroceryListItemTableViewCell.fullNameWidth - widthToSubtract
    }
    
    func returnItemQuantity() -> Float? {
        guard var quantityString = groceryListItemQuantityLabel.text else {
            return nil
        }

        if quantityString == "" {
            return 1
        }
        
        quantityString = quantityString.removeCharacters(from: "()")
        
        let formatter = NumberFormatter()
        
        guard let quantityNumber = formatter.number(from: quantityString) else {
            return nil
        }
        
        return quantityNumber.floatValue
    }
    
    func returnItemName() -> String {
        return groceryListItemName.text ?? ""
    }
}
