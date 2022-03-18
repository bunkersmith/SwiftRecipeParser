//
//  CGSize+Helpers.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 8/29/17.
//  Copyright © 2017 CarlSmith. All rights reserved.
//

import UIKit

extension CGSize {

    func resizeFill(toSize: CGSize) -> CGSize {
        
        let scale : CGFloat = (self.height / self.width) < (toSize.height / toSize.width) ? (self.height / toSize.height) : (self.width / toSize.width)
        return CGSize(width: (self.width / scale), height: (self.height / scale))
        
    }
}
