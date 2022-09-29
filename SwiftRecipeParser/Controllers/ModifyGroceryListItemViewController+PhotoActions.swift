//
//  ModifyGroceryListItemViewController+PhotoActions.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 8/19/17.
//  Copyright © 2017 CarlSmith. All rights reserved.
//

import UIKit
import AVFoundation

extension ModifyGroceryListItemViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func showPhotoAlert() {
        let cameraAlert = UIAlertController(title:"Photo Source", message:"Select the source for your photo", preferredStyle:UIAlertControllerStyle.alert)
        cameraAlert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] (action) in
            guard let strongSelf = self else {
                return
            }
            
            AuthUtilities.requestCameraAuth(completion: { (status) in
                print("status = \(status)")
                
                if status == .authorized {
                    strongSelf.showPicker(sourceType: .camera)
                } else {
                    AlertUtilities.showTwoButtonAlert(strongSelf,
                                                      title: "Camera Usage",
                                                      message: "Please let Swift Recipe Parser use the camera for grocery item photos.",
                                                      buttonTitle1: "Cancel",
                                                      buttonHandler1: nil,
                                                      buttonTitle2: "Allow Camera",
                                                      buttonHandler2: { (action) in
                                                        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
                                                      })
                }
            })
        }))
        cameraAlert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] (action) in
            guard let strongSelf = self else {
                return
            }
            
            AuthUtilities.requestPhotoLibraryAuth(completion: { (status) in
                print("status = \(status)")
                
                if status == .authorized {
                    strongSelf.showPicker(sourceType: .photoLibrary)
                } else {
                    AlertUtilities.showTwoButtonAlert(strongSelf,
                                                      title: "Photo Library Usage",
                                                      message: "Please let Swift Recipe Parser use your photo library for grocery item photos.",
                                                      buttonTitle1: "Cancel",
                                                      buttonHandler1: nil,
                                                      buttonTitle2: "Allow Photo Library",
                                                      buttonHandler2: { (action) in
                                                        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
                    })
                }
            })
        }))
        cameraAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(cameraAlert, animated:true, completion: nil)
    }

    func showDeleteAlert() {
        let deleteAlert = UIAlertController(title:"Photo Deletion", message:"Are you sure you want to delete this photo?", preferredStyle:UIAlertControllerStyle.alert)
        deleteAlert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self] (action) in
            guard let strongSelf = self else {
                return
            }
            
            let error = strongSelf.groceryListItem.deleteImage(databaseInterface: strongSelf.databaseInterface)
            
            if error == nil {
                strongSelf.configureThumbnail()
            } else {
                AlertUtilities.showOkButtonAlert(strongSelf, title: "Deletion Error", message: "Error deleting photo", buttonHandler: nil)
            }
        }))
        deleteAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(deleteAlert, animated:true, completion: nil)
    }
    
    func showPicker(sourceType: UIImagePickerControllerSourceType) {
        
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        if originalImage != nil {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {
                    Logger.logDetails(msg: "Self error")
                    return
                }
                
                strongSelf.processImage(originalImage)

                strongSelf.dismiss(animated: true, completion: nil)
            }
        } else {
            AlertUtilities.showOkButtonAlert(self, title: "Error Alert", message: "Could not obtain image.", buttonHandler: { [weak self] (action) in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.dismiss(animated: true, completion: nil)
            })
        }
    }


    func processImage(_ image: UIImage!) {
        
        activityIndicator.startAnimating()
        
        let imageResult = groceryListItem.createImage(image: image,
                                                      thumbnailSize: imageView.bounds.size)
        
        guard imageResult.error == nil else {
            showImageError()
            return
        }
        
        guard let imageData = imageResult.imageData else {
            showImageError()
            return
        }
        
        activityIndicator.stopAnimating()
        
        let error = groceryListItem.saveImage(imageData: imageData,
                                                         databaseInterface: databaseInterface)
        
        if error == nil {
            configureThumbnail()
        }
    }
    
    func showImageError() {
        DispatchQueue.main.async {
            AlertUtilities.showOkButtonAlert(self, title: "Error Alert", message: "Could not add photo", buttonHandler: nil )
        }
    }
}
