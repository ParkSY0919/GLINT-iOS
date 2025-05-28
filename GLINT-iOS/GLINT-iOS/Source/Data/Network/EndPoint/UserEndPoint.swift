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
    case signIn(SignInRequest)
    case signInForApple(SignInRequestForApple)
    case signInForKakao(SignInRequestForKakao)
//    case todayArtist
}

extension UserEndPoint: EndPoint {
    var headers: Alamofire.HTTPHeaders? {
        switch self {
        case .checkEmailValidation, .signUp, .signIn, .signInForApple, .signInForKakao:
            return HeaderType.basic
        }
    }
    
    var utilPath: String {
        return "v1/users/"
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .checkEmailValidation, .signUp, .signIn, .signInForApple, .signInForKakao: .post
        }
    }
    
    var path: String {
        switch self {
        case .checkEmailValidation: utilPath + "validation/email"
        case .signUp: utilPath + "join"
        case .signIn: utilPath + "login"
        case .signInForApple: utilPath + "login/apple"
        case .signInForKakao: utilPath + "login/kakao"
        }
    }
    
    var requestType: RequestType {
        switch self {
        case .checkEmailValidation(let request):
            return .bodyEncodable(request)
        case .signUp(let reuqest):
            return .bodyEncodable(reuqest)
        case .signIn(let reuqest):
            return .bodyEncodable(reuqest)
        case .signInForApple(let reuqest):
            return .bodyEncodable(reuqest)
        case .signInForKakao(let reuqest):
            return .bodyEncodable(reuqest)
        }
    }
    
}

