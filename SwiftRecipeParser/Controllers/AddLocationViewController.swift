//
//  AddLocationViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 12/28/22.
//  Copyright © 2022 CarlSmith. All rights reserved.
//

import UIKit

class AddLocationViewController: UIViewController {
    
    var databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
    
    var groceryListItem: GroceryListItem!
    
    var initialStoreName = ""
    var initialAisle = ""
    var initialDetails = ""
    var initialMonth = -1
    var initialDay = -1
    var initialYear = -1
    
    var titleViewLabel = UILabel()
    
    @IBOutlet weak var storeTextField: UITextField!
    @IBOutlet weak var aisleTextField: UITextField!
    @IBOutlet weak var detailsTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
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
        
        datePicker.maximumDate = Date()
        
        if let location = groceryListItem.location {
            storeTextField.text = location.storeName
            aisleTextField.text = location.aisle
            detailsTextField.text = location.details
            datePicker.date = Calendar.current.date(from: DateComponents(year: location.year!.intValue,
                                                                         month: location.month!.intValue,
                                                                         day: location.day!.intValue))!
        }

        assignInitialValues()

        storeTextField.becomeFirstResponder()
    }
    
    func assignInitialValues() {
        initialStoreName = storeTextField.text!
        initialAisle = aisleTextField.text!
        initialDetails = detailsTextField.text!
        let components = DateTimeUtilities.dateToMonthDayYear(date: datePicker.date)
        initialMonth = components.month!
        initialDay = components.day!
        initialYear = components.year!
    }
    
    @IBAction func datePickerValueChanged(_ sender: Any) {
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func hasDataChanged() -> Bool {
        if storeTextField.text! != initialStoreName {
            return true
        }
        if aisleTextField.text! != initialAisle {
            return true
        }
        if detailsTextField.text! != initialDetails {
            return true
        }
        
        let components = DateTimeUtilities.dateToMonthDayYear(date: datePicker.date)
        if components.month! != initialMonth {
            return true
        }
        if components.day! != initialDay {
            return true
        }
        if components.year! != initialYear {
            return true
        }

        return false
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
// CHECK TO BE SURE THAT NO CHANGES HAVE BEEN MADE BEFORE POPPING!
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

    func saveData() {
        let store = storeTextField.text!
//        Logger.logDetails(msg: "Store: \(store)")
        let aisle = aisleTextField.text!
//        Logger.logDetails(msg: "Aisle: \(aisle)")
        let details = detailsTextField.text!
//        Logger.logDetails(msg: "Details: \(details)")
        let components = DateTimeUtilities.dateToMonthDayYear(date: datePicker.date)
        let year = components.year!
        let month = components.month!
        let day = components.day!
//        Logger.logDetails(msg: "Date: \(month)/\(day)/\(year)")
        groceryListItem.setLocation(databaseInterface: databaseInterface,
                                    storeName: store,
                                    aisle: aisle,
                                    details: details,
                                    month: month,
                                    day: day,
                                    year: year)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if hasDataChanged() {
            saveData()
        }
        navigationController?.popViewController(animated: true)
    }
}
