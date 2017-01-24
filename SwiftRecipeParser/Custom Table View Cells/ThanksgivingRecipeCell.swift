//
//  ThanksgivingRecipeCell.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 11/26/15.
//  Copyright © 2015 CarlSmith. All rights reserved.
//

import UIKit

class ThanksgivingRecipeCell: UITableViewCell {

    @IBOutlet weak var recipeTitle: UILabel!
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var instructionsTextView: UITextView!
    var ingredientsTableViewController: IngredientsTableViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
