//
//  TextMessageViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 4/16/21.
//  Copyright © 2021 CarlSmith. All rights reserved.
//

import UIKit
import MessageUI

protocol TextMessageViewControllerDelegate: class {
    func returnMessageBody() -> String
}

class TextMessageViewController: UIViewController, MFMessageComposeViewControllerDelegate {

    var composeMessageViewControllerRequested:Bool = false
    var composeTextViewController = MFMessageComposeViewController()

    weak var delegate: TextMessageViewControllerDelegate? = nil
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector:  #selector(handleExitTextMessageNotification(notification:)), name: Notification.Name(rawValue:"SwiftRecipeParser.exitTextMessageScreenNotification"), object: nil)
        
        if composeMessageViewControllerRequested {
            composeMessageViewControllerRequested = false
            showMessageComposeViewController()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.isOpaque = false
        view.backgroundColor = .clear
    }
    
    func requestMessageComposeViewController() {
        composeMessageViewControllerRequested = true
    }
    
    @objc func handleExitTextMessageNotification(notification:NSNotification) {
        NotificationCenter.default.removeObserver(self)
        
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func popViewController(sender:AnyObject) {
        guard let navigationController = navigationController else {
            return
        }
        let _ = navigationController.popViewController(animated: true)
    }

    func showMessageComposeViewController() {
        
        guard MFMessageComposeViewController.canSendText() else {
            // The device can not send email.
            AlertUtilities.showOkButtonAlert(composeTextViewController, title: "SwiftRecipeParserAlert", message: "Device not configured to send texts.") { (action) in
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        composeTextViewController.messageComposeDelegate = self
        
        // Configure the fields of the interface.
        composeTextViewController.recipients = ["6199805815"]
        
        // If the delegate is non-nil, have it return the message body
        // Otherwise, make the message body an empty string
        composeTextViewController.body = delegate != nil ? delegate?.returnMessageBody() : ""
        
        // Present the view controller modally.
        self.present(composeTextViewController, animated: true, completion: nil)
    }
    
    // MARK - MFMessageComposeViewControllerDelegate
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        composeTextViewController.dismiss(animated: true, completion: { () -> Void in
            let resultString = ObjectToStringUtilities.mfMessageComposeResultToString(result)
            IToast().showToast(self, alertTitle: "SwiftRecipeParser Alert", alertMessage: resultString, duration: 2) { () -> () in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SwiftRecipeParser.exitTextMessageScreenNotification"), object:self)
            }
        })
    }

}
