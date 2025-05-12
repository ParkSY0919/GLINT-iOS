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
    
    var url: URL? { get }
    var baseURL: String { get }
    var utilPath: String { get }
    var method: HTTPMethod { get }
    var header: HTTPHeaders { get }
    var parameters: RequestParams? { get }
    
    func throwError(_ error: AFError) -> ErrorType
}

enum RequestParams {
    case query(_ parameter: Encodable?)
    case body(_ parameter: Encodable?)
}

extension Encodable {
    
    func toDictionary() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self),
              let jsonData = try? JSONSerialization.jsonObject(with: data),
              let dictionaryData = jsonData as? [String: Any] else { return [:] }
        return dictionaryData
    }
    
}
