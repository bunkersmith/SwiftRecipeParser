//
//  UIImage+Helpers.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 8/29/17.
//  Copyright © 2017 CarlSmith. All rights reserved.
//

import UIKit

extension UIImage {

    func scale(toSize newSize:CGSize) -> UIImage {
        
        // make sure the new size has the correct aspect ratio
        let aspectFill = self.size.resizeFill(toSize: newSize)
        
        UIGraphicsBeginImageContextWithOptions(aspectFill, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: aspectFill.width, height: aspectFill.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }

}
