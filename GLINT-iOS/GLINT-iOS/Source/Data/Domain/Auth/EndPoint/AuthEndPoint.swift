//
//  AuthEndPoint.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/13/25.
//

import Foundation

import Alamofire

enum AuthEndPoint {
    case postCheckEmailValidation(CheckEmailValidationRequest)
}

extension AuthEndPoint: TargetTypeProtocol {
    
//    var url: URL? { get }
//    var baseURL: String { get }
//    var utilPath: String { get }
//    var method: HTTPMethod { get }
//    var header: HTTPHeaders { get }
//    var parameters: RequestParams? { get }
    
    
    var utilPath: String {
        return "v1/users/"
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .postCheckEmailValidation: .post
        }
    }
    
    var path: String {
        switch self {
        case .postCheckEmailValidation:
            return utilPath + "validation/email"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .postCheckEmailValidation(let request):
            return .query
        }
    }
    
    
}

