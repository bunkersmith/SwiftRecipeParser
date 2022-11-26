//
//  EmailRecipeViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 8/21/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import UIKit
import MessageUI

class EmailRecipeViewController: UIViewController, MFMailComposeViewControllerDelegate {

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
        
        NotificationCenter.default.addObserver(self, selector:  #selector(EmailRecipeViewController.handleExitEmailRecipeNotification(notification:)), name: Notification.Name(rawValue:"SwiftRecipeParser.exitEmailRecipeScreenNotification"), object: nil)
        
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
    
    @objc func handleExitEmailRecipeNotification(notification:NSNotification) {
        NotificationCenter.default.removeObserver(self)
        
        DispatchQueue.main.async {
            self.composeViewController.dismiss(animated: false, completion: nil)
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func popViewController(sender:AnyObject) {
        guard let navigationController = navigationController else {
            return
        }
        let _ = navigationController.popViewController(animated: true)
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
            AlertUtilities.showOkButtonAlert(self, title: "SwiftRecipeParserAlert", message: "Device not configured to send mail.") { (action) in
                self.composeViewController.dismiss(animated: false, completion: nil)
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    
    func displayMailComposerSheet() {
        composeViewController.mailComposeDelegate = self
        
        composeViewController.setSubject("SwiftRecipeParser \(emailRecipeTitle) Recipe")
        
        // Fill out the email body text
        emailBody = Recipe.convertRecipeNameToFormattedText(emailRecipeTitle)
        composeViewController.setMessageBody(emailBody, isHTML: false)
        
        present(composeViewController, animated: false, completion: nil)
    }
    
    // MARK - MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        let resultString = ObjectToStringUtilities.mfMailComposeResultToString(result)
        
        let toastDuration:TimeInterval = 2.0
        
        dismiss(animated: false, completion: {})
        
        resultToast = IToast()
        if resultToast != nil {
            resultToast!.showToast(controller, alertTitle: "SwiftRecipeParser Alert", alertMessage:resultString, duration:toastDuration, completionHandler: {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SwiftRecipeParser.exitEmailRecipeScreenNotification"), object:self)
            })
        }
    }
}
