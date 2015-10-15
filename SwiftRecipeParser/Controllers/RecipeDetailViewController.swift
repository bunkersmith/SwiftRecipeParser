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
    
    private var expandedCells:Array<NSIndexPath> = Array()
    @IBOutlet weak var ingredientsTable: UITableView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var instructionsTextView: UITextView!
    @IBOutlet weak var instructionsVerticalSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var showInstructionsButton: UIButton!
    @IBOutlet weak var showIngredientsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if recipe != nil {
            self.recipeTitle.text = recipe!.title.name
        }
    }

    override func viewWillAppear(animated: Bool) {
        
        let deviceString:String =  UIDevice.currentDevice().model
        if deviceString.rangeOfString("iPad") != nil {
            instructionsVerticalSpaceConstraint.constant = 15.0
        }
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.showIngredientsButton.frame.origin.y + 40)
        
        if recipe != nil {
            instructionsTextView.text = recipe!.instructions
            instructionsTextView.contentOffset = CGPointZero
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showInstructionsPressed(sender: AnyObject) {
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, 452)
    }
    
    @IBAction func showIngredientsPressed(sender: AnyObject) {
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, 0)
    }
    
    @IBAction func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Ended {
            let point:CGPoint = recognizer.locationInView(ingredientsTable)
            let indexPath:NSIndexPath? = ingredientsTable.indexPathForRowAtPoint(point)
            if indexPath != nil {
                expandOrContractCellLabel(indexPath!)
            }
        }
    }
    
    func storeCellIsExpandedValueForIndexPath(indexPath: NSIndexPath, newValue: Bool)
    {
        //NSLog(@"%s called for indexPath.section = %ld and indexPath.row = %ld", __PRETTY_FUNCTION__, (long)indexPath.section, (long)indexPath.row);
        
        let itemIndex:Int? = expandedCells.indexOf(indexPath)
        
        if newValue == false && itemIndex != nil {
            expandedCells.removeAtIndex(itemIndex!)
        }
        else {
            if newValue == true && itemIndex == nil {
                expandedCells.append(indexPath)
            }
        }
    }
    
    func expandOrContractCellLabel(indexPath:NSIndexPath)
    {
        //NSLog(@"%s called for indexPath = %i, %i", __PRETTY_FUNCTION__, indexPath.section, indexPath.row );
        
        let currentValue:Bool = fetchCellIsExpandedValueForIndexPath(indexPath)
        
        if currentValue {
            storeCellIsExpandedValueForIndexPath(indexPath, newValue:false);
        }
        else {
            storeCellIsExpandedValueForIndexPath(indexPath, newValue:true);
        }
        
        ingredientsTable.beginUpdates()
        ingredientsTable.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        ingredientsTable.endUpdates()
    }
    
    func fetchCellIsExpandedValueForIndexPath(indexPath:NSIndexPath) -> Bool
    {
        var returnValue:Bool = false
        //return returnValue;
        
        //NSLog(@"%s called for indexPath.section = %ld and indexPath.row = %ld", __PRETTY_FUNCTION__, (long)indexPath.section, (long)indexPath.row);
        
        if self.expandedCells.indexOf(indexPath) != nil {
            returnValue = true
        }
        
        return returnValue;
    }
    
    func ingredientTextForRow(itemRowNumber: NSInteger) -> String
    {
        var returnValue:String = ""
        
        if recipe != nil {
            let ingredient:Ingredient = recipe!.containsIngredients[itemRowNumber] as! Ingredient
            
            if ingredient.quantity.integerValue == 0 && ingredient.unitOfMeasure == "-" {
                if ingredient.ingredientItem.name == "-" {
                    returnValue = " "
                }
                else {
                    returnValue = ingredient.ingredientItem.name
                }
            }
            else {
                returnValue = "\(FractionMath.doubleToString(ingredient.quantity.doubleValue)) \(ingredient.unitOfMeasure) \(ingredient.ingredientItem.name)"
                
                if ingredient.processingInstructions != "" {
                    returnValue = returnValue.stringByAppendingFormat(", %@", ingredient.processingInstructions)
                }
            }
        }
    
        return returnValue;
    }
    
    func configureLabelForCell(cell:UITableViewCell, indexPath:NSIndexPath, expandedFlag:Bool, ingredientText:String)
    {
        if (expandedFlag) {
            cell.layoutIfNeeded()

            cell.textLabel!.numberOfLines = 0;
            cell.textLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell.textLabel!.text = ingredientText;
        }
        else
        {
            cell.textLabel!.text = ingredientText;
            cell.textLabel!.numberOfLines = 1;
            cell.textLabel!.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        }
    }
    
    func showAddIngredientAlert(object: AnyObject)
    {
        let databaseInterface = DatabaseInterface()
        let selectedIngredient:Ingredient = object as! Ingredient;
        let currentGroceryList = GroceryList.returnCurrentGroceryListWithDatabaseInterfacePtr(databaseInterface)
    
        if (currentGroceryList == nil)
        {
            if #available(iOS 8.0, *) {
                Utilities.showOkButtonAlert(self, title: "Error Alert", message: "No current grocery list", okButtonHandler: nil)
            } else {
                // Fallback on earlier versions
            }
        }
        else
        {
            let quantityString:String = FractionMath.doubleToString(selectedIngredient.quantity.doubleValue);
            let addString = "Add \(quantityString) \(selectedIngredient.unitOfMeasure) \(selectedIngredient.ingredientItem.name) to the \(currentGroceryList!.name) grocery list?"
            if #available(iOS 8.0, *) {
                Utilities.showYesNoAlert(self, title: "Add Item", message: addString, yesButtonHandler: { action in
                    let groceryListItem:GroceryListItem = databaseInterface.newManagedObjectOfType("GroceryListItem") as! GroceryListItem
                    groceryListItem.name = selectedIngredient.ingredientItem.name
                    currentGroceryList!.addHasItemsObject(groceryListItem)
                    databaseInterface.saveContext()
                })
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    // MARK: - Table View Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        showAddIngredientAlert(recipe!.containsIngredients[indexPath.row])
    }
    
    // MARK: - Table View Data Source
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        if recipe != nil {
            return recipe!.containsIngredients.count
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "IngredientCell")
        
        let ingredientText: String = ingredientTextForRow(indexPath.row)
        
        let cellIsExpanded: Bool = fetchCellIsExpandedValueForIndexPath(indexPath)
        
        configureLabelForCell(cell, indexPath:indexPath, expandedFlag:cellIsExpanded, ingredientText:ingredientText)
        
        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "emailRecipeSegue" {
            let emailRecipeViewController:EmailRecipeViewController = segue.destinationViewController as! EmailRecipeViewController
            
            emailRecipeViewController.initRecipeTitle( recipeTitle.text! )
            emailRecipeViewController.requestMailComposeViewController()
        }
    }

}
