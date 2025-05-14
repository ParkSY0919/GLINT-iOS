//
//  TargetTypeProtocol.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/9/25.
//

import Foundation

import Alamofire

protocol TargetTypeProtocol: URLRequestConvertible {
    associatedtype ErrorType: Error
    
    var method: HTTPMethod { get }
    var header: HTTPHeaders { get }
    var utilPath: String { get }
    var parameters: RequestParams? { get }
    var encoding: ParameterEncoding { get }
    
    func throwError(_ error: AFError) -> ErrorType
}

enum RequestParams {
    case query(_ parameter: Encodable?)
    case body(_ parameter: Encodable?)
}

extension TargetTypeProtocol {
    
    func asURLRequest() throws -> URLRequest {
        var url = baseURL
        if !utilPath.isEmpty {
            url.appendPathComponent(utilPath)
        }
        var urlRequest = try URLRequest(url: url, method: method)
        urlRequest.headers = header

        switch parameters {
        case let .query(request):
            let params = request?.toDictionary() ?? [:]
            return try encoding.encode(urlRequest, with: params)
        case let .body(request):
            let params = request?.toDictionary() ?? [:]
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
            return try encoding.encode(urlRequest, with: nil)
        case .none:
            return urlRequest
        }
    }
    
    var baseURL: URL {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: Config.Keys.baseURL) as? String,
              let url = URL(string: urlString) else {
            fatalError("🚨BASE_URL을 찾을 수 없습니다🚨")
        }
        return url
    }
    
    var headers: [String : String]? {
        let headers = ["Content-Type" : "application/json"]
        return headers
    }
    
    
}

extension Encodable {
    
    func toDictionary() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self),
              let jsonData = try? JSONSerialization.jsonObject(with: data),
              let dictionaryData = jsonData as? [String: Any] else { return [:] }
        return dictionaryData
    }
    
}
