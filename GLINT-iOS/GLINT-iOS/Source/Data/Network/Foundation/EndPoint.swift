//
//  EndPoint.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/9/25.
//

import Foundation

import Alamofire

protocol EndPoint: URLRequestConvertible {
    var baseURL: String { get }
    var headers: HTTPHeaders { get }
    var utilPath: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var decoder: JSONDecoder { get }
    var requestType: RequestType { get }
    
    associatedtype ErrorType: Error where ErrorType == GLError
    func throwError(_ error: AFError) -> GLError
}

extension EndPoint {
    var baseURL: String {
        return Config.baseURL
    }
    
    var headers: HTTPHeaders {
        return HeaderType.basic
    }
    
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        // 필요한 디코딩 전략 설정
        return decoder
    }

    func asURLRequest() throws -> URLRequest {
        var request = URLRequest(url: URL(string: baseURL + path)!)
        request.method = method
        request.headers = headers
        
        switch requestType {
        case .queryEncodable(let parameters):
            if let parameters = parameters {
                request = try URLEncodedFormParameterEncoder.default.encode(parameters, into: request)
            }
            
        case .bodyEncodable(let parameters):
            if let parameters = parameters {
                request = try JSONParameterEncoder.default.encode(parameters, into: request)
            }
            
        case .none, .multipartData:
            break
        }
        
        return request
    }
    
    func throwError(_ error: Alamofire.AFError) -> GLError {
        switch error {
        case .responseValidationFailed(let reason):
            if case .unacceptableStatusCode(let code) = reason {
                switch code {
                case 401: return .e401
                case 403: return .e403
                case 419: return .e419
                case 420: return .e420
                case 429: return .e429
                case 444: return .e444
                case 500: return .e500
                default: return .unknown(error)
                }
            }
        case .responseSerializationFailed: return .networkFailure(error)
        default: return .unknown(error)
        }
        return .unknown(error)
    }
}
