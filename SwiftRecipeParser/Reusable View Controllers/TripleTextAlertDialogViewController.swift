//
//  AlertDialogViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/18/21.
//

import UIKit

class TripleTextAlertDialogViewController: UIViewController {

    typealias TripleTextAlertDialogCompletion = ((Float,String,Float) -> Void)

    @IBOutlet private weak var dialogBoxView: UIView!
    @IBOutlet private weak var okayButton: UIButton!
    @IBOutlet private weak var prompt: UILabel!

    @IBOutlet private weak var quantityTextField: UITextField!
    @IBOutlet private weak var unitsTextField: UITextField!
    @IBOutlet private weak var priceTextField: UITextField!

    private var promptText = ""
    private var initialQuantityText = ""
    private var initialUnitsText = ""
    private var initialPriceText = ""

    private var completion: TripleTextAlertDialogCompletion!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //adding an overlay to the view to give focus to the dialog box
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        //customizing the dialog box view
        dialogBoxView.layer.cornerRadius = 16.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        prompt.text = promptText

        quantityTextField.addLeadingButton(title: nil, image: UIImage(named: "ic_mic"), target: self, selector: #selector(startTextRecognition))
        priceTextField.becomeFirstResponder()
        
        quantityTextField.safeFill(newText: initialQuantityText)
        unitsTextField.safeFill(newText: initialUnitsText)
        priceTextField.safeFill(newText: initialPriceText)
    }
    
    @IBAction func okayButtonPressed(_ sender: Any) {
        guard quantityTextField.text != nil, quantityTextField.text != "",
              unitsTextField.text != nil, unitsTextField.text != "",
              priceTextField.text != nil, priceTextField.text != "" else {
                AlertUtilities.showOkButtonAlert(self, title: "Please enter quantity, units and price values", message: "", buttonHandler: nil)
            return
        }
        
        completion(Float(quantityTextField.text!)!,
                   unitsTextField.text!,
                   Float(priceTextField.text!)!)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func startTextRecognition() {
        Logger.logDetails(msg: "Entered")
    }

    static func showPopup(parentVC: UIViewController,
                          prompt: String,
                          initialQuantity: String,
                          initialUnits: String,
                          initialPrice: String,
                          completionHandler: @escaping TripleTextAlertDialogCompletion) {
        //creating a reference for the dialogView controller
        if let popupViewController = UIStoryboard(name: "TripleTextAlertDialog", bundle: nil).instantiateViewController(withIdentifier: "TripleTextAlertDialogViewController") as? TripleTextAlertDialogViewController {
            
            popupViewController.modalPresentationStyle = .custom
            popupViewController.modalTransitionStyle = .coverVertical
            
            popupViewController.promptText = prompt
            
            popupViewController.initialQuantityText = initialQuantity
            popupViewController.initialUnitsText = initialUnits
            popupViewController.initialPriceText = initialPrice

            popupViewController.completion = completionHandler
            
            //presenting the pop up viewController from the parent viewController
            parentVC.present(popupViewController, animated: true)
        }
    }
}
