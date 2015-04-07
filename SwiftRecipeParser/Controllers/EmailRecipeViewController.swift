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
        emailRecipeTitle = recipeTitle;
    }
    
    func handleExitEmailLogNotification(notification:NSNotification) {
        //[Logger writeToLogFile:[NSString stringWithFormat:@"%s called", __PRETTY_FUNCTION__]];
    
        dispatch_async(dispatch_get_main_queue(), {
            self.popViewController(self)
        })
    }
    
    func popViewController(sender:AnyObject) {
        navigationController.popViewControllerAnimated(true)
    }
    
    func requestMailComposeViewController() {
        composeMailViewControllerRequested = true
    }
    
    func showMailComposeViewController() {
        // You must check that the current device can send email messages before you
        // attempt to create an instance of MFMailComposeViewController.  If the
        // device can not send email messages,
        // [[MFMailComposeViewController alloc] init] will return nil.  Your app
        // will crash when it calls -presentViewController:animated:completion: with
        // a nil view controller.
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
        //[Logger writeToLogFile:[NSString stringWithFormat:@"%s called", __PRETTY_FUNCTION__]];
        
        if composeViewController != nil {
            composeViewController.mailComposeDelegate = self
            
            composeViewController.setSubject("SwiftRecipeParser \(emailRecipeTitle) Recipe")
            
            // Fill out the email body text
            emailBody = RecipeUtilities.convertRecipeNameToFormattedText(emailRecipeTitle)
            composeViewController.setMessageBody(emailBody, isHTML: false)
            
            presentViewController(composeViewController, animated: false, completion: nil)
        }
    }
    
    // MARK - MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        var resultString:String
        let toastDuration:NSTimeInterval = 2.0
        
        switch result.value {
            case MFMailComposeResultCancelled.value:
                resultString = "Result: Mail sending canceled"
            break
            
            case MFMailComposeResultSaved.value:
                resultString = "Result: Mail saved"
            break
            
            case MFMailComposeResultSent.value:
                resultString = "Result: Mail sent"
            break
            
            case MFMailComposeResultFailed.value:
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int) {
        navigationController.popViewControllerAnimated(false)
    }
}
