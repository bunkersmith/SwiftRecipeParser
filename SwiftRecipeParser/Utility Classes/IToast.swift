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
    var timer:NSTimer = NSTimer()
    var completionHandler: () -> (Void) = {}
    
    func showToast(alertTitle:String, alertMessage:String, duration:NSTimeInterval, completionHandler: (() -> Void))
    {
        self.completionHandler = completionHandler;
        
        //[Logger writeToLogFile:[NSString stringWithFormat:@"%s called", __PRETTY_FUNCTION__]];
        
        toast = UIAlertView(title: alertTitle, message: alertMessage, delegate: self, cancelButtonTitle: "")
        toast.show()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: Selector("cancelToast:"), userInfo: nil, repeats: false)
    }
    
    func cancelToast( timer: NSTimer )
    {
        //[Logger writeToLogFile:[NSString stringWithFormat:@"%s called", __PRETTY_FUNCTION__]];
        
        toast.dismissWithClickedButtonIndex(0, animated: true)
        
        self.completionHandler()
    }
    
}