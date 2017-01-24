//
//  Logger.swift
//  Swift Music Player
//
//  Created by CarlSmith on 6/9/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit

class Logger: NSObject, NSCoding {

    // Singleton instance
    static let instance = Logger.loadInstance()
    
    lazy fileprivate var logMessages:[String] = [String]()
    
    fileprivate override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.logMessages = aDecoder.decodeObject(forKey: "logMessages") as! [String]
    }
 
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.logMessages, forKey:"logMessages")
    }
    
    func archiveData() {
        NSKeyedArchiver.archiveRootObject(self, toFile:FileUtilities.loggerArchiveFilePath())
    }
    
    class func loadInstance() -> Logger
    {
        /*
        if let loggerData:Logger = NSKeyedUnarchiver.unarchiveObject(withFile: FileUtilities.loggerArchiveFilePath()) as? Logger {
            return loggerData
        }
        return Logger()
        */
        
        let archiveFileUrl = URL(fileURLWithPath:FileUtilities.loggerArchiveFilePath())
        
        guard let dat = NSData(contentsOf: archiveFileUrl) else {
            return Logger()
        }
        
        do {
            if #available(iOS 9.0, *) {
                let decodedDataObject = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(dat)
                
                guard let logger = decodedDataObject as? Logger else {
                    return Logger()
                }
                
                return logger
            } else {
                return Logger()
            }
        }
        catch {
            return Logger()
        }
    }
    
    class func writeToLogFile(_ string: String) {
        Logger.commonDiskLogger(string, withTimeStamp:true)
    }
    
    class func writeToLogFileSpecial(_ string: String) {
        Logger.commonDiskLogger(string, withTimeStamp:true)
    }
    
    class func commonMemoryLogger(_ stringToWrite: String, withTimeStamp: Bool) {
        NSLog(stringToWrite)
    
        var logString = ""
    
        if withTimeStamp {
            logString = logString + DateTimeUtilities.dateToString(Date()) + ": "
        }
    
        logString = logString + stringToWrite
        Logger.instance.logMessages.append(logString)
    }
    
    class func commonDiskLogger(_ stringToWrite: String, withTimeStamp: Bool) {
        NSLog(stringToWrite)
    
        let logFilePath = FileUtilities.logFilePath()
        var error:NSError?
        var contents = ""
        
        do {
            let oldContents = try String(contentsOfFile: logFilePath, encoding: String.Encoding.utf8)
            contents = oldContents + "\n"
        } catch let error1 as NSError {
            error = error1
            // Assume that we're writing to the file for the first time
            NSLog(logFilePath)
        }
    
    
        if withTimeStamp {
            contents = contents + DateTimeUtilities.dateToString(Date()) + ": "
        }
    
        contents = contents + stringToWrite
    
        do {
            try contents.write(toFile: logFilePath, atomically: false, encoding: String.Encoding.utf8)
        } catch let error1 as NSError {
            error = error1
            if error != nil {
                NSLog("Error writing to log file (\(logFilePath)): \(error!)")
            }
            else {
                NSLog("Unspedified error writing to log file (\(logFilePath))")
            }
        }
    }
    
    class func writeSeparatorToLogFile() {
    Logger.commonDiskLogger("#################################################################################################################################################", withTimeStamp:false)
    }
    
    class func writeLogFileToDisk() {
        let logFilePath = FileUtilities.logFilePath()
    
        let fileManager = FileManager.default
    
        if fileManager.fileExists(atPath: logFilePath) {
            do {
                try fileManager.removeItem(atPath: logFilePath)
            } catch let error as NSError {
                NSLog("Error deleting log file (at path \(logFilePath)): \(error)")
            }
        }
    
        let joiner = "\n"
        let joinedStrings = Logger.instance.logMessages.joined(separator: joiner)

        do {
            try joinedStrings.write(toFile: logFilePath, atomically:true, encoding:String.Encoding.utf8)
            Logger.instance.logMessages.removeAll(keepingCapacity: false)
        } catch let error as NSError {
            NSLog("Error writing to log file (at path \(logFilePath)): \(error)")
        }
    }
    
    class func returnLogFileAsNSData() -> Data? {
        let logFilePath = FileUtilities.logFilePath()
        return (try? Data(contentsOf: URL(fileURLWithPath: logFilePath)))
    }

    class func logDetails(msg:String, function: String = #function, file: String = #file, line: Int = #line){
        Logger.commonDiskLogger("\(makeTag(function: function, file: file, line: line)) : \(msg)", withTimeStamp: true)
    }
    
    private class func makeTag(function: String, file: String, line: Int) -> String{
        let url = NSURL(fileURLWithPath: file)
        let className = url.lastPathComponent ?? file
        return "\(className) \(function)[\(line)]"
    }
}
