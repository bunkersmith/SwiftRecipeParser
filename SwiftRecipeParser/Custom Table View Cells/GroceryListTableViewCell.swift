//
//  GroceryListTableViewCell.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 4/9/21.
//  Copyright © 2021 CarlSmith. All rights reserved.
//

import UIKit

class GroceryListTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var projectedCostLabel: UILabel!
    @IBOutlet weak var isSelectedCheckBox: CheckBox!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
