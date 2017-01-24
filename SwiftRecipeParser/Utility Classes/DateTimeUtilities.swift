//
//  DateTimeUtilities.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/21/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit

class DateTimeUtilities {
    class func dateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    class func currentTimeToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HHmm"
        return dateFormatter.string(from: Date())
    }
    
    class func timeIntervalToString(_ timeInterval: TimeInterval) -> String {
        return dateToString(Date(timeIntervalSinceReferenceDate: timeInterval))
    }
    
    class func returnStringFromNSDate(_ date: Date?) -> String
    {
        var userVisibleDateTimeString = ""
        
        if date != nil {
            // Convert the date object to a user-visible date string.
            let userVisibleDateFormatter = DateFormatter()
            userVisibleDateFormatter.dateStyle = .short
            userVisibleDateFormatter.timeStyle = .short
            
            userVisibleDateTimeString = userVisibleDateFormatter.string(from: date!)
        }
        
        return userVisibleDateTimeString
    }
    
    class func durationToMinutesString(_ duration: Double) -> String {
        let minutes = floor(duration / 60.0)
        return String(format: "%.0f", minutes)
    }
    
    class func durationToMinutesAndSecondsString(_ duration: Double) -> String {
        let seconds = floor(duration.truncatingRemainder(dividingBy: 60.0))
        let minutes = floor(duration / 60.0)
        return String(format: "%.0f:%02.0f", minutes, seconds)
    }
    
    class func returnNowTimeInterval() -> TimeInterval {
        let nowDate = Date()
        return nowDate.timeIntervalSinceReferenceDate
    }
}
