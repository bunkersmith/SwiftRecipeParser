//
//  TextMessageViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 4/16/21.
//  Copyright © 2021 CarlSmith. All rights reserved.
//

import UIKit
import MessageUI

class TextMessageViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    var composeVC: MFMessageComposeViewController!

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        composeVC.dismiss(animated: true, completion: { () -> Void in
            let resultString = ObjectToStringUtilities.mfMessageComposeResultToString(result)
            IToast().showToast(self, alertTitle: "SwiftRecipeParser Alert", alertMessage: resultString, duration: 2, completionHandler: nil)
        })
    }
    
    func sendTextMessage(_ message: String) {
        composeVC = MFMessageComposeViewController()
        
        composeVC.messageComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.recipients = ["6199805815"]
        composeVC.body = message
        
        // Present the view controller modally.
        guard MFMessageComposeViewController.canSendText() else {
            AlertUtilities.showOkButtonAlert(composeVC, title: "SwiftRecipeParserAlert", message: "Device cannot send texts.", buttonHandler: nil)
            return
        }
        self.present(composeVC, animated: false, completion: nil)
        
    }
    
}
