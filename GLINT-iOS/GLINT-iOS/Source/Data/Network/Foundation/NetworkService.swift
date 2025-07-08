//
//  NetworkService.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/9/25.
//

//
//  NetworkService.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/9/25.
//

import Foundation

import Alamofire

let defaultSession = Session()

struct NetworkService<E: EndPoint>: NetworkServiceInterface {
    /// 응답 O 에러 핸들러
    private func handleError<U: EndPoint>(_ error: Error, endPoint: U) throws -> Never {
        GTLogger.shared.networkFailure("networkFailure", error: error)
        
        if let afError = error as? AFError {
            switch afError {
            case .responseSerializationFailed(let reason):
                if case .decodingFailed(let decodingError) = reason {
                    GTLogger.shared.i("디코딩 에러: \(decodingError)")
                }
            case .responseValidationFailed(let reason):
                switch reason {
                case .unacceptableStatusCode(let code):
                    GTLogger.shared.i("서버 응답 상태 코드: \(code)")
                case .dataFileNil:
                    GTLogger.shared.i("응답 데이터가 없음")
                default:
                    break
                }
            default:
                break
            }
            
            // 재시도 실패 시 원본 에러를 다시 던짐
            if case let AFError.requestRetryFailed(retryError: retryError, originalError: _) = afError {
                throw retryError
            }
        }
        
        // 타임아웃 에러는 그대로 throw
        if let urlError = error as? URLError, urlError.code == .timedOut {
            throw error
        }
        
        // 그 외의 경우 endPoint의 커스텀 에러로 변환
        throw endPoint.throwError(error as? AFError ?? AFError.explicitlyCancelled)
    }
    
    //MARK: 응답값 O
    func request<T: ResponseData>(_ endPoint: E) async throws -> T {
        let type: InterceptorType = endPoint.path == "refresh" ? .refresh : .default
        
        GTLogger.shared.networkRequest("🚀 NetworkStart: \(endPoint.method.rawValue) \(endPoint.baseURL)\(endPoint.path)")
        
        let request = defaultSession.request(
            endPoint,
            interceptor: Interceptor(interceptors: [GTInterceptor(type: type)])
        )
        
        do {
            let value = try await withTimeout(seconds: 10) {
                try await request
                    .validate(statusCode: 200..<300)
                    .serializingDecodable(T.self, decoder: endPoint.decoder)
                    .value
            }
            
            GTLogger.shared.networkSuccess("networkSuccess")
            print("response: \(value)")
            return value
            
        } catch {
            // handleError를 호출하여 에러 처리
            try handleError(error, endPoint: endPoint)
        }
    }

    // 타임아웃 헬퍼 함수
    func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw URLError(.timedOut)
            }
            
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
    
    //MARK: 응답값 X
    func requestVoid(_ endPoint: E) async throws {
        let type: InterceptorType = endPoint.path == "refresh" ? .refresh : .default
        
        GTLogger.shared.networkRequest("🚀 NetworkStart (Void): \(endPoint.method.rawValue) \(endPoint.baseURL)\(endPoint.path)")
        
        let request = defaultSession.request(
            endPoint,
            interceptor: Interceptor(interceptors: [GTInterceptor(type: type)])
        )
        
        do {
            // response headers만 확인, body는 기다리지 않음
            try await withCheckedThrowingContinuation { continuation in
                request.response { response in
                    if let statusCode = response.response?.statusCode, 200..<300 ~= statusCode {
                        GTLogger.shared.networkSuccess("networkSuccess (Void Response) - Status: \(statusCode)")
                        continuation.resume()
                    } else {
                        let statusCode = response.response?.statusCode ?? -1
                        let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: statusCode))
                        continuation.resume(throwing: error)
                    }
                }
            }
            
        } catch {
            try handleError(error, endPoint: endPoint)
        }
    }
    
    /// 멀티파트폼
    func requestMultipart<T: ResponseData>(_ endPoint: E) async throws -> T {
        guard case .multipartData(let config) = endPoint.requestType else {
            throw GLError.typeError("Multipart 메서드에 잘못된 requestType이 전달됨")
        }
        
        GTLogger.shared.networkRequest("🚀 NetworkStart (Multipart): \(endPoint.method.rawValue) \(endPoint.baseURL)\(endPoint.path)")
        
        let request = defaultSession.upload(
            multipartFormData: { formData in
                for (index, data) in config.files.enumerated() {
                    let fileName = "file\(index).\(config.fileExtension)"
                    formData.append(
                        data,
                        withName: config.fieldName,
                        fileName: fileName,
                        mimeType: config.mimeType
                    )
                }
            },
            to: endPoint.baseURL + endPoint.path,
            method: endPoint.method,
            interceptor: Interceptor(interceptors: [GTInterceptor(type: .multipart)])
        )
        
        do {
            let value = try await withTimeout(seconds: 10) {
                try await request
                    .validate(statusCode: 200..<300)
                    .serializingDecodable(T.self, decoder: endPoint.decoder)
                    .value
            }
            
            GTLogger.shared.networkSuccess("networkSuccess (Multipart)")
            return value
            
        } catch {
            // handleError를 호출하여 에러 처리
            try handleError(error, endPoint: endPoint)
        }
    }
}
