//
//  CheckBox.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 5/15/21.
//  Copyright © 2021 CarlSmith. All rights reserved.
//

import UIKit

class CheckBox: UIButton {
    // Images
    let checkedImage = UIImage(named: "ic_check_box_checked")! as UIImage
    let uncheckedImage = UIImage(named: "ic_check_box_unchecked")! as UIImage
    
    // Bool property
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                self.setImage(checkedImage, for: UIControl.State.normal)
            } else {
                self.setImage(uncheckedImage, for: UIControl.State.normal)
            }
        }
    }
        
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.isChecked = false
    }
        
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
            NotificationCenter.default.post(name: NSNotification.Name("SwiftRecipeParser.groceryListCheckBoxNotification"), object: self)
        }
    }
}
