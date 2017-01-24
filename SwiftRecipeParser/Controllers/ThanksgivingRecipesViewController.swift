//
//  ThanksgivingRecipesViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 11/26/15.
//  Copyright © 2015 CarlSmith. All rights reserved.
//

import UIKit

class ThanksgivingRecipesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {


    let recipeNamesArray:[String] = ["Brined Roast Turkey",
                                     "Beth's Stuffing",
                                     "Creamy Garlic Mashed Potatoes",
                                     "French's Green Bean Casserole",
                                     "Green Beans Almondine",
                                     "'Ol No. 7 Yams"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initIngredientsTableViewController(cell: ThanksgivingRecipeCell) {
        cell.ingredientsTableViewController = IngredientsTableViewController()
    
        cell.ingredientsTableViewController.embeddedTableView = cell.ingredientsTableView
    
        cell.ingredientsTableView.delegate = cell.ingredientsTableViewController
        cell.ingredientsTableView.dataSource = cell.ingredientsTableViewController

/*
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: cell.ingredientsTableViewController, action: Selector("handleLongPress:"))
        longPressGestureRecognizer.minimumPressDuration = 1.0 //seconds
        longPressGestureRecognizer.delegate = cell.ingredientsTableViewController
        cell.ingredientsTableView.addGestureRecognizer(longPressGestureRecognizer)
*/
    }
    
    func populateRecipeDisplayFields(cell: ThanksgivingRecipeCell) {
        cell.instructionsTextView.textAlignment = .justified
        
        let recipe = RecipeUtilities.convertRecipeNameToObject(fileName: cell.recipeTitle.text!)
        
        cell.instructionsTextView.text = recipe!.instructions
        
        cell.ingredientsTableViewController.recipeIngredients = recipe!.containsIngredients
        
        cell.ingredientsTableView.reloadData()
        
        let scrollToPath = NSIndexPath(row: 0, section: 0)
        cell.ingredientsTableView.scrollToRow(at: scrollToPath as IndexPath, at:.top, animated:false)
        
        cell.instructionsTextView.scrollRangeToVisible(NSMakeRange(0, 1))
    }

    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeNamesArray.count
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ThanksgivingRecipeCell = tableView.dequeueReusableCell(withIdentifier: "ThanksgivingRecipeCell") as! ThanksgivingRecipeCell
        
        cell.recipeTitle.text = recipeNamesArray[indexPath.row]
        
        initIngredientsTableViewController(cell: cell)
        populateRecipeDisplayFields(cell: cell)
        
        return cell
    }
}
