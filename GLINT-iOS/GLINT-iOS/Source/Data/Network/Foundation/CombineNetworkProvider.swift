//
//  CombineNetworkProvider.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/9/25.
//

import Foundation
import Combine

import Alamofire

// MARK: - Combine 기반 Network Provider
final class CombineNetworkProvider: NetworkServiceProvider {

    private let session: Session // Alamofire Session

    init(session: Session = AF) {
        self.session = session
    }

    // MARK: - Decodable 응답 요청
    func request<T: EndPoint, R: Decodable>(
        target: T,
        responseType: R.Type,
        interceptor: RequestInterceptor? = nil
    ) -> AnyPublisher<R, T.ErrorType> {

        Task { try? NetworkLogger.request(target) }

        return session.request(target, interceptor: interceptor)
            .validate(statusCode: 200..<300)
            .publishDecodable(type: R.self, decoder: target.decoder)
            .value()
            .handleEvents(receiveOutput: { _ in
                Task {
                    print("[ℹ️] NETWORK -> response success for \(String(describing: try? target.asURLRequest().url?.absoluteString ?? "N/A"))")
                }
            }, receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    Task {
                        
                        print("[ℹ️] NETWORK -> response failure: \(error.localizedDescription) for \(String(describing: try? target.asURLRequest().url?.absoluteString ?? "N/A"))")
                    }
                }
            })
            .mapError { afError -> T.ErrorType in
                print("AFError occurred: \(afError)")
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
                    if let specificError = retryError as? T.ErrorType {
                        return specificError
                    }
                    return GLError.retryFailed(afError)
                default:
                    return GLError.unknown(afError)
                }
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Void 응답 요청
    func request<T: EndPoint>(
        target: T,
        interceptor: RequestInterceptor? = nil
    ) -> AnyPublisher<Void, T.ErrorType> {

        Task { try? NetworkLogger.request(target) }

        return session.request(target, interceptor: interceptor)
            .validate(statusCode: 200..<300)
            .publishData() // 데이터만 받는 Publisher
            .tryMap { dataResponse -> Void in // DataResponse<Data, AFError>
                Task {
                    print("[ℹ️] NETWORK -> response (Void) for \(String(describing: try? target.asURLRequest().url?.absoluteString ?? "N/A")): status \(dataResponse.response?.statusCode ?? 0)")
                    if let data = dataResponse.data, !data.isEmpty {
                        print("  Body (Void response, but data exists): \(String(data: data, encoding: .utf8) ?? "nil")")
                    }
                }

                if let error = dataResponse.error {
                    if case .responseSerializationFailed(.inputDataNilOrZeroLength) = error,
                       dataResponse.response?.statusCode == 200 {
                        return ()
                    }
                    throw error
                }
                return ()
            }
            .mapError { error -> T.ErrorType in
                print("Error in Void request: \(error)")
                if let afError = error as? AFError {
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
                        if let specificError = retryError as? T.ErrorType {
                            return specificError
                        }
                        return GLError.retryFailed(afError)
                    default:
                        return GLError.unknown(afError)
                    }
                }
                return GLError.unknown(error)
            }
            .eraseToAnyPublisher()
    }
    
}
