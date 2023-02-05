//
//  PersianRecipeCell.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 11/26/15.
//  Copyright © 2015 CarlSmith. All rights reserved.
//

import UIKit

class PersianRecipeCell: UITableViewCell {

    @IBOutlet weak var recipeTitle: UILabel!
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var instructionsTextView: UITextView!
    var ingredientsTableViewController: IngredientsTableViewController!
    
}
