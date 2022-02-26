//
//  TextGroceryListViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 9/6/21.
//  Copyright © 2021 CarlSmith. All rights reserved.
//

import UIKit

class TextGroceryListViewController: TextMessageViewController, TextMessageViewControllerDelegate {
    
    var textGroceryListName:String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        delegate = self
    }
    
    func initGroceryListName(groceryListName: String) {
        textGroceryListName = groceryListName
    }

    func returnMessageBody() -> String {
        return textGroceryListName + "\n" + GroceryList.groceryListNameToTextString(groceryListName: textGroceryListName)
    }
    
}
