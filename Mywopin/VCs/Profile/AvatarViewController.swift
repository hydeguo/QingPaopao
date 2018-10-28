//
//  AvatarViewController.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/10/28.
//  Copyright © 2018 Wopin. All rights reserved.
//

import Foundation
import Photos
import UIKit


class AvatarViewController: UIViewController ,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    @IBOutlet var avatar:UIImageView?
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.imagePicker.delegate = self
        
    }
    
    func changePic()
    {
 
        let sheet = UIAlertController(title: nil, message: Language.getString("Select the source") , preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: Language.getString("Camera"), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.openPhotoPickerWith(source: .camera)
        })
        let photoAction = UIAlertAction(title: Language.getString("Gallery"), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.openPhotoPickerWith(source: .library)
        })
        let cancelAction = UIAlertAction(title: Language.getString("Cancel"), style: .cancel, handler: nil)
        sheet.addAction(cameraAction)
        sheet.addAction(photoAction)
        sheet.addAction(cancelAction)
        self.present(sheet, animated: true, completion: nil)
    }
    
    func openPhotoPickerWith(source: PhotoSource) {
        switch source {
        case .camera:
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if (status == .authorized || status == .notDetermined) {
                self.imagePicker.sourceType = .camera
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        case .library:
            let status = PHPhotoLibrary.authorizationStatus()
            if (status == .authorized || status == .notDetermined) {
                self.imagePicker.sourceType = .savedPhotosAlbum
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            //            self.mainImage.image = pickedImage
            if let imageData = UIImageJPEGRepresentation(pickedImage, 0.1)
            {
                avatar?.image = pickedImage
                uploadImage(fileName: UUID.init().uuidString+".jpg", imageData: imageData) { (url) in
                    if let _url = url
                    {
                        self.avatar?.image(fromUrl: _url)
                        myClientVo?.icon = _url;
                        _ = Wolf.request(type: MyAPI.changeIcon(icon: _url), completion: { (returnUser2: User?, msg, code) in
                        }, failure: nil)
                    }
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
