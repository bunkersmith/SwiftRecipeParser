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
    
    func configure(item: GroceryListItem) {
        
        groceryListItemCost.text = String(format: "%.2f", item.cost.floatValue)

        let buttonTitle = item.isBought.boolValue ? "Return" : "Buy"
        groceryListItemBuyButton.setTitle(buttonTitle, for: .normal)
        
        let buttonColor = item.isBought.boolValue ? UIColor.red : UIColor.black
        groceryListItemName.textColor = buttonColor
        
        if item.isFsa.boolValue {
            groceryListItemName.text = item.isTaxable.boolValue ? "ft-" + item.name : "f-" + item.name
        } else {
            groceryListItemName.text = item.isTaxable.boolValue ? "t-" + item.name : item.name
        }

        if !item.notes.isEmpty {
            groceryListItemName.text = "*" + groceryListItemName.text!
        }
        
        if item.quantity == 1.0 {
            groceryListItemQuantityLabel.text = ""
        } else {
            configureForQuantity(quantity: item.quantity.floatValue, unitOfMeasure: item.unitOfMeasure)
        }
    }

    func configureForQuantity(quantity: Float, unitOfMeasure: String) {
        if quantity.remainder(dividingBy: 1.0) == 0.0 {
            groceryListItemQuantityLabel.text = "(\(Int(quantity))) "
        } else {
            let poundsString = unitOfMeasure == "lb" ? "#" : ""
            groceryListItemQuantityLabel.text = "(\(String(format:"%.1f", quantity))" + poundsString +    ") "
        }
    }
}
