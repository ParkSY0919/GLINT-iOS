//
//  NetworkService.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/9/25.
//

import Foundation
import Combine

import Alamofire

typealias RequestData = Encodable & Sendable
typealias ResponseData = Decodable & Sendable

let defaultSession = Session()

struct NetworkService<E: EndPoint>: NetworkServiceInterface {
    func requestAsyncMultipart<T: ResponseData>(_ endPoint: E) async throws -> T {
        let request = defaultSession.request(
            endPoint,
            interceptor: Interceptor(interceptors: [GTInterceptor(type: .multipart)])
        )
        GTLogger.shared.networkRequest("NetworkStart: \(request)")
        
        let response = await request
        .validate(statusCode: 200..<300)
        .serializingDecodable(T.self, decoder: endPoint.decoder)
        .response
        
        print("response: \n\(response)")
        
        switch response.result {
        case .success(let value):
            GTLogger.shared.networkSuccess("networkSuccess")
            return value
        case .failure(let error):
            GTLogger.shared.networkFailure("networkFailure", error: error)
            if case let AFError.requestRetryFailed(
                retryError: retryError,
                originalError: _
            ) = error {
                throw retryError
            }
            
            // throwError 메서드로 처리
            throw endPoint.throwError(error)
        }
    }
    
    func requestAsync<T: ResponseData>(_ endPoint: E) async throws -> T {
        let request = defaultSession.request(
            endPoint,
            interceptor: Interceptor(interceptors: [GTInterceptor(type: .default)])
        )
        GTLogger.shared.networkRequest("NetworkStart: \(request)")
        
        let response = await request
        .validate(statusCode: 200..<300)
        .serializingDecodable(T.self, decoder: endPoint.decoder)
        .response
        
        print("response: \n\(response)")
        
        switch response.result {
        case .success(let value):
            GTLogger.shared.networkSuccess("networkSuccess")
            return value
        case .failure(let error):
            GTLogger.shared.networkFailure("networkFailure", error: error)
            if case let AFError.requestRetryFailed(
                retryError: retryError,
                originalError: _
            ) = error {
                throw retryError
            }
            
            // throwError 메서드로 처리
            throw endPoint.throwError(error)
        }
    }
    
    func requestAsyncVoid(_ endPoint: E) async throws {
        GTLogger.shared.networkRequest("N/Start: noRes, noToken")
        
        let response = await defaultSession.request(
            endPoint,
            interceptor: Interceptor(interceptors: [GTInterceptor(type: .default)])
        )
        .validate(statusCode: 200..<300)
        .serializingData()
        .response
        
        switch response.result {
        case .success: return
        case .failure(let error):
            GTLogger.shared.networkFailure("networkFailure", error: error)
            if case let AFError.requestRetryFailed(retryError: retryError, originalError: _) = error {
                throw retryError
            }
            if case .responseSerializationFailed(.inputDataNilOrZeroLength) = error,
               response.response?.statusCode == 200 {
                GTLogger.shared.networkSuccess("networkSuccess")
                return
            }
            guard response.data != nil else {
                throw error
            }
            throw endPoint.throwError(error)
        }
    }
    
    func requestNonToken<T: ResponseData>(_ endPoint: E) async throws -> T {
        GTLogger.shared.networkRequest("NetworkStart")
        
        let response = await defaultSession.request(endPoint)
        .validate(statusCode: 200..<300)
        .serializingDecodable(T.self, decoder: endPoint.decoder)
        .response
        
        switch response.result {
        case .success(let value):
            GTLogger.shared.networkSuccess("networkSuccess")
            return value
        case .failure(let error):
            GTLogger.shared.networkFailure("networkFailure", error: error)
            guard response.data != nil else {
                throw error
            }
            throw endPoint.throwError(error)
        }
    }
    
    func requestNonToken(_ endPoint: E) async throws {
        GTLogger.shared.networkRequest("NetworkStart")
        
        let response = await defaultSession.request(endPoint)
        .validate(statusCode: 200..<300)
        .serializingData()
        .response
        
        switch response.result {
        case .success: return
        case .failure(let error):
            if case .responseSerializationFailed(.inputDataNilOrZeroLength) = error,
               response.response?.statusCode == 200 {
                GTLogger.shared.networkSuccess("networkSuccess")
                return
            }
            guard response.data != nil else {
                throw error
            }
            throw endPoint.throwError(error)
        }
    }
}
