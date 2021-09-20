//
//  AuthUtilities.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 8/17/17.
//  Copyright © 2017 CarlSmith. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

typealias CameraAuthCompletion = (AVAuthorizationStatus) -> Void
typealias PhotoLibraryAuthCompletion = (PHAuthorizationStatus) -> Void

class AuthUtilities: UIViewController {
    
    class func cameraAuthStatus() -> AVAuthorizationStatus {
        guard AVCaptureDevice.devices(for: AVMediaType.video).count > 0 else {
            return .denied
        }
        
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    }
    
    class func requestCameraAuth(completion: @escaping CameraAuthCompletion) {
        guard AVCaptureDevice.devices(for: AVMediaType.video).count > 0 else {
            completion(.denied)
            return
        }
        
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized {
            completion(.authorized)
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                // Per the docs, the requestAccess completion is called on an arbitrary dispatch queue.
                // Call the requestCameraAuth completion on the main thread.
                DispatchQueue.main.async {
                    if granted == true {
                        completion(.authorized)
                    } else {
                        completion(.denied)
                    }
                }
            })
        }
    }
    
    class func requestPhotoLibraryAuth(completion: @escaping PhotoLibraryAuthCompletion) -> Void {
        
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            completion(.authorized)
        } else {
            PHPhotoLibrary.requestAuthorization({ (status) in
                // Make sure that the completion handler is called on the main thread
                DispatchQueue.main.async {
                    completion(status)
                }
            })
        }
    }
}
