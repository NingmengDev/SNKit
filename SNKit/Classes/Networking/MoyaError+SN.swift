//
//  MoyaError+SN.swift
//  SNKit
//
//  Created by SN on 2020/3/1.
//  Copyright © 2020 Apple. All rights reserved.
//

import Moya
import Alamofire

/// Unwraps MoyaError.
public extension MoyaError {
    
    /// Depending on error type, returns a more underlying error.
    var unwrappedError: Swift.Error {
        switch self {
        case .objectMapping(let error, _):
            return (error as? AFError)?.underlyingError ?? error
        case .encodableMapping(let error):
            return (error as? AFError)?.underlyingError ?? error
        case .underlying(let error, _):
            return (error as? AFError)?.underlyingError ?? error
        case .parameterEncoding(let error):
            return (error as? AFError)?.underlyingError ?? error
        default:
            return self
        }
    }
}
