//
//  PersianRecipesViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 11/26/15.
//  Copyright © 2015 CarlSmith. All rights reserved.
//

import UIKit

class PersianRecipesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var recipe:Recipe?

    let recipeNamesArray:[String] = ["Persian Chicken With Rice (Zereshk Polo ba Morgh)",
                                     "Persian Eggplant (Naz Khatoon)",
                                     "Persian Eggplant With Tomatoes and Potatoes (Yateamche Bademjon)",
                                     "Persian Saffron Rice With Tahdeeg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initIngredientsTableViewController(cell: PersianRecipeCell) {
        cell.ingredientsTableViewController = IngredientsTableViewController()
    
        cell.ingredientsTableViewController.embeddedTableView = cell.ingredientsTableView
    
        cell.ingredientsTableView.delegate = self
        cell.ingredientsTableView.dataSource = cell.ingredientsTableViewController

/*
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: cell.ingredientsTableViewController, action: Selector("handleLongPress:"))
        longPressGestureRecognizer.minimumPressDuration = 1.0 //seconds
        longPressGestureRecognizer.delegate = cell.ingredientsTableViewController
        cell.ingredientsTableView.addGestureRecognizer(longPressGestureRecognizer)
*/
    }
    
    func populateRecipeDisplayFields(cell: PersianRecipeCell) {
        cell.instructionsTextView.textAlignment = .justified
        
        recipe = Recipe.findRecipeByName(cell.recipeTitle.text!)
        
        cell.instructionsTextView.text = recipe!.instructions
        
        cell.ingredientsTableViewController.recipeIngredients = recipe!.containsIngredients
        
        cell.ingredientsTableView.reloadData()
        
        let scrollToPath = NSIndexPath(row: 0, section: 0)
        cell.ingredientsTableView.scrollToRow(at: scrollToPath as IndexPath, at:.top, animated:false)
        
        cell.instructionsTextView.scrollRangeToVisible(NSMakeRange(0, 1))
    }

    // MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        AlertUtilities.showAddIngredientAlert(object: recipe!.containsIngredients[indexPath.row] as AnyObject, viewController: self)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeNamesArray.count
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:PersianRecipeCell = tableView.dequeueReusableCell(withIdentifier: "PersianRecipeCell") as! PersianRecipeCell
        
        cell.recipeTitle.text = recipeNamesArray[indexPath.row]
        
        initIngredientsTableViewController(cell: cell)
        populateRecipeDisplayFields(cell: cell)
        
        return cell
    }
}
