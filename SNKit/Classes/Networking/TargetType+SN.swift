//
//  TargetType+SN.swift
//  SNKit
//
//  Created by SN on 2020/3/1.
//  Copyright © 2020 Apple. All rights reserved.
//

import Moya

/// The protocol used to define the specifications necessary for a `SNMoyaProvider`.
public protocol SNMoyaTarget : TargetType {
    
    /// Returns the timeout interval of the receiver.
    /// Default is 15s.
    var timeoutInterval: TimeInterval { get }
    
    /// Validates parameters before requesting.
    /// If a parameter doesn't conform to some rule, return a Error to ignore request.
    /// Default is nil.
    var parametersValidation: Error? { get }
    
    /// A flag, if true, the 'callbackHandler' will still be invoked when the request is cancelled.
    /// See also MoyaProvider+SN.
    /// Default is false.
    var callbackWhenCancelled: Bool { get }
    
    /// If true, maps responsive data received from the request into a JSON object.
    /// See also MoyaProvider+SN.
    /// Default is false.
    var mapsResponseToJSON: Bool { get }
}

/// Defines default values.
public extension SNMoyaTarget {
    
    var timeoutInterval: TimeInterval {
        return 15.0
    }
    
    var parametersValidation: Error? {
        return nil
    }
    
    var callbackWhenCancelled: Bool {
        return false
    }
    
    var mapsResponseToJSON: Bool {
        return false
    }
}
