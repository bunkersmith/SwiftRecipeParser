//
//  FloatExtensions.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/20/21.
//  Copyright © 2021 CarlSmith. All rights reserved.
//

import Foundation

extension Float {
    
// Returns a String for a Float, with either zero or two digits of precision, as appropriate
    
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(format: "%.2f", self)
    }
}
