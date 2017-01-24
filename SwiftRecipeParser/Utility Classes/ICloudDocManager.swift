//
//  ICloudDocManager.swift
//  Swift 3 Music Player
//
//  Created by CarlSmith on 1/15/17.
//  Copyright © 2017 CarlSmith. All rights reserved.
//

import UIKit

class ICloudDocManager: NSObject {
    
    // Singleton instance
    static let instance = ICloudDocManager()
    
    var iCloudContainerURL:URL? = nil
    
    func retrieveICloudContainerURL() {
        DispatchQueue.global().async {
            let ubiq = FileManager.default.url(forUbiquityContainerIdentifier: nil)
            
            DispatchQueue.main.async {
                if ubiq == nil {
                    Logger.logDetails(msg:"No iCloud access")
                } else {
                    Logger.logDetails(msg:"iCloud access at \(ubiq!.absoluteString.removingPercentEncoding!)")
                    self.iCloudContainerURL = ubiq;
                }
            }
        }
    }

}
