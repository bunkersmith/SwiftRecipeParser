//
//  StringExtensions.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/19/21.
//  Copyright © 2021 CarlSmith. All rights reserved.
//

import Foundation

extension String {
    var isNumber: Bool {
        let characters = CharacterSet.decimalDigits.inverted
        return !self.isEmpty && rangeOfCharacter(from: characters) == nil
    }
    
    var isDecimal: Bool {
        let characters = CharacterSet.decimalDigits.union(CharacterSet (charactersIn: ".")).inverted
        return !self.isEmpty && rangeOfCharacter(from: characters) == nil
    }
}
