//
//  EndPoint.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/9/25.
//

import Foundation

import Alamofire

protocol EndPoint: URLRequestConvertible {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var requestType: RequestType { get }
    var decoder: JSONDecoder { get }
    
//    associatedtype ErrorType: Error // 각 Target별로 특정 에러 타입을 정의할 수 있도록
    associatedtype ErrorType: Error where ErrorType == GLError
    func throwError(_ error: AFError) -> GLError
}

extension EndPoint {
    var baseURL: URL {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: Config.Keys.baseURL) as? String,
              let url = URL(string: urlString) else {
            fatalError("🚨BASE_URL을 찾을 수 없습니다🚨")
        }
        return url
    }
    
    var encoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        // 필요한 디코딩 전략 설정
        return decoder
    }

    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers?.dictionary
        
        switch requestType {
        case .queryEncodable(let encodableParams):
            return try URLEncoding.queryString.encode(request, with: encodableParams?.toDictionary())
        case .bodyEncodable(let encodableParams):
            return try JSONEncoding.default.encode(request, with: encodableParams?.toDictionary())
        case .none:
            return request
        }
    }
    
    typealias ErrorType = GLError
    
    func throwError(_ error: Alamofire.AFError) -> GLError {
        switch error {
        case .responseValidationFailed(let reason):
            if case .unacceptableStatusCode(let code) = reason {
                switch code {
                case 401:
                    return .e401
                case 403:
                    return .e403
                case 419:
                    return .e419
                case 420:
                    return .e420
                case 429:
                    return .e429
                case 444:
                    return .e444
                case 500:
                    return .e500
                default:
                    return .unknown(error)
                }
            }
        case .responseSerializationFailed:
            return .networkFailure(error)
        default:
            return .unknown(error)
        }
        return .unknown(error)
    }
}

extension Encodable {
    func toDictionary() -> [String: Any]? { // 반환 타입을 옵셔널로 변경 (실패 가능성)
        do {
            let data = try JSONEncoder().encode(self)
            let jsonData = try JSONSerialization.jsonObject(with: data)
            return jsonData as? [String: Any]
        } catch {
            print("Error encoding to dictionary: \(error)")
            return nil // 인코딩 실패 시 nil 반환
        }
    }
}
