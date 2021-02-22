//
//  UIImage+SN.swift
//  SNKit
//
//  Created by SN on 2021/2/3.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

public extension UIImage {
    
    /// Base-64 encoded header.
    enum Base64EncodedStringHeader : String {
        case png  = "data:image/png;base64,"
        case jpeg = "data:image/jpeg;base64,"
    }
    
    /// Base-64 encoded JPEG or PNG data of the image. JPEG data is preferential.
    /// - Parameters:
    ///   - compressionQuality: The quality of the resulting JPEG image.
    ///   - options: The options to use for the encoding. Default value is [].
    /// - Returns: Base-64 encoded JPEG or PNG data of the image as a String.
    func base64EncodedString(compressionQuality: CGFloat = 1.0, options: Data.Base64EncodingOptions = []) -> String? {
        if let jpegData = self.jpegData(compressionQuality: compressionQuality) {
            return UIImage.base64EncodedString(header: .jpeg, data: jpegData, options: options)
        }
        if let pngData = self.pngData() {
            return UIImage.base64EncodedString(header: .png, data: pngData, options: options)
        }
        return nil
    }
    
    /// Base-64 encoded PNG data of the image.
    /// - Parameter options: The options to use for the encoding. Default value is [].
    /// - Returns: Base-64 encoded PNG data of the image as a String.
    func pngBase64EncodedString(options: Data.Base64EncodingOptions = []) -> String? {
        return UIImage.base64EncodedString(header: .png, data: pngData(), options: options)
    }
    
    /// Base-64 encoded JPEG data of the image.
    /// - Parameters:
    ///   - compressionQuality: The quality of the resulting JPEG image.
    ///   - options: The options to use for the encoding. Default value is [].
    /// - Returns: Base-64 encoded JPEG data of the image as a String.
    func jpegBase64EncodedString(compressionQuality: CGFloat = 1.0, options: Data.Base64EncodingOptions = []) -> String? {
        return UIImage.base64EncodedString(header: .jpeg, data: jpegData(compressionQuality: compressionQuality), options: options)
    }
    
    /// Encode an image data to Base-64 string with the given header and options.
    /// - Parameters:
    ///   - header: Base-64 encoded header value.
    ///   - data: JPEG or PNG data of an image.
    ///   - options: The options to use for the encoding. Default value is [].
    /// - Returns: Returns a Base-64 encoded string.
    private static func base64EncodedString(header: Base64EncodedStringHeader, data: Data?, options: Data.Base64EncodingOptions = []) -> String? {
        guard let imageData = data else { return nil }
        return header.rawValue + imageData.base64EncodedString(options: options)
    }
    
    /// Create a new image from a base 64 string.
    /// - Parameters:
    ///   - base64String: A base-64 `String`, representing the image.
    ///   - options: The options to use for the encoding. Default value is [].
    ///   - scale: The scale factor to assume when interpreting the image data.
    convenience init?(base64Encoded base64String: String, options: Data.Base64DecodingOptions = [], scale: CGFloat = 1.0) {
        guard let data = Data(base64Encoded: base64String, options: options) else { return nil }
        self.init(data: data, scale: scale)
    }
}

public extension UIImage {
    
    /// Create an UIImage with the given color.
    /// - Parameters:
    ///   - color: A color.
    ///   - size: Target size of the image.
    /// - Returns: An UIImage with the given color.
    static func fromColor(_ color: UIColor, size: CGSize = CGSize(width: 1.0, height: 1.0)) -> UIImage? {
        guard size.width > 0.0, size.height > 0.0 else { return nil }
        return UIGraphicsImageRenderer(size: size).image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }

    /// UIImage tinted with color.
    /// - Parameters:
    ///   - color: Color to tint image with.
    ///   - blendMode: The blend mode to use when compositing the image, default is kCGBlendModeDestinationIn.
    ///   - alpha: The desired opacity of the image.
    /// - Returns: UIImage tinted with given color.
    func tint(_ color: UIColor, blendMode: CGBlendMode = .destinationIn, alpha: CGFloat = 1.0) -> UIImage {
        let drawRect = CGRect(origin: .zero, size: size)
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            color.setFill()
            context.fill(drawRect)
            draw(in: drawRect, blendMode: blendMode, alpha: alpha)
        }
    }
    
    /// Render an image with the specified alpha component.
    /// - Parameter alpha: The desired opacity of the image.
    /// - Returns: UIImage rendered with given alpha.
    func withAlphaComponent(_ alpha: CGFloat) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            draw(at: .zero, blendMode: .normal, alpha: alpha)
        }
    }
}

public extension UIImage {
    
    /// Create an image using the data contained within the subrectangle `rect'.
    /// - Parameter rect: CGRect to crop UIImage to.
    /// - Returns: Cropped UIImage.
    func cropping(to rect: CGRect) -> UIImage {
        guard rect.width <= size.width, rect.height <= size.height else { return self }
        let scaledRect = rect.applying(CGAffineTransform(scaleX: scale, y: scale))
        guard let image = cgImage?.cropping(to: scaledRect) else { return self }
        return UIImage(cgImage: image, scale: scale, orientation: imageOrientation)
    }
    
    /// Scale the image to the given size.
    /// - Parameters:
    ///   - targetSize: The size to scale to.
    ///   - proportionally: If true, target size will be adjusted to fit original scale.
    /// - Returns: Returns the scaled image.
    func scale(to targetSize: CGSize, proportionally: Bool = false) -> UIImage {
        var scaledSize = targetSize
        if proportionally {
            let scale = min(targetSize.width / size.width, targetSize.height / size.height)
            scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        }
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        return UIGraphicsImageRenderer(size: scaledSize, format: format).image { context in
            draw(in: CGRect(origin: .zero, size: scaledSize))
        }
    }
}
