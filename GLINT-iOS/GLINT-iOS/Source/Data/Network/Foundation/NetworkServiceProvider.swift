//
//  NetworkServiceProvider.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/9/25.
//

import Foundation
import Combine

import Alamofire

typealias ResponseData = Decodable & Sendable
typealias RequestData = Encodable & Sendable

let defaultSession = Session()

let imageSession = Session(
    interceptor: Interceptor(
        adapters: [KeyAdapter()],
        interceptors: [GTInterceptor()]
    )
)

struct KeyAdapter: RequestAdapter {
    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, any Error>) -> Void
    ) {
        var request = urlRequest
        request.addValue(
            Config.sesacKey,
            forHTTPHeaderField: "SeSACKey"
        )
        completion(.success(request))
    }
}


// MARK: - Network Service Provider 프로토콜
protocol NetworkServiceProvider {
    associatedtype E: EndPoint
    
    // 토큰 포함 요청
    static func requestAsync<T: ResponseData>(_ endPoint: E) async throws -> T
    static func requestAsync(_ endPoint: E) async throws
    
    // 토큰 없이 요청 (adaptable 파라미터 추가)
    static func requestNonToken<T: ResponseData>(_ endPoint: E) async throws -> T
    static func requestNonToken(_ endPoint: E) async throws
}

extension NetworkServiceProvider {
    static func requestAsync<T: ResponseData>(_ endPoint: E) async throws -> T {
        GTLogger.shared.networkRequest("NetworkStart")
        
        let response = await defaultSession.request(
            endPoint,
            interceptor: Interceptor(
                interceptors: [GTInterceptor()]
            )
        )
        .validate(statusCode: 200..<300)
        .serializingDecodable(T.self, decoder: endPoint.decoder)
        .response
        
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
    
    static func requestAsync(_ endPoint: E) async throws {
        GTLogger.shared.networkRequest("NetworkStart")
        
        let response = await defaultSession.request(
            endPoint,
            interceptor: Interceptor(
                interceptors: [GTInterceptor()]
            )
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
    
    static func requestNonToken<T: ResponseData>(_ endPoint: E) async throws -> T {
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
    
    static func requestNonToken(_ endPoint: E) async throws {
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
