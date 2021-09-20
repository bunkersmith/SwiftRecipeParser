//
//  IToast.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 8/21/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import UIKit

class IToast: NSObject {
    
    var toast: UIAlertController = UIAlertController()
    var timer:Timer = Timer()
    var completionHandler: () -> (Void) = {}
    
    func showToast(_ viewController: UIViewController, alertTitle:String, alertMessage:String, duration:TimeInterval, completionHandler: (() -> Void)?)
    {
        if completionHandler != nil {
            self.completionHandler = completionHandler!
        }
        
        //[Logger writeToLogFile:[NSString stringWithFormat:@"%s called", __PRETTY_FUNCTION__]]
        
        toast = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        viewController.present(toast, animated: true, completion: nil)
        
        timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(IToast.cancelToast(timer:)), userInfo: nil, repeats: false)
    }
    
    @objc func cancelToast( timer: Timer )
    {
        //[Logger writeToLogFile:[NSString stringWithFormat:@"%s called", __PRETTY_FUNCTION__]]
        
        toast.dismiss(animated: true)
        
        self.completionHandler()
    }
    
}
