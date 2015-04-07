//
//  FractionMath.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 8/8/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import Foundation

class FractionMath {
    
//
// Taken from an answer by JPS on Sep 18 '08 at 21:46, and edited Apr 30 '12 at 16:52 by Jon
// on this Stack Overflow thread:
// http://stackoverflow.com/questions/95727/how-to-convert-floats-to-human-readable-fractions

    class func stringToDouble(inputString: String) -> Double {
        var returnValue:Double = -1

        var dashDividedString:Array<String> = inputString.componentsSeparatedByString("-")
        
        if dashDividedString.count == 1 || dashDividedString.count == 2 {
            var fractionString:String
            
            if dashDividedString.count == 1 {
                // The number is either a whole number, or a fraction with no leading whole number
                returnValue = 0;
                fractionString = dashDividedString[0];
            }
            else {
                // The number has both a leading whole number and a fraction
                //NSLog(@"Whole number = %f", [dashDividedString[0] doubleValue]);
                returnValue = NSString(string: dashDividedString[0]).doubleValue
                fractionString = dashDividedString[1]
            }
            
            var slashDividedString:Array<String> = fractionString.componentsSeparatedByString("/")
            
            if slashDividedString.count == 1 || slashDividedString.count == 2 {
                if slashDividedString.count == 1 {
                    // The number has no fractional part
                    //NSLog(@"Whole number = %f", [fractionString doubleValue]);
                    returnValue += NSString(string: fractionString).doubleValue
                }
                else {
                    // The number has a fractional part
                    var numeratorString:NSString = slashDividedString[0];
                    var denominatorString:NSString = slashDividedString[1];
                    
                    //NSLog(@"Fraction value = %f", [numeratorString doubleValue] / [denominatorString doubleValue]);
                    returnValue +=  numeratorString.doubleValue / denominatorString.doubleValue
                }
            }
        }
        
        return returnValue;
    }
        
    class func doubleToString(inputDouble:Double) -> String {
        var rval:String = ""

        if inputDouble == 0.0 {
            return "0";
        }
        
        var workingInputDouble:Double
        
        // TODO: negative numbers:if inputDouble < 0.0)...
        if inputDouble >= 1.0 {
            rval += String(format:"%.0f", floor(inputDouble))
        }
        
        workingInputDouble = inputDouble-floor(inputDouble); // now only the fractional part is left
        
        if workingInputDouble == 0.0 {
            return rval;
        }
        
        if rval != "" {
            rval += "-"
        }
        
        if workingInputDouble < 0.47 {
            if workingInputDouble < 0.25 {
                if workingInputDouble < 0.16 {
                    if workingInputDouble < 0.12 { // Note: fixed from .13
                        if workingInputDouble < 0.11 {
                            rval += "1/10" // .1
                        }
                        else {
                            rval += "1/9" // .1111....
                        }
                    }
                    else { // workingInputDouble >= .12
                        if workingInputDouble < 0.14 {
                            rval += "1/8" // .125
                        }
                        else {
                            rval += "1/7" // .1428...
                        }
                    }
                }
                else { // workingInputDouble >= .16
                    if  workingInputDouble < 0.19 {
                        rval += "1/6" // .1666...
                    }
                    else { // workingInputDouble > .19
                        if workingInputDouble < 0.22 {
                            rval += "1/5" // .2
                        }
                        else {
                            rval += "2/9" // .2222...
                        }
                    }
                }
            }
            else { // workingInputDouble >= .25
                if workingInputDouble < 0.37 { // Note: fixed from .38
                    if workingInputDouble < 0.28 { // Note: fixed from .29
                        rval += "1/4" // .25
                    }
                    else { // workingInputDouble >=.28
                        if workingInputDouble < 0.31 {
                            rval += "2/7" // .2857...
                        }
                        else {
                            rval += "1/3" // .3333...
                        }
                    }
                }
                else { // workingInputDouble >= .37
                    if workingInputDouble < 0.42 { // Note: fixed from .43
                        if workingInputDouble < 0.40 {
                            rval += "3/8" // .375
                        }
                        else {
                            rval += "2/5" // .4
                        }
                    }
                    else { // workingInputDouble >= .42
                        if workingInputDouble < 0.44 {
                            rval += "3/7" // .4285...
                        }
                        else {
                            rval += "4/9" // .4444...
                        }
                    }
                }
            }
        }
        else {
            if workingInputDouble < 0.71 {
                if workingInputDouble < 0.60 {
                    if workingInputDouble < 0.55 { // Note: fixed from .56
                        rval += "1/2" // .5
                    }
                    else { // workingInputDouble >= .55
                        if workingInputDouble < 0.57 {
                            rval += "5/9" // .5555...
                        }
                        else {
                            rval += "4/7" // .5714
                        }
                    }
                }
                else { // workingInputDouble >= .6
                    if workingInputDouble < 0.62 { // Note: Fixed from .63
                        rval += "3/5" // .6
                    }
                    else { // workingInputDouble >= .62
                        if workingInputDouble < 0.66 {
                            rval += "5/8" // .625
                        }
                        else {
                            rval += "2/3" // .6666...
                        }
                    }
                }
            }
            else {
                if workingInputDouble < 0.80 {
                    if workingInputDouble < 0.74 {
                        rval += "5/7" // .7142...
                    }
                    else { // workingInputDouble >= .74
                        if workingInputDouble < 0.77 { // Note: fixed from .78
                            rval += "3/4" // .75
                        }
                        else {
                            rval += "7/9" // .7777...
                        }
                    }
                }
                else { // workingInputDouble >= .8
                    if workingInputDouble < 0.85 { // Note: fixed from .86
                        if workingInputDouble < 0.83 {
                            rval += "4/5" // .8
                        }
                        else {
                            rval += "5/6" // .8333...
                        }
                    }
                    else { // workingInputDouble >= .85
                        if workingInputDouble < 0.87 { // Note: fixed from .88
                            rval += "6/7" // .8571
                        }
                        else { // workingInputDouble >= .87
                            if workingInputDouble < 0.88 { // Note: fixed from .89
                                rval += "7/8" // .875
                            }
                            else { // workingInputDouble >= .88
                                if workingInputDouble < 0.90 {
                                    rval += "8/9" // .8888...
                                }
                                else {
                                    rval += "9/10" // .9
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return rval
    }
}
