//
//  ModifyGroceryListItemViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 6/10/17.
//  Copyright © 2017 CarlSmith. All rights reserved.
//

import UIKit

struct ModGliVCStruct {
    var itemName: String
    var quantity: Float
    var unitOfMeasure: String
    var taxable: Bool
    var indexPath: IndexPath
}
protocol ModifyGroceryListItemDelegate: class {
    func groceryListItemModified(modStruct: ModGliVCStruct)
}

// This class needs
//
// Item name: String
// Item quantity: Float
// Item unit of measure: String
// Item taxable status: String
// Item cell index path: IndexPath

class ModifyGroceryListItemViewController: UIViewController {

    weak var delegate: ModifyGroceryListItemDelegate?
    
    var modStruct:ModGliVCStruct = ModGliVCStruct(itemName: "",
                                                  quantity: 0.0,
                                                  unitOfMeasure: "",
                                                  taxable: false,
                                                  indexPath: IndexPath())
    
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var unitOMeasureLabel: UILabel!
    @IBOutlet weak var taxableSegmentedControl: UISegmentedControl!
    @IBOutlet weak var okButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        okButton.contentEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureUI()
    }
    
    func configureUI() {
        title = modStruct.itemName
        
        quantityTextField.text = String(modStruct.quantity)
        unitOMeasureLabel.text = modStruct.unitOfMeasure
        taxableSegmentedControl.selectedSegmentIndex = Int(modStruct.taxable)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func okButtonPressed(_ sender: Any) {
        guard let currentQuantity = Float(quantityTextField.text!) else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        let currentTaxableValue = taxableSegmentedControl.selectedSegmentIndex == 1
        
        if currentQuantity == modStruct.quantity && modStruct.taxable == currentTaxableValue {
            NSLog("Nothing changed")
            navigationController?.popViewController(animated: true)
            return
        }
        
        modStruct.taxable = currentTaxableValue
        modStruct.quantity = currentQuantity
        
        delegate?.groceryListItemModified(modStruct: modStruct)
        navigationController?.popViewController(animated: true)
    }

}
