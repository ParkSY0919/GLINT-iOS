//
//  GTInterceptor.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/27/25.
//

import Foundation

import Alamofire

final class GTInterceptor: RequestInterceptor {
    enum InterceptorType {
        case `default`
        case nuke
        case multipart
    }
    
    private let type: InterceptorType
    private let keychain = KeychainManager.shared
    
    init(type: InterceptorType) {
        self.type = type
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var adaptedRequest = urlRequest
        
        if type == .nuke {
            adaptedRequest.setValue("\(Config.sesacKey)", forHTTPHeaderField: "SeSACKey")
        } else if type == .multipart {
            adaptedRequest.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        }
        if !shouldAddAuthHeader(for: urlRequest) {
            if let accessToken = keychain.getAccessToken() {
                adaptedRequest.setValue("\(accessToken)", forHTTPHeaderField: "Authorization")
            }
        }
        completion(.success(adaptedRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        let isImageRequest = isImageRequest(request)
        
        if let response = request.task?.response as? HTTPURLResponse {
            let statusCode = response.statusCode
            
            // 🔍 이미지 요청의 status code 로깅 (중요!)
            if isImageRequest {
                GTLogger.shared.networkFailure("🖼️ IMAGE REQUEST FAILED - Status Code: \(statusCode), URL: \(request.request?.url?.absoluteString ?? "unknown")", error: error)
                
                // 개발 중에는 콘솔에 명확히 출력
                print("🚨 NUKE IMAGE FAILURE:")
                print("   Status Code: \(statusCode)")
                print("   URL: \(request.request?.url?.absoluteString ?? "unknown")")
                print("   Error: \(error)")
                print("   ==================")
            }
            
            // 일단 넓게 잡아서 테스트 (개발 단계)
            if statusCode == 401 || statusCode == 403 || statusCode == 419 {
                GTLogger.shared.networkRequest("Attempting token refresh for \(isImageRequest ? "image" : "API") request with status: \(statusCode)")
                
                refreshToken { [weak self] result in
                    switch result {
                    case .success:
                        GTLogger.shared.networkSuccess("Token refresh successful, retrying \(isImageRequest ? "image" : "API") request")
                        completion(.retry)
                    case .failure(let refreshError):
                        GTLogger.shared.networkFailure("Token refresh failed", error: refreshError)
                        self?.keychain.deleteAllTokens()
                        completion(.doNotRetryWithError(AuthError.tokenRefreshFailed))
                    }
                }
            } else {
                GTLogger.shared.networkFailure("\(isImageRequest ? "Image" : "API") request failed with status \(statusCode), not retrying", error: error)
                completion(.doNotRetryWithError(error))
            }
        } else {
            // 네트워크 에러 (HTTP 응답 없음)
            if isImageRequest {
                GTLogger.shared.networkFailure("🖼️ IMAGE NETWORK ERROR (no HTTP response): \(error)", error: error)
                print("🚨 NUKE NETWORK ERROR:")
                print("   Error: \(error)")
                print("   URL: \(request.request?.url?.absoluteString ?? "unknown")")
                print("   ==================")
            }
            
            // 네트워크 에러는 토큰 재발급 없이 재시도
            if shouldRetryNetworkError(error) {
                GTLogger.shared.networkRequest("Retrying \(isImageRequest ? "image" : "API") request due to network error")
                completion(.retry)
            } else {
                completion(.doNotRetryWithError(error))
            }
        }
    }
    
    private func isImageRequest(_ request: Request) -> Bool {
        guard let url = request.request?.url else { return false }
        
        // 이미지 파일 확장자 확인
        let pathExtension = url.pathExtension.lowercased()
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "webp", "heic", "heif", "bmp", "tiff"]
        
        if imageExtensions.contains(pathExtension) {
            return true
        }
        
        // 이미지 관련 도메인 확인 (서버에 맞게 수정)
        if let host = url.host {
            return host.contains("image") ||
            host.contains("cdn") ||
            host.contains("photo") ||
            host.contains("pic")
        }
        
        return false
    }
    
    private func shouldRetryNetworkError(_ error: Error) -> Bool {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut, .networkConnectionLost, .notConnectedToInternet, .cannotConnectToHost:
                return true
            default:
                return false
            }
        }
        return false
    }
    
    // 기존 메서드들...
    private func shouldAddAuthHeader(for request: URLRequest) -> Bool {
        let publicEndpoints = [
            "v1/users/login",
            "v1/users/join",
            "v1/users/validation/email",
            "v1/users/login/apple",
            "v1/users/login/kakao",
        ]
        
        guard let url = request.url else { return false }
        let path = url.pathComponents.dropFirst().joined(separator: "/")
        
        return publicEndpoints.contains(path)
    }
    
    private func refreshToken(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let refreshToken = keychain.getRefreshToken() else {
            completion(.failure(AuthError.noTokenFound))
            return
        }
        
        let refreshRequest = RequestDTO.RefreshToken(refreshToken: refreshToken)
        let endpoint = AuthEndPoint.refreshToken(refreshRequest)
        
        AF.request(endpoint, interceptor: GTInterceptor(type: .default))
            .validate(statusCode: 200..<300)
            .responseDecodable(of: ResponseDTO.RefreshToken.self) { [weak self] response in
                switch response.result {
                case .success(let refreshResponse):
                    self?.keychain.saveAccessToken(refreshResponse.accessToken)
                    self?.keychain.saveRefreshToken(refreshResponse.refreshToken)
                    
                    if (self?.keychain.getAccessToken() != nil) && (self?.keychain.getRefreshToken() != nil) {
                        completion(.success(()))
                    } else {
                        completion(.failure(AuthError.tokenSaveFailed))
                    }
                    
                case .failure(let error):
                    GTLogger.shared.networkFailure("Refresh token API call failed", error: error)
                    completion(.failure(error))
                }
            }
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case noTokenFound
    case tokenRefreshFailed
    case tokenSaveFailed
    
    var errorDescription: String? {
        switch self {
        case .noTokenFound: return "저장된 토큰이 없습니다."
        case .tokenRefreshFailed: return "토큰 갱신에 실패했습니다."
        case .tokenSaveFailed: return "토큰 저장에 실패했습니다."
        }
    }
}
