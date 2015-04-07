//
//  ParseRecipe.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/27/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import Foundation

class ParseRecipe {
    
    class func replaceString(stringToReplace:NSString, inputString:NSString, replacementString:NSString) -> NSString {
        var components:NSArray = inputString.componentsSeparatedByString(stringToReplace)
        
        return components.componentsJoinedByString(replacementString);
    }
    
    class func textBetweenStrings(inputString:NSString, startString:NSString, endString:NSString, keepStrings:Bool) -> Array<NSString> {
        var returnValue:Array<NSString> = Array()
        var returnString:NSString
        
        var error:NSError?
        var stringToFind:String = "\(startString).*?\(endString)"
        var regex:NSRegularExpression = NSRegularExpression(pattern: stringToFind, options: NSRegularExpressionOptions.DotMatchesLineSeparators|NSRegularExpressionOptions.CaseInsensitive, error: &error)!
        
        var matches:Array<NSTextCheckingResult>
        var entireStringRange:NSRange = NSMakeRange(0, inputString.length-1)
        
        //NSLog("entireStringRange = \(entireStringRange)")
        //NSLog("inputString = \(inputString)")
        
        matches = regex.matchesInString(inputString, options: nil, range: entireStringRange) as Array<NSTextCheckingResult>
        
        if matches.count == 0
        {
            returnValue.append("")
        }
        else {
            var match:NSTextCheckingResult
            var rangeToReturn:NSRange = NSMakeRange(0, 0)
            
            for i in 0 ..< matches.count {
                match = matches[i]
                
                if keepStrings {
                    returnString = inputString.substringWithRange(match.range)
                }
                else {
                    rangeToReturn.location = match.range.location + startString.length
                    rangeToReturn.length = match.range.length - startString.length - endString.length
                    
                    returnString = inputString.substringWithRange(rangeToReturn)
                }
                
                returnValue.append(returnString)
            }
        }
        
        return returnValue
    }
    //(NSArray *): (NSString *)inputString forStartString: (NSString *) startString andEndString: (NSString *) endString andKeepStrings: (BOOL)keepStrings
    
}