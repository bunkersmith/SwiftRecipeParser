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
    
    func configureUI() {
        titleViewLabel.text = groceryListItem.name
        
        costTextField.text = String(describing: groceryListItem.cost)
        quantityTextField.text = String(describing: groceryListItem.quantity)
        unitOfMeasureTextField.text = groceryListItem.unitOfMeasure
        notesTextField.text = groceryListItem.notes
        
        taxableSegmentedControl.selectedSegmentIndex = Int(groceryListItem.isTaxable.boolValue)
        configureTaxablePrice()
        
        fsaSegmentedControl.selectedSegmentIndex = Int(groceryListItem.isFsa.boolValue)
        
        crvSegmentedControl.selectedSegmentIndex = Int(groceryListItem.isCrv.boolValue)
        configureCrvUI()
        
        updateTotalCostLabel()
        
        configureThumbnail()
    }

    func updateTotalCostLabel() {
        totalCostLabel.text = groceryListItem.totalCostString()
    }
    
    func configureTaxablePrice() {
        if taxableSegmentedControl.selectedSegmentIndex == yesSegment {
            taxablePriceLabel.alpha = 1.0
            taxablePriceTextField.alpha = 1.0
            taxablePriceTextField.text = String(groceryListItem.taxablePrice.floatValue)
        } else {
            taxablePriceLabel.alpha = 0.0
            taxablePriceTextField.alpha = 0.0
        }
    }
    
    func configureCrvUI() {
        if crvSegmentedControl.selectedSegmentIndex == yesSegment {
            crvQuantityLabel.alpha = 1.0
            crvQuantityTextField.alpha = 1.0
            crvFluidOuncesLabel.alpha = 1.0
            crvFluidOuncesTextField.alpha = 1.0
            crvQuantityTextField.text = String(groceryListItem.crvQuantity.intValue)
            crvFluidOuncesTextField.text = String(groceryListItem.crvFluidOunces.floatValue)
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
        }
        
    }

    func hasFloatChanged(textField: UITextField, textFieldName: String, oldValue: Float) -> Bool {
        
        let textFieldText = textField.text!
        
        if textFieldText.isEmpty {
            return oldValue != 0.0
        }

        let textFieldValue = Float(textFieldText)
        
        return textFieldValue != oldValue
    }

    func hasBoolChanged(segmentedControl: UISegmentedControl, oldValue: Bool) -> Bool {

        let segmentedControlValue = segmentedControl.selectedSegmentIndex == 1
        
        if segmentedControlValue != oldValue {
            return true
        }
        
        return false
    }
    
    func hasDataChanged() -> Bool {
        
        if hasFloatChanged(textField: quantityTextField, textFieldName: "Quantity", oldValue: groceryListItem.quantity.floatValue) {
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

        if hasFloatChanged(textField: crvQuantityTextField, textFieldName: "CRV Quantity", oldValue: groceryListItem.crvQuantity.floatValue) {
            return true
        }

        if hasFloatChanged(textField: crvFluidOuncesTextField, textFieldName: "CRV Fluid Ounces", oldValue: groceryListItem.crvFluidOunces.floatValue) {
            return true
        }

        if notesTextField.text != groceryListItem.notes {
            return true
        }

        return false
    }
    

    func updateFloatValue(textField: UITextField) -> NSNumber {
        if textField.text!.isEmpty {
            return NSNumber(value: Float(0))
        } else {
            return NSNumber(value: Float(textField.text!)!)
        }
    }
    
    func updateBoolValue(segmentedControl: UISegmentedControl) -> NSNumber {
        let controlValue = segmentedControl.selectedSegmentIndex == 1

        return NSNumber(value: controlValue)
    }
    
    func saveData() {
        if hasDataChanged() {

            groceryListItem.cost = updateFloatValue(textField: costTextField)
            groceryListItem.quantity = updateFloatValue(textField: quantityTextField)
            groceryListItem.unitOfMeasure = unitOfMeasureTextField.text!

            groceryListItem.isFsa = updateBoolValue(segmentedControl: fsaSegmentedControl)
            
            groceryListItem.isTaxable = updateBoolValue(segmentedControl: taxableSegmentedControl)
            groceryListItem.taxablePrice = updateFloatValue(textField: taxablePriceTextField)

            groceryListItem.isCrv = updateBoolValue(segmentedControl: crvSegmentedControl)
            groceryListItem.crvQuantity = updateFloatValue(textField: crvQuantityTextField)
            groceryListItem.crvFluidOunces = updateFloatValue(textField: crvFluidOuncesTextField)

            groceryListItem.notes = notesTextField.text!
         
            groceryListItem.calculateTotalCost()
            
            let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
            databaseInterface.saveContext()
            
            delegate?.groceryListItemModified(groceryListItem: groceryListItem, indexPath: indexPath)
        }
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
                strongSelf.saveData()
                strongSelf.navigationController?.popViewController(animated: true)
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
        saveData()
        navigationController?.popViewController(animated: true)
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

    func textFieldDidBeginEditing(_ textField: UITextField) {
//        textFieldText = textField.text!
        Logger.logDetails(msg: "\(textFieldText)")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
/*
//        Logger.logDetails(msg: "\(textFieldText)")
        
        if textField.text! != textFieldText {
            switch textField {
                case costTextField:
                    groceryListItem.update(cost: Float(textField.text!)!, saveContext: true)
                break
                case quantityTextField:
                    groceryListItem.update(quantity: Float(textField.text!)!, saveContext: true)
                break
                case unitOfMeasureTextField:
                    groceryListItem.update(unitOfMeasure: textField.text!, saveContext: true)
                break
                case taxablePriceTextField:
                    groceryListItem.update(taxablePrice: Float(textField.text!)!, saveContext: true)
                break
                case crvQuantityTextField:
                    groceryListItem.update(crvQuantity: Int(textField.text!)!, saveContext: true)
                break
                case crvFluidOuncesTextField:
                    groceryListItem.update(crvFluidOunces: Float(textField.text!)!, saveContext: true)
                break
                case notesTextField:
                    groceryListItem.update(notes: notesTextField.text!, saveContext: true)
                break
                default:
                break
            }
            updateTotalCostLabel()
            delegate?.groceryListItemModified(groceryListItem: groceryListItem, indexPath: indexPath)
        } else {
            textFieldText = ""
        }
*/
    }
}
