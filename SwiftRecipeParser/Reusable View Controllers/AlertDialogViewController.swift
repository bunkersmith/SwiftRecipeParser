//
//  AlertDialogViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/18/21.
//

import UIKit

class AlertDialogViewController: UIViewController {

    @IBOutlet private weak var dialogBoxView: UIView!
    @IBOutlet private weak var okayButton: UIButton!
    @IBOutlet private weak var prompt: UILabel!
    @IBOutlet private weak var textField: UITextField!
    
    private var textFieldKeyboardType: UIKeyboardType!
    private var promptText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //adding an overlay to the view to give focus to the dialog box
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        //customizing the dialog box view
        dialogBoxView.layer.cornerRadius = 16.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textField.keyboardType = textFieldKeyboardType
        textField.addLeadingButton(title: nil, image: UIImage(named: "ic_mic"), target: self, selector: #selector(startTextRecognition))
        textField.becomeFirstResponder()
        prompt.text = promptText
    }
    
    @IBAction func okayButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func startTextRecognition() {
        Logger.logDetails(msg: "Entered")
    }

    func fillTextFieldText(text: String) {

        if textField.keyboardType == .numberPad  && text.isNumber {
            textField.text = text
            return
        }

        if textField.keyboardType == .decimalPad  && text.isDecimal {
            textField.text = text
            return
        }
        
        textField.text = text
    }
    
    static func showPopup(parentVC: UIViewController,
                          prompt: String,
                          textFieldKeyboardType: UIKeyboardType) -> AlertDialogViewController? {
        //creating a reference for the dialogView controller
        if let popupViewController = UIStoryboard(name: "AlertDialog", bundle: nil).instantiateViewController(withIdentifier: "AlertDialogViewController") as? AlertDialogViewController {
            popupViewController.modalPresentationStyle = .custom
            popupViewController.modalTransitionStyle = .coverVertical
            popupViewController.promptText = prompt
            popupViewController.textFieldKeyboardType = textFieldKeyboardType
            //presenting the pop up viewController from the parent viewController
            parentVC.present(popupViewController, animated: true)
            
            return popupViewController
        }
        
        return nil
    }
}
