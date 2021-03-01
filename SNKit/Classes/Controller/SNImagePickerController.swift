//
//  SNImagePickerController.swift
//  SNKit
//
//  Created by SN on 2020/3/2.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

public final class SNImagePickerController : UIImagePickerController {
    
    private var completionHandler: (([UIImagePickerController.InfoKey : Any]) -> Void)?
    
    /// Presents from a viewcontroller, and call the reslut back in completionHandler.
    /// - Parameters:
    ///   - presentingViewController: The view controller that presented this view controller.
    ///   - completionHandler: In stead of delegate to call the reslut back.
    public static func present(from presentingViewController: UIViewController, allowsEditing: Bool = false,
                               completionHandler: (([UIImagePickerController.InfoKey : Any]) -> Void)? = nil) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera), UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alertController.addAction(UIAlertAction(title: "拍照", style: .default, handler: { [weak presentingViewController] (_) in
                guard let presenting = presentingViewController else { return }
                SNImagePickerController.present(from: presenting, allowsEditing: allowsEditing, sourceType: .camera, completionHandler: completionHandler)
            }))
            alertController.addAction(UIAlertAction(title: "从手机相册选择", style: .default, handler: { [weak presentingViewController] (_) in
                guard let presenting = presentingViewController else { return }
                SNImagePickerController.present(from: presenting, allowsEditing: allowsEditing, sourceType: .photoLibrary, completionHandler: completionHandler)
            }))
        } else if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(UIAlertAction(title: "拍照", style: .default, handler: { [weak presentingViewController] (_) in
                guard let presenting = presentingViewController else { return }
                SNImagePickerController.present(from: presenting, allowsEditing: allowsEditing, sourceType: .camera, completionHandler: completionHandler)
            }))
        } else if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alertController.addAction(UIAlertAction(title: "从手机相册选择", style: .default, handler: { [weak presentingViewController] (_) in
                guard let presenting = presentingViewController else { return }
                SNImagePickerController.present(from: presenting, allowsEditing: allowsEditing, sourceType: .photoLibrary, completionHandler: completionHandler)
            }))
        }
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        DispatchQueue.main.async { presentingViewController.present(alertController, animated: true, completion: nil) }
    }
    
    private class func present(from presentingViewController: UIViewController,
                               allowsEditing: Bool,
                               sourceType: UIImagePickerController.SourceType,
                               completionHandler: (([UIImagePickerController.InfoKey : Any]) -> Void)? = nil) {
        let imagePickerController = SNImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.allowsEditing = allowsEditing
        imagePickerController.modalPresentationStyle = .fullScreen
        imagePickerController.delegate = imagePickerController
        imagePickerController.completionHandler = completionHandler
        presentingViewController.present(imagePickerController, animated: true, completion: nil)
    }
}

extension SNImagePickerController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [weak self] in
            self?.completionHandler?(info)
        }
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
