//
//  Logger.swift
//  Swift Music Player
//
//  Created by CarlSmith on 6/9/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit

class Logger: NSObject, NSCoding {

    static let maxLogMessageCount = 10000
    
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
                let decodedDataObject = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(dat as Data)
                
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
        Logger.commonMemoryLogger(string, withTimeStamp:true)
    }
    
    class func writeToLogFileSpecial(_ string: String) {
        Logger.commonMemoryLogger(string, withTimeStamp:true)
    }
    
    class func commonMemoryLogger(_ stringToWrite: String, withTimeStamp: Bool) {
        NSLog(stringToWrite)
    
        var logString = ""
    
        if withTimeStamp {
            logString = logString + DateTimeUtilities.dateToString(Date()) + ": "
        }
    
        logString = logString + stringToWrite
        
        // Insure that the Log file doesn't grow to infinte size
        if Logger.instance.logMessages.count > maxLogMessageCount {
            Logger.instance.logMessages.removeFirst()
        }

        Logger.instance.logMessages.append(logString)
    }
    
    class func writeSeparatorToLogFile() {
    Logger.commonMemoryLogger("#################################################################################################################################################", withTimeStamp:false)
    }
    
    class func writeLogFileToDisk() {
        deleteFile()
    
        let logFilePath = FileUtilities.logFilePath()
        
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
        Logger.commonMemoryLogger("\(makeTag(function: function, file: file, line: line)) : \(msg)", withTimeStamp: true)
    }
    
    private class func makeTag(function: String, file: String, line: Int) -> String{
        let url = NSURL(fileURLWithPath: file)
        let className = url.lastPathComponent ?? file
        return "\(className) \(function)[\(line)]"
    }
    
    class func deleteFile() {
        let logFilePath = FileUtilities.logFilePath()
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: logFilePath) {
            do {
                try fileManager.removeItem(atPath: logFilePath)
            } catch let error as NSError {
                NSLog("Error deleting log file (at path \(logFilePath)): \(error)")
            }
        }
    }
    
    class func deleteAll() {
        Logger.instance.logMessages = []
        
        deleteFile()
    }
}
