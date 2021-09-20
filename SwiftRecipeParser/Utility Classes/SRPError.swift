
//
//  SRPError.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 8/30/17.
//  Copyright © 2017 CarlSmith. All rights reserved.
//

import UIKit

public enum SRPError: Int, Error {
    case jpegError
    case thumbnailError
    case jpegDeletionError
    case thumbnailDeletionError
    case coreDataError
}

extension SRPError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .jpegError:
                return NSLocalizedString("Error creating photo JPEG.", comment: "Photo error")
        case .thumbnailError:
            return NSLocalizedString("Error creating thumbnail JPEG.", comment: "Photo error")
        case .jpegDeletionError:
            return NSLocalizedString("Error deleting photo JPEG.", comment: "Photo error")
        case .thumbnailDeletionError:
            return NSLocalizedString("Error deleting thumbnail JPEG.", comment: "Photo error")
        case .coreDataError:
            return NSLocalizedString("Error saving to core data.", comment: "Core Data error")
        }
    }
}
