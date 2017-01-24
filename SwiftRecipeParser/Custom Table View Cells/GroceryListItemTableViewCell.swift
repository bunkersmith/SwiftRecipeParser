//
//  GroceryListItemTableViewCell.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 6/5/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit

class GroceryListItemTableViewCell: UITableViewCell {

    @IBOutlet weak var groceryListItemName: UILabel!
    @IBOutlet weak var groceryListItemCost: UILabel!
    @IBOutlet weak var groceryListItemButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
