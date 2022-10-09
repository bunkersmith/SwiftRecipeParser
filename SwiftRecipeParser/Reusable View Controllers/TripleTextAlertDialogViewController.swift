//
//  AlertDialogViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/18/21.
//

import UIKit

class TripleTextAlertDialogViewController: UIViewController, UITextFieldDelegate {

    typealias TripleTextAlertDialogCompletion = ((Float,String,Float) -> Void)

    @IBOutlet private weak var dialogBoxView: UIView!
    @IBOutlet private weak var okayButton: UIButton!
    @IBOutlet private weak var prompt: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
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
        errorLabel.isHidden = true
        
        quantityTextField.addLeadingButton(title: nil, image: UIImage(named: "ic_mic"), target: self, selector: #selector(startTextRecognition))
        priceTextField.addLeadingButton(title: ".99", image: nil, target: self, selector: #selector(ninetyNineCents))
        priceTextField.becomeFirstResponder()
        
        quantityTextField.safeFill(newText: initialQuantityText)
        unitsTextField.safeFill(newText: initialUnitsText)
        priceTextField.safeFill(newText: initialPriceText)
    }
    
    @IBAction func okayButtonPressed(_ sender: Any) {
        guard quantityTextField.text != nil, quantityTextField.text != "",
              unitsTextField.text != nil, unitsTextField.text != "",
              priceTextField.text != nil, priceTextField.text != "" else {
            errorLabel.text = "Enter all values"
            errorLabel.isHidden = false
            return
        }
        
        let textFieldText = quantityTextField.text!
        var quantity: Float? = nil
        
        if textFieldText.rangeOfCharacter(from: CharacterSet(charactersIn: "-/")) != nil {
            if FractionMath.validateFractionString(fractionString: textFieldText) {
                quantity = Float(FractionMath.stringToDouble(inputString: textFieldText))
            }
        } else {
            quantity = Float(textFieldText)
        }

        guard quantity != nil else {
            errorLabel.text = "Enter a valid quantity"
            errorLabel.isHidden = false
            return
        }

        guard let price = Float(priceTextField.text!) else {
            errorLabel.text = "Enter a valid price"
            errorLabel.isHidden = false
            return
        }
        
        errorLabel.isHidden = true
        
        completion(quantity!,
                   unitsTextField.text!,
                   price)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func startTextRecognition() {
        Logger.logDetails(msg: "Entered")
    }

    @objc func ninetyNineCents() {
        guard priceTextField.text != nil else {
            return
        }
//        Logger.logDetails(msg: "Price: \(priceTextField.text!)")
        if let periodIndex = priceTextField.text!.index(of: ".") {
//            Logger.logDetails(msg: "Index of .: \(periodIndex)")
            priceTextField.text!.replaceSubrange(periodIndex..., with: "")
        }
        priceTextField.text!.append(".99")
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

    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if textField == priceTextField {
            return textField.priceTextField(textField, shouldChangeCharactersIn: range, replacementString: string)
        } else {
            return true
        }
    }
}
