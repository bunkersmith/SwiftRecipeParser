//
//  ModifyGroceryListItemViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 6/10/17.
//  Copyright © 2017 CarlSmith. All rights reserved.
//

import UIKit

protocol ModifyGroceryListItemDelegate: class {
    func groceryListItemModified(groceryListItem: GroceryListItem, indexPath: IndexPath)
}

// This class needs
//
// Item name: String
// Item quantity: Float
// Item unit of measure: String
// Item taxable status: String
// Item cell index path: IndexPath

class ModifyGroceryListItemViewController: UIViewController, UITextFieldDelegate {

    weak var delegate: ModifyGroceryListItemDelegate?
    
    var groceryListItem: GroceryListItem!
    var indexPath: IndexPath!
    var imagePicker: UIImagePickerController!
    var currentTextField: UITextField!
    
    let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)

    let noSegment = 0
    let yesSegment = 1

    var textFieldText = ""

    var titleViewLabel = UILabel()
    
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var costTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var unitOfMeasureTextField: UITextField!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var produceCodeTextField: UITextField!
    @IBOutlet weak var fsaSegmentedControl: UISegmentedControl!
    @IBOutlet weak var taxableSegmentedControl: UISegmentedControl!
    @IBOutlet weak var taxablePriceLabel: UILabel!
    @IBOutlet weak var taxablePriceTextField: UITextField!
    @IBOutlet weak var crvSegmentedControl: UISegmentedControl!
    @IBOutlet weak var crvQuantityLabel: UILabel!
    @IBOutlet weak var crvQuantityTextField: UITextField!
    @IBOutlet weak var crvFluidOuncesLabel: UILabel!
    @IBOutlet weak var crvFluidOuncesTextField: UITextField!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Tell the to NOT use its frame for sizing purposes
        titleViewLabel.translatesAutoresizingMaskIntoConstraints = false
        titleViewLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleViewLabel.adjustsFontSizeToFitWidth = true
        titleViewLabel.numberOfLines = 1
        titleViewLabel.minimumScaleFactor = 0.5
        navigationItem.titleView = titleViewLabel
        
        titleViewLabel.centerXAnchor.constraint(equalTo: navigationItem.titleView!.centerXAnchor).isActive = true
        titleViewLabel.centerYAnchor.constraint(equalTo: navigationItem.titleView!.centerYAnchor).isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureUI()
    }
    
