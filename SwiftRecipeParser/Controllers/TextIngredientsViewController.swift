//
//  TextIngredientsViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 5/2/20.
//  Copyright © 2020 CarlSmith. All rights reserved.
//

import UIKit
import MessageUI

class TextIngredientsViewController: TextMessageViewController, TextMessageViewControllerDelegate {

    var textRecipeTitle:String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        delegate = self
    }
    
    func initRecipeTitle(recipeTitle: String) {
        textRecipeTitle = recipeTitle
    }

    func returnMessageBody() -> String {
        return textRecipeTitle + " Ingredients:\n" + Recipe.convertRecipeNameToFormattedIngredients(textRecipeTitle)
    }
    
}
