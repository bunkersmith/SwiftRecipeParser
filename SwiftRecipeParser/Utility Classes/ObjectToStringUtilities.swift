//
//  ObjectToStringUtilities.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/21/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer
import MessageUI

class ObjectToStringUtilities {
    class func imageOrientationToString(_ orientation:UIImageOrientation) -> String {
        switch (orientation) {
        case .down:
            return "UIImageOrientationDown";
            
        case .downMirrored:
            return "UIImageOrientationDownMirrored";
            
        case .left:
            return "UIImageOrientationLeft";
            
        case .leftMirrored:
            return "UIImageOrientationLeftMirrored";
            
        case .right:
            return "UIImageOrientationRight";
            
        case .rightMirrored:
            return "UIImageOrientationRigheMirrored";
            
        case .up:
            return "UIImageOrientationUp";
            
        case .upMirrored:
            return "UIImageOrientationUpMirrored";
        }
    }
    
    class func stringFromCGSize(_ size: CGSize) -> String {
        return String(format: "%.2f, %.2f", size.width, size.height)
    }
    
    class func stringFromCGPoint(_ point: CGPoint) -> String {
        return String(format: "%.2f, %.2f", point.x, point.y)
    }
    
    class func stringFromCGRect(_ rect: CGRect) -> String {
        let returnValue = String(format: "origin = %.2f, %.2f", rect.origin.x, rect.origin.y)
        return returnValue + String(format: "\nsize = %.2f, %.2f", rect.size.width, rect.size.height)
    }
    
    class func eventTypeToString(_ eventType: UIEventType) -> String
    {
        var returnValue = ""
        
        switch (eventType)
        {
        case .touches:
            returnValue = "UIEventTypeTouches"
            break
            
        case .motion:
            returnValue = "UIEventTypeMotion"
            break
            
        case .remoteControl:
            returnValue = "UIEventTypeRemoteControl"
            break
            
        default:
            returnValue = "Unknown"
            break
        }
        
        return returnValue
    }
    
    class func eventSubtypeToString(_ eventSubtype: UIEventSubtype) -> String
    {
        var returnValue = ""
        
        switch (eventSubtype)
        {
        case .none:
            returnValue = "UIEventSubtypeNone"
            break
            
        case .motionShake:
            returnValue = "UIEventSubtypeMotionShake"
            break
            
        case .remoteControlPlay:
            returnValue = "UIEventSubtypeRemoteControlPlay"
            break
            
        case .remoteControlPause:
            returnValue = "UIEventSubtypeRemoteControlPause"
            break
            
        case .remoteControlStop:
            returnValue = "UIEventSubtypeRemoteControlStop"
            break
            
        case .remoteControlTogglePlayPause:
            returnValue = "UIEventSubtypeRemoteControlTogglePlayPause"
            break
            
        case .remoteControlNextTrack:
            returnValue = "UIEventSubtypeRemoteControlNextTrack"
            break
            
        case .remoteControlPreviousTrack:
            returnValue = "UIEventSubtypeRemoteControlPreviousTrack"
            break
            
        case .remoteControlBeginSeekingBackward:
            returnValue = "UIEventSubtypeRemoteControlBeginSeekingBackward"
            break
            
        case .remoteControlEndSeekingBackward:
            returnValue = "UIEventSubtypeRemoteControlEndSeekingBackward"
            break
            
        case .remoteControlBeginSeekingForward:
            returnValue = "UIEventSubtypeRemoteControlBeginSeekingForward"
            break
            
        case .remoteControlEndSeekingForward:
            returnValue = "UIEventSubtypeRemoteControlEndSeekingForward"
            break
        }
        
        return returnValue
    }
    
    class func fetchedResultsChangeTypeToString(_ fetchedResultsChangeType: NSFetchedResultsChangeType) -> String {
        var returnValue = ""
        
        switch (fetchedResultsChangeType) {
        case .insert:
            returnValue = "NSFetchedResultsChangeInsert"
            break
        case .delete:
            returnValue = "NSFetchedResultsChangeDelete"
            break
        case .move:
            returnValue = "NSFetchedResultsChangeMove"
            break
        case .update:
            returnValue = "NSFetchedResultsChangeUpdate"
            break
        }
        
        return returnValue
    }
    
    class func mfMailComposeResultToString(_ result: MFMailComposeResult) -> String {
        var resultString:String
        switch (result.rawValue) {
        case MFMailComposeResult.cancelled.rawValue:
            resultString = "Result: Mail sending cancelled"
            break
        case MFMailComposeResult.saved.rawValue:
            resultString = "Result: Mail saved"
            break
        case MFMailComposeResult.sent.rawValue:
            resultString = "Result: Mail sent"
            break
        case MFMailComposeResult.failed.rawValue:
            resultString = "Result: Mail sending failed"
            break
        default:
            resultString = "Result: Unknown (mail not sent)"
            break
        }
        return resultString
    }
    
    class func mfMessageComposeResultToString(_ result: MessageComposeResult) -> String {
        var resultString:String
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            resultString = "Result: Text sending cancelled"
            break
        case MessageComposeResult.sent.rawValue:
            resultString = "Result: Text sent"
            break
        case MessageComposeResult.failed.rawValue:
            resultString = "Result: Text sending failed"
            break
        default:
            resultString = "Result: Unknown (text not sent)"
            break
        }
        return resultString
    }

    class func eventTypeAndSubtypeToString(_ event: UIEvent) -> String {
        return "type = \(eventTypeToString(event.type)) and subtype = \(eventSubtypeToString(event.subtype))"
    }
}
