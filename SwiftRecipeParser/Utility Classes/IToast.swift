//
//  IToast.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 8/21/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import UIKit

class IToast: NSObject, UIAlertViewDelegate {
    
    var toast: UIAlertView = UIAlertView()
    var timer:Timer = Timer()
    var completionHandler: () -> (Void) = {}
    
    func showToast(alertTitle:String, alertMessage:String, duration:TimeInterval, completionHandler: @escaping (() -> Void))
    {
        self.completionHandler = completionHandler;
        
        //[Logger writeToLogFile:[NSString stringWithFormat:@"%s called", __PRETTY_FUNCTION__]];
        
        toast = UIAlertView(title: alertTitle, message: alertMessage, delegate: self, cancelButtonTitle: "")
        toast.show()
        
        timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(IToast.cancelToast(timer:)), userInfo: nil, repeats: false)
    }
    
    func cancelToast( timer: Timer )
    {
        //[Logger writeToLogFile:[NSString stringWithFormat:@"%s called", __PRETTY_FUNCTION__]];
        
        toast.dismiss(withClickedButtonIndex: 0, animated: true)
        
        self.completionHandler()
    }
    
}
