//
//  CombineNetworkProvider.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/9/25.
//

import Foundation
import Alamofire
import Combine

// MARK: - iOS 17+ Modern CombineNetworkProvider
final class CombineNetworkProvider: NetworkServiceProvider {
    private let session: Session
    private let authInterceptor: GTInterceptor
    
    init(session: Session = AF) {
        self.authInterceptor = GTInterceptor()
        self.session = session
    }
    
    // MARK: - Legacy Combine Methods (기존 호환성)
    func request<T: EndPoint, R: Decodable>(
        target: T,
        responseType: R.Type,
        interceptor: RequestInterceptor? = nil
    ) -> AnyPublisher<R, T.ErrorType> {
        
        GLogger.shared.networkRequest("NetworkStart")
        let finalInterceptor = interceptor ?? authInterceptor
        
        return session.request(target, interceptor: finalInterceptor)
            .validate(statusCode: 200..<300)
            .publishDecodable(type: R.self, decoder: target.decoder)
            .value()
            .handleEvents(
                receiveOutput: { _ in
                    GLogger.shared.networkSuccess("NetworkSuccess")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        GLogger.shared.networkFailure("NetworkFailure", error: error.localizedDescription)
                    }
                }
            )
            .mapError { [weak self] afError -> T.ErrorType in
                return self?.mapAFErrorToGLError(afError) ?? GLError.unknown(afError)
            }
            .eraseToAnyPublisher()
    }
    
    func request<T: EndPoint>(
        target: T,
        interceptor: RequestInterceptor? = nil
    ) -> AnyPublisher<Void, T.ErrorType> {
        
        GLogger.shared.networkRequest("NetworkStart")
        let finalInterceptor = interceptor ?? authInterceptor
        
        return session.request(target, interceptor: finalInterceptor)
            .validate(statusCode: 200..<300)
            .publishData()
            .tryMap { dataResponse -> Void in
                GLogger.shared.networkSuccess("NetworkSuccess")
                
                if let error = dataResponse.error {
                    if case .responseSerializationFailed(.inputDataNilOrZeroLength) = error,
                       dataResponse.response?.statusCode == 200 {
                        return ()
                    }
                    throw error
                }
                return ()
            }
            .mapError { [weak self] error -> T.ErrorType in
                if let afError = error as? AFError {
                    return self?.mapAFErrorToGLError(afError) ?? GLError.unknown(afError)
                }
                return GLError.unknown(error)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Modern Async/Await Methods (iOS 17+ 권장)
    
    /// Decodable 응답을 반환하는 비동기 요청
    func requestAsync<T: EndPoint, R: Decodable>(
        target: T,
        responseType: R.Type,
        interceptor: RequestInterceptor? = nil
    ) async throws -> R {
        GLogger.shared.networkRequest("NetworkStart")
        
        let finalInterceptor = interceptor ?? authInterceptor
        
        do {
            let response = try await session.request(target, interceptor: finalInterceptor)
                .validate(statusCode: 200..<300)
                .serializingDecodable(R.self, decoder: target.decoder)
                .value
            
            GLogger.shared.networkSuccess("NetworkSuccess")
            return response
        } catch {
            GLogger.shared.networkFailure("NetworkFailure", error: error.localizedDescription)
            
            if let afError = error as? AFError {
                throw mapAFErrorToGLError(afError)
            }
            throw GLError.unknown(error)
        }
    }
    
    /// Void 응답을 반환하는 비동기 요청
    func requestAsync<T: EndPoint>(
        target: T,
        interceptor: RequestInterceptor? = nil
    ) async throws {
        GLogger.shared.networkRequest("NetworkRequest")
        
        let finalInterceptor = interceptor ?? authInterceptor
        
        do {
            let dataResponse = await session.request(target, interceptor: finalInterceptor)
                .validate(statusCode: 200..<300)
                .serializingData()
                .response
            
            GLogger.shared.networkDataResponse(dataResponse)
            
            // 200 상태코드이지만 데이터가 없는 경우 정상 처리
            if let error = dataResponse.error {
                if case .responseSerializationFailed(.inputDataNilOrZeroLength) = error,
                   dataResponse.response?.statusCode == 200 {
                    return
                }
                throw error
            }
        } catch {
            GLogger.shared.networkFailure("NetworkFailure", error: error.localizedDescription)
            
            if let afError = error as? AFError {
                throw mapAFErrorToGLError(afError)
            }
            throw GLError.unknown(error)
        }
    }
    
    // MARK: - 인증 없는 요청 (로그인, 회원가입 등)
    
    /// 인증 헤더 없이 Decodable 응답 요청
    func requestWithoutAuth<T: EndPoint, R: Decodable>(
        target: T,
        responseType: R.Type
    ) async throws -> R {
        return try await requestAsync(target: target, responseType: responseType, interceptor: nil)
    }
    
    /// 인증 헤더 없이 Void 응답 요청
    func requestWithoutAuth<T: EndPoint>(
        target: T
    ) async throws {
        try await requestAsync(target: target, interceptor: nil)
    }
    
    
    // MARK: - Error Mapping
    private func mapAFErrorToGLError(_ afError: AFError) -> GLError {
        switch afError {
        case .responseValidationFailed(let reason):
            switch reason {
            case .unacceptableStatusCode(let code):
                switch code {
                case 401: return GLError.e401
                case 403: return GLError.e403
                case 419: return GLError.e419
                case 420: return GLError.e420
                case 429: return GLError.e429
                case 444: return GLError.e444
                case 500: return GLError.e500
                default: return GLError.unknown(afError)
                }
            default: return GLError.unknown(afError)
            }
        case .sessionTaskFailed:
            return GLError.networkFailure(afError)
        case .responseSerializationFailed:
            return GLError.unknown(afError)
        case .requestRetryFailed(let retryError, _):
            if let specificError = retryError as? GLError {
                return specificError
            }
            return GLError.retryFailed(afError)
        default:
            return GLError.unknown(afError)
        }
    }
}

// MARK: - Combine to Async/Await Bridge Extensions
extension Publisher {
    /// Combine Publisher를 async/await로 변환 (단일 값)
    func asyncValue() async throws -> Output {
        for try await value in self.values {
            return value
        }
        throw URLError(
            .cannotLoadFromNetwork,
            userInfo: [NSLocalizedDescriptionKey: "The publisher completed without emitting a value."]
        )
    }
    
    /// Combine Publisher를 async/await로 변환 (완료 대기)
    func asyncCompletion() async throws {
        var iterator = self.values.makeAsyncIterator()
        _ = try await iterator.next()
    }
    
    // Legacy 호환성 메서드들
    func firstValue() async throws -> Output {
        return try await asyncValue()
    }
    
    func awaitCompletion() async throws {
        try await asyncCompletion()
    }
}
