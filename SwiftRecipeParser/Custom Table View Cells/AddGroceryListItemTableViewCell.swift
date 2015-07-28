//
//  AddGroceryListItemTableViewCell.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/7/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit

class AddGroceryListItemTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
