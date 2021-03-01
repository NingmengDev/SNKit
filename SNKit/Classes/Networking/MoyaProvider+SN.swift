//
//  MoyaProvider+SN.swift
//  SNKit
//
//  Created by SN on 2020/3/1.
//  Copyright © 2020 Apple. All rights reserved.
//

import Moya

/// Define a unified completion handler.
/// This handler takes a result object and an error as its parameters, result object is mutually-exclusive with error.
/// When requesting target conforms to SNMoyaTarget, and 'mapsResponseToJSON' is true,
/// the responsive data will be mapped into a JSON object, and sets as the result object.
public typealias SNMoyaCompletionHandler = (Any?, Error?) -> Void

/// Request provider class. Requests should be made through this class only.
/// `MultiTarget` will be used to enable `SNMoyaProvider` to process multiple `TargetType`s.
public final class SNMoyaProvider : MoyaProvider<MultiTarget> {
    
    /// Designated request-making method.
    /// - Parameters:
    ///   - target: Any object which conforms to TargetType.
    ///   - callbackQueue: Propagated to Alamofire as callback queue.
    ///   - progress: Progress handler to be executed when progress changes.
    ///   - completionHandler: Completion handler to be executed when a request has completed.
    /// - Returns: A `Cancellable` token to cancel the request later.
    @discardableResult
    public func request(_ target: Target,
                      callbackQueue: DispatchQueue? = nil,
                      progress: ProgressBlock? = nil,
                      completionHandler: @escaping SNMoyaCompletionHandler) -> Cancellable {
        return super.request(MultiTarget(target),
                             callbackQueue: callbackQueue,
                             progress: progress) { (result) in
            switch result {
            case .success(let response):
                completionHandler(response, nil)
            case .failure(let error):
                /// Unwraps error to get an more underlying `Error`.
                let unwrappedError = error.unwrappedError
                completionHandler(nil, unwrappedError)
            }
        }
    }
     
    /// Designated request-making method, use 'SNMoyaTarget' as designated target.
    /// - Parameters:
    ///   - target: Any object which conforms to SNMoyaTarget.
    ///   - plugins: A list of plugins.
    ///   - callbackQueue: Propagated to Alamofire as callback queue.
    ///   - progress: Progress handler to be executed when progress changes.
    ///   - completionHandler: Completion handler to be executed when a request has completed.
    /// - Returns: A `Cancellable` token to cancel the request later.
    @discardableResult
    public static func request(_ target: SNMoyaTarget,
                               plugins: [PluginType] = [],
                               callbackQueue: DispatchQueue? = nil,
                               progress: ProgressBlock? = nil,
                               completionHandler: @escaping SNMoyaCompletionHandler) -> Cancellable {
        /// Customize request closure.
        let requestClosure = { (endpoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
            if let parametersError = target.parametersValidation {
                done(.failure(MoyaError.parameterEncoding(parametersError)))
                return
            }
            do { var request = try endpoint.urlRequest()
                request.timeoutInterval = target.timeoutInterval
                done(.success(request))
            } catch MoyaError.requestMapping(let url) {
                done(.failure(MoyaError.requestMapping(url)))
            } catch MoyaError.parameterEncoding(let error) {
                done(.failure(MoyaError.parameterEncoding(error)))
            } catch {
                done(.failure(MoyaError.underlying(error, nil)))
            }
        }
        /// Create a provider with the customized request closure and the given plugins.
        let provider = SNMoyaProvider(requestClosure: requestClosure, plugins: plugins)
        return provider.request(MultiTarget(target),
                                callbackQueue: callbackQueue,
                                progress: progress) { result in
            switch result {
            case .success(let response):
                guard target.mapsResponseToJSON else {
                    completionHandler(response, nil)
                    return
                }
                do { let json = try response.mapJSON()
                    completionHandler(json, nil)
                } catch {
                    completionHandler(nil, error)
                }
            case .failure(let error):
                /// Unwraps error to get an more underlying `Error`.
                let unwrappedError = error.unwrappedError
                /// Handles for the cancelled task if needed. See also 'callbackWhenCancelled'.
                if (unwrappedError as NSError).code == NSURLErrorCancelled, !target.callbackWhenCancelled {
                    /// When the request is cancelled, the underlying
                    /// Alamofire failure callback will still kicks in, resulting in a nil 'request'.
                    ///
                    /// When 'callbackWhenCancelled' is false, we choose to completely ignore cancelled tasks.
                    /// Neither success or failure callback will be called.
                } else {
                    completionHandler(nil, unwrappedError)
                }
            }
        }
    }
}
