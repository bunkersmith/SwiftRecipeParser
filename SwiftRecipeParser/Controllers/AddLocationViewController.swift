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
        
        storeTextField.becomeFirstResponder()
    }
    
    @IBAction func datePickerValueChanged(_ sender: Any) {
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
// CHECK TO BE SURE THAT NO CHANGES HAVE BEEN MADE BEFORE POPPING!
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let store = storeTextField.text!
        Logger.logDetails(msg: "Store: \(store)")
        let aisle = aisleTextField.text!
        Logger.logDetails(msg: "Aisle: \(aisle)")
        let details = detailsTextField.text!
        Logger.logDetails(msg: "Details: \(details)")
        let components = DateTimeUtilities.dateToMonthDayYear(date: datePicker.date)
        let year = components.year!
        let month = components.month!
        let day = components.day!
        Logger.logDetails(msg: "Date: \(month)/\(day)/\(year)")
        groceryListItem.setLocation(databaseInterface: databaseInterface,
                                    storeName: store,
                                    aisle: aisle,
                                    details: details,
                                    month: month,
                                    day: day,
                                    year: year)
        navigationController?.popViewController(animated: true)
    }
}
