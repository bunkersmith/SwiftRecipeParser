//
//  EmailViewController.swift
//  Swift Music Player
//
//  Created by CarlSmith on 10/11/15.
//  Copyright © 2015 CarlSmith. All rights reserved.
//

import UIKit
import MessageUI

class EmailViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    var composeMailViewControllerRequested:Bool = false
    var composeMailViewController:MFMailComposeViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (composeMailViewControllerRequested) {
            composeMailViewControllerRequested = false
            showMailComposeViewController()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if composeMailViewController != nil {
            composeMailViewController!.dismiss(animated: true, completion: { () -> Void in
                let resultString = ObjectToStringUtilities.mfMailComposeResultToString(result)
                IToast().showToast(self, alertTitle: "SwiftRecipeParser Alert", alertMessage: resultString, duration: 2) { () -> () in
                    if self.navigationController != nil {
                        self.navigationController!.popViewController(animated: true)
                    }
                }
            })
        }
    }
    
    func showMailComposeViewController() {
        // Check that the current device can send email messages before
        // attempting to create an instance of MFMailComposeViewController.
        if (MFMailComposeViewController.canSendMail()) { // The device can send email.
            composeMailViewController = configureMailComposeViewController()
            if composeMailViewController != nil {
                self.present(composeMailViewController!, animated: true, completion: nil)
            }
        }
        else { // The device can not send email.
            AlertUtilities.showOkButtonAlert(self, title: "Swift Music Player Alert", message: "Device not configured to send mail.", buttonHandler: { (action: UIAlertAction) -> Void in
                guard let navController = self.navigationController else {
                    return
                }
                navController.popViewController(animated: true)
            })
        }
    }
    
    func configureMailComposeViewController() -> MFMailComposeViewController?
    {
        return nil
    }

}
