//
//  AuthEndPoint.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/13/25.
//

import Foundation

import Alamofire

enum AuthEndPoint {
    case checkEmailValidation(email: String)
    case signUp(SignUpDTO.Request)
    case signIn(SignInDTO.Request)
    case signInForApple(SignInAppleDTO.Request)
    case signInForKakao(SignInKakaoDTO.Request)
    case refreshToken(RequestDTO.RefreshToken)
}

extension AuthEndPoint: EndPoint {
    var utilPath: String {
        switch self {
        case .checkEmailValidation, .signUp, .signIn, .signInForApple, .signInForKakao:
            return "v1/users/"
        case .refreshToken:
            return "v1/auth/"
        }
    }
    
    var path: String {
        switch self {
        case .checkEmailValidation: utilPath + "validation/email"
        case .signUp: utilPath + "join"
        case .signIn: utilPath + "login"
        case .signInForApple: utilPath + "login/apple"
        case .signInForKakao: utilPath + "login/kakao"
        case .refreshToken: utilPath + "refresh"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .checkEmailValidation, .signUp, .signIn, .signInForApple, .signInForKakao: return .post
        case .refreshToken:
            return .get
        }
    }
    
    var requestType: RequestType {
        switch self {
        case .checkEmailValidation(let email):
            return .bodyEncodable(["email": email])
        case .signUp(let reuqest):
            return .bodyEncodable(reuqest)
        case .signIn(let reuqest):
            return .bodyEncodable(reuqest)
        case .signInForApple(let reuqest):
            return .bodyEncodable(reuqest)
        case .signInForKakao(let reuqest):
            return .bodyEncodable(reuqest)
        case .refreshToken(let request):
            return .bodyEncodable(request)
        }
    }
    
}

