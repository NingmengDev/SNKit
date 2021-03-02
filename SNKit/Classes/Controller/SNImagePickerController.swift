//
//  SNImagePickerController.swift
//  SNKit
//
//  Created by SN on 2020/3/2.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

/// A configuration for `SNImagePickerController`.
/// You must invoke function 'configurate(_:)' to configurate localized title of actions those defines in 'Action'.
/// The configured title of action will be used in action sheet before presenting SNImagePickerController.
public class SNImagePickerConfiguration {
    
    public enum Action : Int {
        case openingCamera
        case openingPhotoLibrary
        case cancel
    }
    
    static let shared = SNImagePickerConfiguration()
    private var configuredTitles: [Action : String] = [:]
    typealias SNImagePickerSourceType = UIImagePickerController.SourceType
    
    public static func configurate(_ handler: (SNImagePickerConfiguration) -> Void) {
        handler(shared)
    }
    
    public func setTitle(_ title: String, for action: Action) {
        configuredTitles[action] = title
    }
    
    static func configuredTitle(for action: Action) -> String {
        return shared.configuredTitles[action] ?? ""
    }
    
    static func availableSourceTypes() -> [SNImagePickerSourceType] {
        return [.camera, .photoLibrary].filter {
            return UIImagePickerController.isSourceTypeAvailable($0)
        }
    }
    
    static func action(for sourceType: SNImagePickerSourceType) -> Action {
        switch sourceType {
        case .camera:
            return .openingCamera
        default:
            return .openingPhotoLibrary
        }
    }
}

public final class SNImagePickerController : UIImagePickerController {
    
    private var completionHandler: (([UIImagePickerController.InfoKey : Any]) -> Void)?
        
    /// Presents a SNImagePickerController from a view controller, and call reslut back in the completion handler.
    /// - Parameters:
    ///   - presentingViewController: The view controller that presented this view controller.
    ///   - completionHandler: In stead of delegate to call reslut back.
    public static func present(from presentingViewController: UIViewController,
                               allowsEditing: Bool = true,
                               completionHandler: @escaping (([UIImagePickerController.InfoKey : Any]) -> Void)) {
        ///
        let availableSourceTypes = SNImagePickerConfiguration.availableSourceTypes()
        if availableSourceTypes.isEmpty { return }
        ///
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for availableSourceType in availableSourceTypes {
            let action = SNImagePickerConfiguration.action(for: availableSourceType)
            alertController.addAction(UIAlertAction(title: SNImagePickerConfiguration.configuredTitle(for: action),
                                                    style: .default) { [weak presentingViewController] (_) in
                guard let strongPresentingViewController = presentingViewController else { return }
                SNImagePickerController.present(from: strongPresentingViewController,
                                                allowsEditing: allowsEditing,
                                                sourceType: availableSourceType,
                                                completionHandler: completionHandler)
            })
        }
        alertController.addAction(UIAlertAction(title: SNImagePickerConfiguration.configuredTitle(for: .cancel), style: .cancel))
        DispatchQueue.main.async { presentingViewController.present(alertController, animated: true) }
    }
    
    private static func present(from presentingViewController: UIViewController,
                                allowsEditing: Bool,
                                sourceType: UIImagePickerController.SourceType,
                                completionHandler: (([UIImagePickerController.InfoKey : Any]) -> Void)? = nil) {
        let imagePickerController = SNImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.allowsEditing = allowsEditing
        imagePickerController.modalPresentationStyle = .fullScreen
        imagePickerController.delegate = imagePickerController
        imagePickerController.completionHandler = completionHandler
        presentingViewController.present(imagePickerController, animated: true)
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
