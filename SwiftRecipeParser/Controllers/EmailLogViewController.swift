//
//  EmailLogViewController.swift
//  Swift Music Player
//
//  Created by CarlSmith on 7/1/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit
import MessageUI

class EmailLogViewController: EmailViewController {

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
        returnValue.setSubject("SwiftRecipeParser Log File")
        returnValue.setToRecipients(["carl@afterburnerimages.com"])
        Logger.writeLogFileToDisk()
        // Attach the log file to the email
        if let loggerFileData = Logger.returnLogFileAsNSData() {
            returnValue.addAttachmentData(loggerFileData as Data, mimeType: "text", fileName: FileUtilities.timeStampedLogFileName())
            let currentTimeString:String = DateTimeUtilities.returnStringFromNSDate(Date())
            
            // Fill out the email body text
            let emailBody = "SwiftRecipeParser Log sent at " + currentTimeString
            returnValue.setMessageBody(emailBody, isHTML: false)
            return returnValue
        }
        else {
            Logger.writeToLogFile("displayMailComposerSheet could not convert log file to NSData")
            return nil
        }
    }

    // MARK: - MFMailComposeViewControllerDelegate
    
    override func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        Logger.logDetails(msg: "Entered with result: \(result.rawValue), error: \(String(describing: error))")
        
        if result == .sent && error == nil {
            Logger.logDetails(msg: "Safe to delete log file and messages")
            Logger.deleteAll()
        }
        
        super.mailComposeController(controller, didFinishWith: result, error: error)
    }
}
