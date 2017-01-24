//
//  TextDoc.swift
//  Swift 3 Music Player
//
//  Created by CarlSmith on 12/31/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit

class TextDoc: UIDocument {
    
    var docText: String? = ""
    
    // Called whenever the application reads data from the file system
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let content = contents as? Data {
            Logger.logDetails(msg: "Length of contents = \(content.count)")
            if content.count > 0 {
                docText = String(data: content, encoding: .utf8)
            }
        }
    }

    override func contents(forType typeName: String) throws -> Any {
        //Logger.logDetails(msg: "docText = \(docText)")
        if let content = docText {
            //Logger.logDetails(msg: "content = \(content)")
            let length =
                content.lengthOfBytes(using: String.Encoding.utf8)
            Logger.logDetails(msg: "Length of docText = \(length)")
            if length > 0 {
                return content.data(using: .utf8) as Any
            }
        }
        
        return Data()
    }
    
}
