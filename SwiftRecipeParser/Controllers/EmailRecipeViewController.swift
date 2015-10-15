//
//  EmailRecipeViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 8/21/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import UIKit
import MessageUI

class EmailRecipeViewController: UIViewController, MFMailComposeViewControllerDelegate, UIAlertViewDelegate {

    var alertView:UIAlertView = UIAlertView()
    var composeViewController:MFMailComposeViewController = MFMailComposeViewController()
    var composeMailViewControllerRequested:Bool = false
    var emailRecipeTitle:String = ""
    var emailBody:String = ""
    var resultToast:IToast?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:  Selector("handleExitEmailLogNotification:"), name: "exitEmailLogScreenNotification", object: nil)
        
        if composeMailViewControllerRequested {
            composeMailViewControllerRequested = false
            showMailComposeViewController()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initRecipeTitle(recipeTitle:NSString) {
        emailRecipeTitle = recipeTitle as String;
    }
    
    func handleExitEmailLogNotification(notification:NSNotification) {
        dispatch_async(dispatch_get_main_queue(), {
            self.popViewController(self)
        })
    }
    
    func popViewController(sender:AnyObject) {
        navigationController!.popViewControllerAnimated(true)
    }
    
    func requestMailComposeViewController() {
        composeMailViewControllerRequested = true
    }
    
    func showMailComposeViewController() {
        // Check that the current device can send email messages before
        // attempting to create an instance of MFMailComposeViewController.
        if MFMailComposeViewController.canSendMail() {
            // The device can send email.
            displayMailComposerSheet()
        }
        else {
            // The device can not send email.
            alertView = UIAlertView(title: "SwiftRecipeParserAlert", message:"Device not configured to send mail.", delegate: self, cancelButtonTitle: "OK")
            alertView.show()
        }
    }
    
    
    func displayMailComposerSheet() {
        composeViewController.mailComposeDelegate = self
        
        composeViewController.setSubject("SwiftRecipeParser \(emailRecipeTitle) Recipe")
        
        // Fill out the email body text
        emailBody = RecipeUtilities.convertRecipeNameToFormattedText(emailRecipeTitle)
        composeViewController.setMessageBody(emailBody, isHTML: false)
        
        presentViewController(composeViewController, animated: false, completion: nil)
    }
    
    // MARK - MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        var resultString:String
        let toastDuration:NSTimeInterval = 2.0
        
        switch result.rawValue {
            case MFMailComposeResultCancelled.rawValue:
                resultString = "Result: Mail sending canceled"
            break
            
            case MFMailComposeResultSaved.rawValue:
                resultString = "Result: Mail saved"
            break
            
            case MFMailComposeResultSent.rawValue:
                resultString = "Result: Mail sent"
            break
            
            case MFMailComposeResultFailed.rawValue:
                resultString = "Result: Mail sending failed"
            break
            
            default:
                resultString = "Result: Mail not sent"
            break
        }
        
        dismissViewControllerAnimated(false, completion: {})
        
        resultToast = IToast()
        if resultToast != nil {
            resultToast!.showToast("SwiftRecipeParser Alert", alertMessage:resultString, duration:toastDuration, completionHandler: {
                NSNotificationCenter.defaultCenter().postNotificationName("exitEmailLogScreenNotification", object:self)
            })
        }
    }
    
    // MARK: - UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        navigationController!.popViewControllerAnimated(false)
    }
}
