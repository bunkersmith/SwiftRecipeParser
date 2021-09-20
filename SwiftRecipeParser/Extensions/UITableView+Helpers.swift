//
//  UITableView+Helpers.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 5/16/21.
//  Copyright © 2021 CarlSmith. All rights reserved.
//

import UIKit

extension UITableView {
    
    func getAllIndexes() -> [IndexPath] {
        
        var indices = [IndexPath]()
        let sections = self.numberOfSections
        
        if sections > 0{
            for s in 0...sections - 1 {
                let rows = self.numberOfRows(inSection: s)
                if rows > 0{
                    for r in 0...rows - 1{
                        let index = IndexPath(row: r, section: s)
                        indices.append(index)
                    }
                }
            }
        }
        
        return indices
    }
}
