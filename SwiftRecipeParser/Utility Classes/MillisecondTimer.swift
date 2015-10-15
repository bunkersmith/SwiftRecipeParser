//
//  MillisecondTimer.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 6/10/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit

class MillisecondTimer {
    class func currentTickCount() -> UInt64 {
        var sTimebaseInfo:mach_timebase_info_data_t = mach_timebase_info(numer:0, denom:0)
        mach_timebase_info(&sTimebaseInfo)
        
        let machineTime:UInt64 = mach_absolute_time()
        
        return (machineTime * UInt64(sTimebaseInfo.numer) / 1000000) / UInt64(sTimebaseInfo.denom)
    }
    
    class func secondsSince(startTime: UInt64) -> Double {
        let stopTime = currentTickCount()
        return Double(stopTime - startTime) / 1000.0
    }
}
