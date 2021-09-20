//
//  IngredientsTableViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 11/26/15.
//  Copyright © 2015 CarlSmith. All rights reserved.
//

import UIKit

extension NSIndexPath {
    
}

class IngredientsTableViewController: UITableViewController, UIGestureRecognizerDelegate  {

    var embeddedTableView: UITableView!
    var recipeIngredients: NSOrderedSet!
    var expandedCells:[IndexPath] = []
    
    let FONT_SIZE:CGFloat = 17.0
    let CELL_CONTENT_WIDTH:CGFloat = 275.0
    let CELL_CONTENT_MARGIN:CGFloat = 11.0
    let CELL_TEXT_MIN_HEIGHT:CGFloat = 22.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func expandOrContractCellLabel(itemIndexPath: IndexPath)
    {
        let currentValue = fetchCellIsExpandedValueForIndexPath(indexPath: itemIndexPath)
        
        storeCellIsExpandedValueForIndexPath(indexPath: itemIndexPath, value:!currentValue)
        
        embeddedTableView.beginUpdates()
        embeddedTableView.reloadRows(at: [itemIndexPath], with:.none)
        embeddedTableView.endUpdates()
    }
    
    func fetchCellIsExpandedValueForIndexPath(indexPath: IndexPath) -> Bool
    {
        return expandedCells.contains(indexPath)
    }
    
    func storeCellIsExpandedValueForIndexPath(indexPath: IndexPath, value: Bool) {
        let indexPathIndex = expandedCells.index(of: indexPath)
        if value == false && indexPathIndex != nil
        {
            expandedCells.remove(at: indexPathIndex!)
        }
        else
        {
            if value == true && indexPathIndex == nil
            {
                expandedCells.append(indexPath)
            }
        }
    }
    
    func configureLabelForCell( cell: inout UITableViewCell?, indexPath: IndexPath, cellIsExpanded: Bool, ingredientText: String) {
        if cell != nil
        {
            if let cellLabel = cell!.textLabel {
                if (cellIsExpanded) {
                    cell!.layoutIfNeeded()
                    
                    cellLabel.numberOfLines = 0
                    cellLabel.lineBreakMode = .byWordWrapping
                    cellLabel.text = ingredientText
                }
                else {
                    cellLabel.text = ingredientText
                    cellLabel.numberOfLines = 1
                    cellLabel.lineBreakMode = .byTruncatingTail
                }
            }
        }
    }
    
    func ingredientTextForRow(itemRowNumber: NSInteger) -> String
    {
        var returnValue = ""
    
        if let ingredient = recipeIngredients[itemRowNumber] as? Ingredient {
            if ingredient.quantity.intValue == 0 && ingredient.unitOfMeasure == "-"
            {
                if ingredient.ingredientItem.name == "-"
                {
                    returnValue = " "
                }
                else
                {
                    returnValue = ingredient.ingredientItem.name
                }
            }
            else
            {
                returnValue = "\(FractionMath.doubleToString(inputDouble: ingredient.quantity.doubleValue)) \(ingredient.unitOfMeasure) \(ingredient.ingredientItem.name)"
                
                if ingredient.processingInstructions != ""
                {
                    returnValue += ", \(ingredient.processingInstructions)"
                }
            }
        }
        
        return returnValue
    }
    
    func tableRowTotalHeight(indexPath: IndexPath) -> CGFloat {
        return tableRowTextHeight(indexPath: indexPath) + (CELL_CONTENT_MARGIN * 2)
    }
    
    func tableRowTextHeight(indexPath: IndexPath) -> CGFloat
    {
        let rowIsExpanded = fetchCellIsExpandedValueForIndexPath(indexPath: indexPath)
        
        let text = ingredientTextForRow(itemRowNumber: indexPath.row) as NSString
        
        let constraint = CGSize(width: CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), height: 20000.0)
        
        var sizeRect = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
        
        if rowIsExpanded {
            sizeRect = text.boundingRect(with: constraint, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: FONT_SIZE)], context: nil)
        }
        else {
            sizeRect.size.height = CELL_TEXT_MIN_HEIGHT
        }
        
        return max(sizeRect.size.height, CELL_TEXT_MIN_HEIGHT)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableRowTotalHeight(indexPath: indexPath)
    }
    
    //Mark: - Long Press Gesture Recognizer Delegate
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer)
    {
        if gestureRecognizer.state == .ended
        {
            let longPressPoint = gestureRecognizer.location(in: embeddedTableView)
            
            let indexPath = embeddedTableView.indexPathForRow(at: longPressPoint)
            
            if indexPath != nil {
                expandOrContractCellLabel(itemIndexPath: indexPath!)
            }
        }
    }
    
    //Mark: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeIngredients.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ingredientCell")
        
        let ingredientText = ingredientTextForRow(itemRowNumber: indexPath.row)
        
        let cellIsExpanded = fetchCellIsExpandedValueForIndexPath(indexPath: indexPath)
        
        configureLabelForCell(cell: &cell, indexPath: indexPath, cellIsExpanded: cellIsExpanded, ingredientText: ingredientText)
        
        return cell!
    }
    
    //Mark: - Table view delegate
  
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ingredient = recipeIngredients[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated:false)
        
        AlertUtilities.showAddIngredientAlert(object: ingredient as AnyObject, viewController: self)
    }
    
}
