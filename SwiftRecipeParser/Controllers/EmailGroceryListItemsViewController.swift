//
//  EmailGroceryListItemsViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 11/24/22.
//  Copyright © 2022 CarlSmith. All rights reserved.
//

import UIKit
import MessageUI

class EmailGroceryListItemsViewController: EmailViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func requestMailComposeViewController() {
        composeMailViewControllerRequested = true
    }

    override func configureMailComposeViewController() -> MFMailComposeViewController?
    {
        let returnValue = MFMailComposeViewController()
        returnValue.mailComposeDelegate = self
        returnValue.setSubject("SwiftRecipeParser Grocery List Items File")
        returnValue.setToRecipients(["carl@afterburnerimages.com"])
        
        if let groceryItemsData = GroceryListItem.allItemsToData() {
            returnValue.addAttachmentData(groceryItemsData, mimeType: "text", fileName: FileUtilities.timeStampedGroceryListItemsFileName())
        
            let currentTimeString:String = DateTimeUtilities.returnStringFromNSDate(Date())
            
            // Fill out the email body text
            let emailBody = "SwiftRecipeParser Grocery List Items sent at " + currentTimeString
            returnValue.setMessageBody(emailBody, isHTML: false)
            return returnValue
        }
        else {
            Logger.writeToLogFile("displayMailComposerSheet could not convert Grocery List Items to NSData")
            return nil
        }
    }

    // MARK: - MFMailComposeViewControllerDelegate
    
    override func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        Logger.logDetails(msg: "Entered with result: \(result.rawValue), error: \(String(describing: error))")
        
//        if result == .sent && error == nil {
//            Logger.logDetails(msg: "Safe to delete log file and messages")
//            Logger.deleteAll()
//        }
        
        super.mailComposeController(controller, didFinishWith: result, error: error)
    }
}
