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
/// The configured localized titles will be used in action sheet before presenting SNImagePickerController.
public final class SNImagePickerConfiguration {
    
    public enum Action : Int {
        case openingCamera
        case openingPhotoLibrary
        case cancel
    }
    
    static let shared = SNImagePickerConfiguration()
    private var configuredTitles: [Action : String] = [:]
    typealias SNImagePickerSourceType = UIImagePickerController.SourceType
    
    // MARK: - public
    
    /// Provides a handler with a shared instance of SNImagePickerConfiguration.
    /// - Parameter handler: Takes a shared instance of SNImagePickerConfiguration as its only parameter.
    public static func configurate(_ handler: (SNImagePickerConfiguration) -> Void) {
        handler(shared)
    }
    
    /// Configurates localized title of actions those defines in 'Action'.
    /// - Parameters:
    ///   - title: Title of action.
    ///   - action: Instance of 'Action'.
    public func setTitle(_ title: String, for action: Action) {
        configuredTitles[action] = title
    }
    
    // MARK: - internal
        
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
        /// If there isn't any available source type, ignores presenting.
        let availableSourceTypes = SNImagePickerConfiguration.availableSourceTypes()
        if availableSourceTypes.isEmpty { return }
        /// Presents a action sheet for available source types to select.
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
                                completionHandler: (([UIImagePickerController.InfoKey : Any]) -> Void)?) {
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
