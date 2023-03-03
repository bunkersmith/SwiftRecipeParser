//
//  ProcessTextFile.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 9/28/15.
//  Copyright © 2015 CarlSmith. All rights reserved.
//

import UIKit

class ProcessTextFile: NSObject {
    
    fileprivate var _fileName:String!
    fileprivate var _fileContent:String!
    fileprivate var _allLines:[String]!
    
    init(fileName: String) {
        super.init()
        _fileName = fileName
    }
    
    func write(string: String) {
        let filename = FileUtilities.applicationDocumentsDirectory().appendingPathComponent(_fileName)

        do {
            try string.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
        }
    }
    
    func open() -> Bool
    {
        _allLines = []
   
        do {
            try _fileContent = String(contentsOfFile:_fileName, encoding:String.Encoding.utf8)
        } catch let error as NSError {
            Logger.logDetails(msg: "Error reading file named \(String(describing: _fileName)): \(error)")
            return false
        }
        
        let allLinesIncludingBlankOnes:[String] = _fileContent.components(separatedBy: NSCharacterSet.newlines)
        
        for line in allLinesIncludingBlankOnes {
            if line != "" {
                _allLines.append(line)
            }
        }
        return true
    }
    
    func lineAtIndex(index: NSInteger) -> String {
        var returnValue:String
    
        if index < _allLines.count {
            returnValue = _allLines[index]
        }
        else {
            returnValue = ""
        }
        
        return returnValue
    }
    
    func linesInFile() -> [String]
    {
        return _allLines
    }

}
