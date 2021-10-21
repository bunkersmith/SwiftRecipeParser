//
//  ICloudDocWrapper.swift
//  CSmith092459 iCloud TestApp
//
//  Created by CarlSmith on 12/31/16.
//  Copyright © 2016 Carl Smith. All rights reserved.
//

import UIKit

class ICloudDocWrapper: NSObject {
    
    enum DocResult:String {
        case docOpened
        case docCreated
        case docWritten
        case docError
    }
    
    var document: TextDoc?
    var documentURL: URL?

    init(filename: String) {
        super.init()
        
        guard let iCloudContainerURL = ICloudDocManager.instance.iCloudContainerURL else {
            Logger.logDetails(msg: "iCloudContainerURL is nil")
            return
        }
        
        let docsDir = iCloudContainerURL.appendingPathComponent("Documents")
        
        documentURL = docsDir.appendingPathComponent(filename)
        guard let documentURL = documentURL else {
            Logger.logDetails(msg: "documentURL is nil")
            return
        }
        
        document = TextDoc(fileURL: documentURL)
        guard document != nil else {
            Logger.logDetails(msg: "document is nil")
            return
        }
    }
    
    func openTextDoc(completionHandler: @escaping (DocResult) -> ()) {
        Logger.logDetails(msg: "documentURL: \(String(describing: documentURL))")
        
        document?.open(completionHandler: {(success: Bool) -> Void in
            if success {
                completionHandler(.docOpened)
            } else {
                completionHandler(.docError)
            }
        })
    }
    
    func readTextFromDoc(completionHandler: @escaping (DocResult, String?) -> ()) {
        Logger.logDetails(msg: "documentURL: \(String(describing: documentURL))")
        
        openOrCreateDoc { (docResult) in
            if docResult == .docError {
                completionHandler(docResult, nil)
            } else {
                guard let document = self.document else {
                    completionHandler(.docError, nil)
                    return
                }
                
                completionHandler(docResult, document.docText)
            }
        }
    }
    
    func writeTextToDoc(text:String, completionHandler: @escaping (DocResult) -> ()) {
        Logger.logDetails(msg: "documentURL: \(String(describing: documentURL))")
        
        var startTime = MillisecondTimer.currentTickCount()
        
        openOrCreateDoc { (docResult) in
            if docResult == .docError {
                completionHandler(docResult)
            } else {
                guard let document = self.document else {
                    completionHandler(.docError)
                    return
                }
                
                Logger.logDetails(msg: "Document open time: \(MillisecondTimer.secondsSince(startTime: startTime))")
                startTime = MillisecondTimer.currentTickCount()

                document.docText = text
                
                Logger.logDetails(msg: "Text write time: \(MillisecondTimer.secondsSince(startTime: startTime))")
                startTime = MillisecondTimer.currentTickCount()

                self.saveDoc(saveOp: .forOverwriting) { docResult in
                    Logger.logDetails(msg: "Document save time: \(MillisecondTimer.secondsSince(startTime: startTime))")

                    completionHandler(docResult)
                }
             }
        }
    }
    
    func saveDoc(saveOp: UIDocumentSaveOperation, completionHandler: @escaping (DocResult) -> ()) {
        guard let document = document else {
            completionHandler(.docError)
            return
        }
        
        guard let documentURL = documentURL else {
            completionHandler(.docError)
            return
        }
        
        document.save(to: documentURL,
                      for: saveOp,
        completionHandler: {(success: Bool) -> Void in
            if success {
                
                document.close(completionHandler: { (closeSuccess) in
                    if closeSuccess {
                        completionHandler(.docWritten)
                        
                    } else {
                        Logger.logDetails(msg: "Failed to close file ")
                        
                        completionHandler(.docError)
                    }
                })
                
            } else {
                Logger.logDetails(msg: "Failed to save file ")
                
                completionHandler(.docError)
            }
        })
            
    }

    func openOrCreateDoc(completionHandler: @escaping (DocResult) -> ()) {
        
        if (docFileExists()) {
            openTextDoc(completionHandler: { (docResult) in
                completionHandler(docResult)
            })
        } else {
            saveDoc(saveOp: .forCreating, completionHandler: { (docResult) in
                completionHandler(docResult)
            })
        }
    }
    
    func docFileExists() -> Bool {
        
        guard let documentURL = documentURL else {
            return false
        }
        
        let filemgr = FileManager.default
        
        Logger.logDetails(msg: "Returning \(filemgr.fileExists(atPath: documentURL.path))")
        
        return filemgr.fileExists(atPath: documentURL.path)
    }
    
}
