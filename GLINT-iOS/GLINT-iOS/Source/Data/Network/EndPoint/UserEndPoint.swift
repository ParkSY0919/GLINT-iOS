//
//  UserEndPoint.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/13/25.
//

import Foundation

import Alamofire

enum UserEndPoint {
    case checkEmailValidation(CheckEmailValidationRequest)
    case signUp(SignUpRequest)
}

extension UserEndPoint: EndPoint {
    var headers: Alamofire.HTTPHeaders? {
        switch self {
        case .checkEmailValidation, .signUp:
            return HeaderType.basic
        }
    }
    
    var utilPath: String {
        return "v1/users/"
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .checkEmailValidation, .signUp: .post
        }
    }
    
    var path: String {
        switch self {
        case .checkEmailValidation: utilPath + "validation/email"
        case .signUp: utilPath + "join"
        }
    }
    
    var requestType: RequestType {
        switch self {
        case .checkEmailValidation(let request):
            return .bodyEncodable(request)
        case .signUp(let reuqest):
            return .bodyEncodable(reuqest)
        }
    }
    
}

