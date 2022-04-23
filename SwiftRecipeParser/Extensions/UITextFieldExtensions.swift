//
//  UITextFieldExtensions.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/18/21.
//  Copyright © 2021 CarlSmith. All rights reserved.
//

import UIKit

extension UITextField {
    
    func addLeadingButton(title: String?, image: UIImage?, target: Any?, selector: Selector) {
        addButton(title: title, image: image, target: target, selector: selector, isLeading: true)
    }
    
    func addTrailingButton(title: String?, image: UIImage?, target: Any?, selector: Selector) {
        addButton(title: title, image: image, target: target, selector: selector, isLeading: false)
    }
    
    fileprivate func addButton(title: String?, image: UIImage?, target: Any?, selector: Selector, isLeading: Bool) {
        
        guard title == nil || image == nil else {
            print("Error: a text field button cannot have both a title and an image")
            return
        }
        
        let toolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolbar.barStyle = .default

        var button:UIBarButtonItem
        
        if title != nil {
            button = UIBarButtonItem(title: title, style: .plain, target: target, action: selector)
        } else {
            button = UIBarButtonItem(image: UIImage(named: "ic_mic"), style: .plain, target: target, action: selector)
        }
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.items = isLeading ? [button, flexSpace] : [flexSpace, button]
        
        toolbar.sizeToFit()
        
        inputAccessoryView = toolbar
    }
    
    func safeFill(newText: String) {

        if keyboardType == .numberPad  && newText.isNumber {
            text = newText
            return
        }

        if keyboardType == .decimalPad  && newText.isDecimal {
            text = newText
            return
        }
        
        text = newText
    }
    
    func priceTextField(_ textField: UITextField,
                        shouldChangeCharactersIn range: NSRange,
                        replacementString string: String) -> Bool {
        
        if let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) {
            if let periodPosition = updatedString.firstIndex(of: ".") {
                let periodString = updatedString[periodPosition...]
                // THE STRING CAN HAVE UP TO THREE CHARACTERS, BECAUSE IT INCLUDES THE PERIOD
                if periodString.lengthOfBytes(using: .utf8) > 3 {
                    return false
                }
            }
        }
        return true
    }
}
