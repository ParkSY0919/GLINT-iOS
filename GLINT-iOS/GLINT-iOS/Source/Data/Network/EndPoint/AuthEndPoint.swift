//
//  AuthEndPoint.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/27/25.
//

import Foundation

import Alamofire

enum AuthEndpoint {
    case refreshToken(RefreshTokenRequest)
}

extension AuthEndpoint: EndPoint {
    var headers: HTTPHeaders? {
        return HeaderType.basic
    }
    
    var utilPath: String {
        return "v1/auth/"
    }
    
    var method: HTTPMethod {
        switch self {
        case .refreshToken: return .post
        }
    }
    
    var path: String {
        switch self {
        case .refreshToken: utilPath + "refresh"
        }
    }
    
    var requestType: RequestType {
        switch self {
        case .refreshToken(let request):
            return .bodyEncodable(request)
        }
    }
}
