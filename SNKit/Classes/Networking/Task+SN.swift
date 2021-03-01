//
//  Task+SN.swift
//  SNKit
//
//  Created by SN on 2020/3/1.
//  Copyright © 2020 Apple. All rights reserved.
//

import Moya

public extension Task {
    
    /// Creates a "multipart/form-data" post task with the given parameters, the parameter will be ignored when its value is nil.
    /// For parameter value: Array, Dictionary will be mapped into json string, NSNumber will be mapped into stringValue, Bool will be mapped using the rule: 'false' -> "0", 'true' -> "1".
    /// - Parameter parameters: The request parameters.
    /// - Returns: A Task instance, represents an HTTP task.
    static func multipartPost(_ parameters: [String : Any]) -> Task {
        let compactedParameters = parameters.compactMapValues { $0 }
        return .uploadMultipart(compactedParameters.compactMap { (key, value) -> MultipartFormData? in
            let transform: Data?
            switch value {
            case let dictionary as [String : Any]:
                transform = try? JSONSerialization.data(withJSONObject: dictionary)
            case let array as [Any]:
                transform = try? JSONSerialization.data(withJSONObject: array)
            case let number as NSNumber:
                if NSStringFromClass(type(of: number)) == "__NSCFBoolean" {
                    transform = (number.boolValue ? "1" : "0").data(using: .utf8)
                } else {
                    transform = number.stringValue.data(using: .utf8)
                }
            case let bool as Bool:
                transform = (bool ? "1" : "0").data(using: .utf8)
            case let data as Data:
                transform = data
            default:
                transform = ("\(value)").data(using: .utf8)
            }
            guard let data = transform else { return nil }
            return MultipartFormData(provider: .data(data), name: key)
        })
    }
}
