//
//  RecipeDetailViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 8/15/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import UIKit

class RecipeDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var recipe:Recipe?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var recipeTitle: UILabel!
    
    private var expandedCells:Array<IndexPath> = Array()
    @IBOutlet weak var ingredientsTable: UITableView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var instructionsTextView: UITextView!
    @IBOutlet weak var instructionsVerticalSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var showInstructionsButton: UIButton!
    @IBOutlet weak var showIngredientsButton: UIButton!
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        guard let recipe = recipe else {
            return
        }
        
        coder.encode(recipe.title.name, forKey: "currentRecipeName")
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        guard let recipeName = coder.decodeObject(forKey: "currentRecipeName") as? String else {
            return
        }
        
        recipe = Recipe.fetchRecipeWithName(recipeName: recipeName)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ingredientsTable.tableFooterView = UIView(frame: .zero)
        
        self.ingredientsTable.estimatedRowHeight = 50.0
        self.ingredientsTable.rowHeight = UITableViewAutomaticDimension
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        let deviceString:String =  UIDevice.current.model
        if deviceString.range(of: "iPad") != nil {
            instructionsVerticalSpaceConstraint.constant = 15.0
        }
        
        if recipe != nil {
            self.recipeTitle.text = recipe!.title.name
            instructionsTextView.text = recipe!.instructions
            instructionsTextView.contentOffset = CGPoint(x: 0.0, y: 0.0)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.showIngredientsButton.frame.origin.y + 40)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    @IBAction func addAllPressed(_ sender: Any) {
        let currentGroceryList = GroceryList.returnCurrentGroceryList()
        
        if currentGroceryList == nil {
            AlertUtilities.showOkButtonAlert(self, title: "Error Alert", message: "No current grocery list", buttonHandler: nil)
        }
        else {
            let addString = "Add all ingredients to the \(currentGroceryList!.name) grocery list?"
            AlertUtilities.showYesNoAlert(viewController: self, title: "Add Item", message: addString, yesButtonHandler: { action in
                
                Logger.logDetails(msg: "Make Core Data call")
                
                guard let recipe = self.recipe else {
                    return
                }
                
                var groceryListItems = [GroceryListItem]()
                
                for ingredientAny in recipe.containsIngredients {
                    let ingredient = ingredientAny as! Ingredient

                    groceryListItems.append(GroceryListItem.createOrReturn(name: ingredient.ingredientItem.name,
                                                                           cost: 0.0,
                                                                           quantity: ingredient.quantity.floatValue,
                                                                           unitOfMeasure: ingredient.unitOfMeasure,
                                                                           databaseInterface: nil)!)
                }
                
                GroceryList.addItemsToCurrent(items: groceryListItems)
                
            }, noButtonHandler: nil)
        }
    }
    
    @IBAction func showInstructionsPressed(_ sender: Any) {
        self.scrollView.contentOffset = CGPoint(x: self.scrollView.contentOffset.x, y: 452.0)
    }

    @IBAction func showIngredientsPressed(_ sender: Any) {
        self.scrollView.contentOffset = CGPoint(x: self.scrollView.contentOffset.x, y: 0.0)
    }
    
    @IBAction func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.ended {
            let point:CGPoint = recognizer.location(in: ingredientsTable)
            let indexPath:IndexPath? = ingredientsTable.indexPathForRow(at: point)
            if indexPath != nil {
                expandOrContractCellLabel(indexPath: indexPath!)
            }
        }
    }
    
    func storeCellIsExpandedValueForIndexPath(indexPath: IndexPath, newValue: Bool)
    {
        //NSLog(@"%s called for indexPath.section = %ld and indexPath.row = %ld", __PRETTY_FUNCTION__, (long)indexPath.section, (long)indexPath.row);
        
        let itemIndex:Int? = expandedCells.index(of: indexPath)
        
        if newValue == false && itemIndex != nil {
            expandedCells.remove(at: itemIndex!)
        }
        else {
            if newValue == true && itemIndex == nil {
                expandedCells.append(indexPath)
            }
        }
    }
    
    func expandOrContractCellLabel(indexPath:IndexPath)
    {
        //NSLog(@"%s called for indexPath = %i, %i", __PRETTY_FUNCTION__, indexPath.section, indexPath.row );
        
        let currentValue:Bool = fetchCellIsExpandedValueForIndexPath(indexPath: indexPath)
        
        if currentValue {
            storeCellIsExpandedValueForIndexPath(indexPath: indexPath, newValue:false);
        }
        else {
            storeCellIsExpandedValueForIndexPath(indexPath: indexPath, newValue:true);
        }
        
        ingredientsTable.beginUpdates()
        ingredientsTable.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
        ingredientsTable.endUpdates()
    }
    
    func fetchCellIsExpandedValueForIndexPath(indexPath:IndexPath) -> Bool
    {
        var returnValue:Bool = false
        //return returnValue;
        
        //NSLog(@"%s called for indexPath.section = %ld and indexPath.row = %ld", __PRETTY_FUNCTION__, (long)indexPath.section, (long)indexPath.row);
        
        if self.expandedCells.index(of: indexPath) != nil {
            returnValue = true
        }
        
        return returnValue;
    }
    
    func ingredientTextForRow(itemRowNumber: NSInteger) -> String
    {
        var returnValue:String = ""
        
        if recipe != nil {
            let ingredient:Ingredient = recipe!.containsIngredients[itemRowNumber] as! Ingredient
            
            if ingredient.quantity.intValue == 0 && ingredient.unitOfMeasure == "-" {
                if ingredient.ingredientItem.name == "-" {
                    returnValue = " "
                }
                else {
                    returnValue = ingredient.ingredientItem.name
                }
            }
            else {
                returnValue = "\(FractionMath.doubleToString(inputDouble: ingredient.quantity.doubleValue)) \(ingredient.unitOfMeasure) \(ingredient.ingredientItem.name)"
            }
            
            if ingredient.ingredientItem.name != "-" && ingredient.processingInstructions != "" {
                returnValue = returnValue.appendingFormat(", %@", ingredient.processingInstructions)
            }
        }
    
        return returnValue;
    }
    
    func configureLabelForCell(cell:IngredientTableViewCell, indexPath:IndexPath, expandedFlag:Bool, ingredientText:String)
    {
        if (expandedFlag) {
            cell.layoutIfNeeded()

            cell.ingredientLabel!.numberOfLines = 0;
            cell.ingredientLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.ingredientLabel!.text = ingredientText;
        }
        else
        {
            cell.ingredientLabel!.text = ingredientText;
            cell.ingredientLabel!.numberOfLines = 1;
            cell.ingredientLabel!.lineBreakMode = NSLineBreakMode.byTruncatingTail
        }
    }
    
    // MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        AlertUtilities.showAddIngredientAlert(object: recipe!.containsIngredients[indexPath.row] as AnyObject, viewController: self)
    }
    
    // MARK: - Table View Data Source
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        if recipe != nil {
            return recipe!.containsIngredients.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell", for: indexPath)
        
        let ingredientText: String = ingredientTextForRow(itemRowNumber: indexPath.row)
        
        let cellIsExpanded: Bool = fetchCellIsExpandedValueForIndexPath(indexPath: indexPath)
        
        if let ingredientCell = cell as? IngredientTableViewCell {
            configureLabelForCell(cell: ingredientCell, indexPath:indexPath, expandedFlag:cellIsExpanded, ingredientText:ingredientText)
            return ingredientCell
        }
        
        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "emailRecipeSegue" {
            let emailRecipeViewController:EmailRecipeViewController = segue.destination as! EmailRecipeViewController
            
            emailRecipeViewController.initRecipeTitle( recipeTitle: recipeTitle.text! )
            emailRecipeViewController.requestMailComposeViewController()
            return
        }

        if segue.identifier == "textRecipeSegue" {
            let textRecipeViewController:TextIngredientsViewController = segue.destination as! TextIngredientsViewController
            
            textRecipeViewController.initRecipeTitle( recipeTitle: recipeTitle.text! )
            textRecipeViewController.requestMessageComposeViewController()
            return
        }
    }

}
