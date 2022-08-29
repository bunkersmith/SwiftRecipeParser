//
//  UIBarButtonExtensions.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 8/28/22.
//  Copyright © 2022 CarlSmith. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    
    func show(_ show: Bool) {
        if show {
            tintColor = nil
            isEnabled = true
        } else {
            tintColor = .clear
            isEnabled = false
        }
    }
}
