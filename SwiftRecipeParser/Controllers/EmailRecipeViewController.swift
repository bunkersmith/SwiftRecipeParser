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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector:  #selector(EmailRecipeViewController.handleExitEmailLogNotification(notification:)), name: Notification.Name(rawValue:"exitEmailLogScreenNotification"), object: nil)
        
        if composeMailViewControllerRequested {
            composeMailViewControllerRequested = false
            showMailComposeViewController()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initRecipeTitle(recipeTitle:String) {
        emailRecipeTitle = recipeTitle;
    }
    
    func handleExitEmailLogNotification(notification:NSNotification) {
        DispatchQueue.main.async {
            self.popViewController(sender: self)
        }
    }
    
    func popViewController(sender:AnyObject) {
        let _ = navigationController!.popViewController(animated: true)
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
        emailBody = RecipeUtilities.convertRecipeNameToFormattedText(recipeName: emailRecipeTitle)
        composeViewController.setMessageBody(emailBody, isHTML: false)
        
        present(composeViewController, animated: false, completion: nil)
    }
    
    // MARK - MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        var resultString:String
        let toastDuration:TimeInterval = 2.0
        
        switch result {
            case .cancelled:
                resultString = "Result: Mail sending canceled"
            break
            
            case .saved:
                resultString = "Result: Mail saved"
            break
            
            case .sent:
                resultString = "Result: Mail sent"
            break
            
            case .failed:
                resultString = "Result: Mail sending failed"
            break

        }
        
        dismiss(animated: false, completion: {})
        
        resultToast = IToast()
        if resultToast != nil {
            resultToast!.showToast(alertTitle: "SwiftRecipeParser Alert", alertMessage:resultString, duration:toastDuration, completionHandler: {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "exitEmailLogScreenNotification"), object:self)
            })
        }
    }
    
    // MARK: - UIAlertViewDelegate
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        navigationController!.popViewController(animated: false)
    }
}
