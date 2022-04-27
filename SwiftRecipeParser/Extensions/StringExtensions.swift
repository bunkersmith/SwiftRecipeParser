//
//  StringExtensions.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/19/21.
//  Copyright © 2021 CarlSmith. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var isNumber: Bool {
        let characters = CharacterSet.decimalDigits.inverted
        return !self.isEmpty && rangeOfCharacter(from: characters) == nil
    }
    
    var isDecimal: Bool {
        let characters = CharacterSet.decimalDigits.union(CharacterSet (charactersIn: ".")).inverted
        return !self.isEmpty && rangeOfCharacter(from: characters) == nil
    }

    func isValidUrl () -> Bool {
        if let url = URL(string: self) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    func matchesRegex(regexPattern: String) -> Bool {

        let regex = try! NSRegularExpression(pattern: regexPattern,
                                             options: [])

        let matches = regex.matches(in: self, range: NSRange(location: 0 , length: self.count))
        
        return matches.count > 0
    }
}