//    @IBAction func addLocationButtonPressed(_ sender: Any) {
//        Location.createOrReturn(databaseInterface: databaseInterface,
//                                storeName: "Murphy Canyon Vons",
//                                aisle: "Paper",
//                                details: "Far back right corner",
//                                month: 12,
//                                day: 27,
//                                year: 2022)
//    }
    
    func configureUI() {
        titleViewLabel.text = groceryListItem.name
        
        costTextField.text = String(format: "%.2f", groceryListItem.cost.floatValue)
        costTextField.addTrailingButton(title: "Done", image: nil, target: self, selector: #selector(doneWithKeypad))
        costTextField.delegate = self
        
        quantityTextField.text = String(format: "%.2f", groceryListItem.quantity.floatValue)
        quantityTextField.addTrailingButton(title: "Done", image: nil, target: self, selector: #selector(doneWithKeypad))
        quantityTextField.delegate = self
        
        unitOfMeasureTextField.text = groceryListItem.unitOfMeasure
        unitOfMeasureTextField.addTrailingButton(title: "Done", image: nil, target: self, selector: #selector(doneWithKeypad))
        unitOfMeasureTextField.delegate = self
        
        notesTextField.text = groceryListItem.notes
        notesTextField.addTrailingButton(title: "Done", image: nil, target: self, selector: #selector(doneWithKeypad))
        notesTextField.delegate = self
        
        if groceryListItem.location != nil {
            addLocationButton.setTitle("Edit Location", for: .normal)
            addLocationButton.backgroundColor = UIColor(red: 0.0, green: 0.375, blue: 0.0, alpha: 1)
            addLocationButton.setTitleColor(UIColor.white, for: .normal)
        } else {
            addLocationButton.setTitle("Add Location", for: .normal)
        }
        
        let produceCode = groceryListItem.produceCode.int32Value
        if produceCode != 0 {
            produceCodeTextField.text = String(produceCode)
        }
        produceCodeTextField.addTrailingButton(title: "Done", image: nil, target: self, selector: #selector(doneWithKeypad))
        produceCodeTextField.delegate = self

        taxableSegmentedControl.selectedSegmentIndex = Int(groceryListItem.isTaxable.boolValue)
        configureTaxablePrice()
        
        fsaSegmentedControl.selectedSegmentIndex = Int(groceryListItem.isFsa.boolValue)
        
        crvSegmentedControl.selectedSegmentIndex = Int(groceryListItem.isCrv.boolValue)
        configureCrvUI()
        
        updateTotalCostLabel()
        
        configureThumbnail()
    }
    
    @objc func doneWithKeypad() {
        currentTextField.resignFirstResponder()
    }
    
    func updateTotalCostLabel() {
        totalCostLabel.text = groceryListItem.totalCostString()
    }
    
    func configureTaxablePrice() {
        taxablePriceTextField.addTrailingButton(title: "Done", image: nil, target: self, selector: #selector(doneWithKeypad))
        taxablePriceTextField.delegate = self
        if taxableSegmentedControl.selectedSegmentIndex == yesSegment {
            taxablePriceLabel.alpha = 1.0
            taxablePriceTextField.alpha = 1.0
            taxablePriceTextField.text = String(format: "%.2f", groceryListItem.taxablePrice.floatValue)
        } else {
            taxablePriceLabel.alpha = 0.0
            taxablePriceTextField.alpha = 0.0
        }
    }
    
    func configureCrvUI() {
        crvQuantityTextField.addTrailingButton(title: "Done", image: nil, target: self, selector: #selector(doneWithKeypad))
        crvQuantityTextField.delegate = self
        crvFluidOuncesTextField.addTrailingButton(title: "Done", image: nil, target: self, selector: #selector(doneWithKeypad))
        crvFluidOuncesTextField.delegate = self

        if crvSegmentedControl.selectedSegmentIndex == yesSegment {
            crvQuantityLabel.alpha = 1.0
            crvQuantityTextField.alpha = 1.0
            crvFluidOuncesLabel.alpha = 1.0
            crvFluidOuncesTextField.alpha = 1.0
            crvQuantityTextField.text = String(groceryListItem.crvQuantity.int16Value)
            crvFluidOuncesTextField.text = String(format: "%.1f", groceryListItem.crvFluidOunces.floatValue)
        } else {
            crvQuantityLabel.alpha = 0.0
            crvQuantityTextField.alpha = 0.0
            crvFluidOuncesLabel.alpha = 0.0
            crvFluidOuncesTextField.alpha = 0.0
        }
    }
    
    func  configureThumbnail() {
        if groceryListItem.imagePath != nil {
            
            let fullImagePath = FileUtilities.applicationDocumentsDirectory().appendingPathComponent("\(groceryListItem.imagePath!)").path
            
            let url = URL(fileURLWithPath: fullImagePath)
            
            guard let thumbnailData = try? Data(contentsOf: url) else {
                return
            }
            
            guard let thumbnailImage = UIImage(data: thumbnailData as Data) else {
                return
            }
            
            imageView.alpha = 1.0
            imageView.image = thumbnailImage
            
            addPhotoButton.setTitle("Delete Photo", for: .normal)
            
        } else {
            imageView.alpha = 0.0
            addPhotoButton.setTitle("Add Photo", for: .normal)
        }
    }
    
    @IBAction func taxableControlChanged(_ sender: UISegmentedControl) {
//        groceryListItem.update(taxable: sender.selectedSegmentIndex == yesSegment, saveContext: true)
        configureTaxablePrice()
//        updateTotalCostLabel()
//        delegate?.groceryListItemModified(groceryListItem: groceryListItem, indexPath: indexPath)
    }
    
    @IBAction func fsaControlChanged(_ sender: UISegmentedControl) {
//        groceryListItem.update(fsa: sender.selectedSegmentIndex == yesSegment, saveContext: true)
//        delegate?.groceryListItemModified(groceryListItem: groceryListItem, indexPath: indexPath)
    }
    
    @IBAction func crvControlChanged(_ sender: UISegmentedControl) {
        // The item may have previously-entered values for the quantity and fluid ounces if the switch
        // is transitioning from off to on
        
        // TODO: Clear those values in the grocery list item here before updating the UI
//        groceryListItem.update(crv: sender.selectedSegmentIndex == yesSegment, saveContext: true)
        configureCrvUI()
//        updateTotalCostLabel()
//        delegate?.groceryListItemModified(groceryListItem: groceryListItem, indexPath: indexPath)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "fullResSegue" {
            guard let groceryItemPhotoViewController = segue.destination as? GroceryItemPhotoViewController else {
                return
            }

            groceryItemPhotoViewController.groceryListItem = groceryListItem
            
            return
        }
        
        if segue.identifier == "addLocationSegue" {
            guard let addLocationViewController = segue.destination as? AddLocationViewController else {
                return
            }

            addLocationViewController.groceryListItem = groceryListItem
            
            return
        }
    }

    func hasIntChanged(textField: UITextField, textFieldName: String, oldValue: Int16) -> Bool {
        
        let textFieldText = textField.text!
        
        if textFieldText.isEmpty {
            return oldValue != 0
        }

        let textFieldValue = Int16(textFieldText)
        
        return textFieldValue != oldValue
    }

    func hasInt32Changed(textField: UITextField, textFieldName: String, oldValue: Int32) -> Bool {
        
        let textFieldText = textField.text!
        
        if textFieldText.isEmpty {
            return oldValue != 0
        }

        let textFieldValue = Int32(textFieldText)
        
        return textFieldValue != oldValue
    }

    func hasFloatChanged(textField: UITextField, textFieldName: String, oldValue: Float) -> Bool {
        
        let textFieldText = textField.text!
        
        if textFieldText.isEmpty {
            return oldValue != 0.0
        }

        let textFieldValue = Float(textFieldText)
        
        return textFieldValue != oldValue
    }

    func hasQuantityChanged(textField: UITextField, textFieldName: String, oldValue: Double) -> Bool {
        
        let textFieldText = textField.text!
        
        if textFieldText.isEmpty {
            return oldValue != 0.0
        }

        var textFieldDoubleValue: Double? = nil
        
        if textFieldText.rangeOfCharacter(from: CharacterSet(charactersIn: "-/")) != nil {
            if FractionMath.validateFractionString(fractionString: textFieldText) {
                textFieldDoubleValue = FractionMath.stringToDouble(inputString: textFieldText)
            }
        } else {
            textFieldDoubleValue = Double(textFieldText)
        }
        return textFieldDoubleValue != oldValue
    }
    
    func hasBoolChanged(segmentedControl: UISegmentedControl, oldValue: Bool) -> Bool {

        let segmentedControlValue = segmentedControl.selectedSegmentIndex == 1
        
        if segmentedControlValue != oldValue {
            return true
        }
        
        return false
    }
    
    func hasDataChanged() -> Bool {
        
        if hasQuantityChanged(textField: quantityTextField, textFieldName: "Quantity", oldValue: groceryListItem.quantity.doubleValue) {
            return true
        }
        
        if hasFloatChanged(textField: costTextField, textFieldName: "Price", oldValue: groceryListItem.cost.floatValue) {
            return true
        }
        
        if unitOfMeasureTextField.text != groceryListItem.unitOfMeasure {
            return true
        }
        
        if hasBoolChanged(segmentedControl: taxableSegmentedControl, oldValue: groceryListItem.isTaxable.boolValue) {
            return true
        }
        
        if hasFloatChanged(textField: taxablePriceTextField, textFieldName: "Taxable Price", oldValue: groceryListItem.taxablePrice.floatValue) {
            return true
        }
        
        if hasBoolChanged(segmentedControl: fsaSegmentedControl, oldValue: groceryListItem.isFsa.boolValue) {
            return true
        }
        
        if hasBoolChanged(segmentedControl: crvSegmentedControl, oldValue: groceryListItem.isCrv.boolValue) {
            return true
        }

        if hasIntChanged(textField: crvQuantityTextField, textFieldName: "CRV Quantity", oldValue: groceryListItem.crvQuantity.int16Value) {
            return true
        }

        if hasFloatChanged(textField: crvFluidOuncesTextField, textFieldName: "CRV Fluid Ounces", oldValue: groceryListItem.crvFluidOunces.floatValue) {
            return true
        }

        if notesTextField.text != groceryListItem.notes {
            return true
        }

        if hasInt32Changed(textField: produceCodeTextField, textFieldName: "Produce Code", oldValue: groceryListItem.produceCode.int32Value) {
            return true
        }
        
        return false
    }

    func updateIntValue(textField: UITextField) -> NSNumber? {
        if textField.text!.isEmpty {
            return NSNumber(value: Int16(0))
        } else {
            if let intValue = Int16(textField.text!) {
                return NSNumber(value: intValue)
            } else {
                return nil
            }
        }
    }

    func updateInt32Value(textField: UITextField) -> NSNumber? {
        if textField.text!.isEmpty {
            return NSNumber(value: Int32(0))
        } else {
            if let int32Value = Int32(textField.text!) {
                return NSNumber(value: int32Value)
            } else {
                return nil
            }
        }
    }

    func updateFloatValue(textField: UITextField) -> NSNumber? {
        if textField.text!.isEmpty {
            return NSNumber(value: Float(0))
        } else {
            if let floatValue = Float(textField.text!) {
                return NSNumber(value: floatValue)
            } else {
                return nil
            }
        }
    }

    func updateQuantityValue(textField: UITextField) -> NSNumber? {
        let textFieldText = textField.text!
        
        if textFieldText.isEmpty {
            return NSNumber(value: Double(0))
        } else {
            if textFieldText.rangeOfCharacter(from: CharacterSet(charactersIn: "-/")) != nil {
                // CONVERT THE FRACTION VALUE TO A NSNumber DOUBLE OR RETURN NIL IF THE FRACTION SYNTAX IS INVALID
                if FractionMath.validateFractionString(fractionString: textFieldText) {
                    return NSNumber(value: FractionMath.stringToDouble(inputString: textFieldText))
                }
            } else {
                if let doubleValue = Double(textField.text!) {
                    return NSNumber(value: doubleValue)
                }
            }
        }
        return nil
    }
    
    func updateBoolValue(segmentedControl: UISegmentedControl) -> NSNumber {
        let controlValue = segmentedControl.selectedSegmentIndex == 1

        return NSNumber(value: controlValue)
    }
    
    func saveData() -> Bool {
        var errorFound = false
        
        if hasDataChanged() {

            if let groceryListItemCost = updateFloatValue(textField: costTextField) {
                groceryListItem.cost = groceryListItemCost
            } else {
                errorFound = true
                AlertUtilities.showOkButtonAlert(self, title: "Error Alert", message: "Invalid number entered for item cost", buttonHandler: nil)
            }
            
            if let groceryListItemQuantity = updateQuantityValue(textField: quantityTextField) {
                groceryListItem.quantity = groceryListItemQuantity
            } else {
                errorFound = true
                AlertUtilities.showOkButtonAlert(self, title: "Error Alert", message: "Invalid number entered for item quantity", buttonHandler: nil)
            }
            
            groceryListItem.unitOfMeasure = unitOfMeasureTextField.text!

            groceryListItem.isFsa = updateBoolValue(segmentedControl: fsaSegmentedControl)
            
            groceryListItem.isTaxable = updateBoolValue(segmentedControl: taxableSegmentedControl)
            
            if let groceryListItemTaxablePrice = updateFloatValue(textField: taxablePriceTextField) {
                groceryListItem.taxablePrice = groceryListItemTaxablePrice
            } else {
                errorFound = true
                AlertUtilities.showOkButtonAlert(self, title: "Error Alert", message: "Invalid number entered for item taxable price", buttonHandler: nil)
            }

            groceryListItem.isCrv = updateBoolValue(segmentedControl: crvSegmentedControl)
            
            if let groceryListItemCrvQuantity = updateIntValue(textField: crvQuantityTextField) {
                groceryListItem.crvQuantity = groceryListItemCrvQuantity
            } else {
                errorFound = true
                AlertUtilities.showOkButtonAlert(self, title: "Error Alert", message: "Invalid number entered for item CRV quantity", buttonHandler: nil)
            }
            
            if let groceryListItemCrvFluidOunces = updateFloatValue(textField: crvFluidOuncesTextField) {
                groceryListItem.crvFluidOunces = groceryListItemCrvFluidOunces
            } else {
                errorFound = true
                AlertUtilities.showOkButtonAlert(self, title: "Error Alert", message: "Invalid number entered for item CRV fluid ounces", buttonHandler: nil)
            }

            groceryListItem.notes = notesTextField.text!
            
            if let groceryListItemProduceCode = updateInt32Value(textField: produceCodeTextField) {
                groceryListItem.produceCode = groceryListItemProduceCode
            } else {
                errorFound = true
                AlertUtilities.showOkButtonAlert(self, title: "Error Alert", message: "Invalid number entered for item CRV quantity", buttonHandler: nil)
            }

            if !errorFound {
                groceryListItem.calculateTotalCost()
                
                let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
                databaseInterface.saveContext()
                
                groceryListItem.writeToIcloud()
                
                delegate?.groceryListItemModified(groceryListItem: groceryListItem, indexPath: indexPath)
            }
        }
        
        return !errorFound
    }
    
    func showTextFieldAlert(_ textFieldName: String) {
        AlertUtilities.showOkButtonAlert(self, title: "\(textFieldName) text field error", message: "", buttonHandler: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        if hasDataChanged() {
            AlertUtilities.showYesNoAlert(viewController: self, title: "Unsaved Changes", message: "Would you like to save your changes?", yesButtonHandler: { [weak self] alertAction in
                guard let strongSelf = self else {
                    Logger.logDetails(msg: "self error")
                    return
                }
                if strongSelf.saveData() {
                    strongSelf.navigationController?.popViewController(animated: true)
                }
                return
            }, noButtonHandler: { [weak self] alertAction in
                guard let strongSelf = self else {
                    Logger.logDetails(msg: "self error")
                    return
                }
                strongSelf.navigationController?.popViewController(animated: true)
                return
            })
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if saveData() {
            navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func addPhotoButtonPressed(_ sender: Any) {
        if groceryListItem.imagePath == nil {
            showPhotoAlert()
        } else {
            showDeleteAlert()
        }
    }
    
    @IBAction func segueButtonPressed(_ sender: UITapGestureRecognizer) {
        if groceryListItem.imagePath != nil {
            performSegue(withIdentifier: "fullResSegue", sender: self)
        }
    }

    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if textField == costTextField {
            return textField.priceTextField(textField, shouldChangeCharactersIn: range, replacementString: string)
        }
        if textField == quantityTextField {
            return textField.quantityTextField(textField, shouldChangeCharactersIn: range, replacementString: string)
        }
        return true
    }
}
