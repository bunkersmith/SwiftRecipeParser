//
//  RecipeMasterTableViewController+CameraAuth.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 8/18/17.
//  Copyright © 2017 CarlSmith. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

extension RecipeMasterTableViewController {

    func checkCameraAndLibrary() {
        if cameraAndPhotoLibraryDenied() {
            alertForAccessViaSettings(accessType: "Camera and Photo Library")
        } else {
            if cameraCheckNeeded() {
                checkCamera()
            }
            
            if photoLibraryCheckNeeded() {
                checkPhotoLibrary()
            }
        }
    }
    
    func cameraAndPhotoLibraryDenied() -> Bool {
        let cameraAuthStatus = AuthUtilities.cameraAuthStatus()
        let libraryAuthStatus = PHPhotoLibrary.authorizationStatus()
        
        return cameraAuthStatus == .denied && libraryAuthStatus == .denied
    }
    
    func cameraCheckNeeded() -> Bool {
        let authStatus = AuthUtilities.cameraAuthStatus()
        
        return authStatus == .denied || authStatus == .notDetermined
    }
    
    func checkCamera() {

        let authStatus = AuthUtilities.cameraAuthStatus()
        
        switch authStatus {
        case .authorized:
            Logger.logDetails(msg: "Camera is authorized")
        case .denied:
            alertForAccessViaSettings(accessType: "Camera")
        case .notDetermined:
            AuthUtilities.requestCameraAuth(completion: { (authStatus) in
                Logger.logDetails(msg: "authStatus = \(authStatus)")
            })
        case .restricted:
            Logger.logDetails(msg: "Camera access is restricted")
        }
    }
    
    func alertForAccessViaSettings(accessType: String) {
    
        AlertUtilities.showTwoButtonAlert(self,
                                          title: "\(accessType) Usage",
                                          message: "Please let Swift Recipe Parser use the \(accessType.lowercased()) for grocery item photos.",
                                          buttonTitle1: "Cancel",
                                          buttonHandler1: nil,
                                          buttonTitle2: "Allow \(accessType)",
                                          buttonHandler2: { (action) in
                                            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
                                          })
    }
    
    func photoLibraryCheckNeeded() -> Bool {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        
        return authStatus == .denied || authStatus == .notDetermined
    }
    
    func checkPhotoLibrary() {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authStatus {
            case .authorized:
                Logger.logDetails(msg: "Photo library access is authorized")
            case .denied:
                alertForAccessViaSettings(accessType: "Photo Library")
            case .notDetermined:
                AuthUtilities.requestPhotoLibraryAuth(completion: { (status) in
                    Logger.logDetails(msg: "authStatus = \(authStatus)")
                })
            case .limited:
                Logger.logDetails(msg: "Photo library access is limited")
            case .restricted:
                Logger.logDetails(msg: "Photo library access is restricted")
        }
    }

}
