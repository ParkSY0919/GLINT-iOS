//
//  UserRepository+LiveValue.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/15/25.
//

import Foundation

import Alamofire

extension UserRepository {
    static let liveValue: UserRepository = {
        let provider: NetworkServiceProvider = CombineNetworkProvider()
        
        return UserRepository(
            checkEmailValidation: { request in
                let endPoint = UserEndPoint.checkEmailValidation(request)
                // 이메일 검증은 인증이 필요 없으므로 인터셉터 없이 요청
                try await provider.requestWithoutAuth(target: endPoint)
            },
            signUp: { request in
                let endPoint = UserEndPoint.signUp(request)
                // 회원가입도 인증이 필요 없으므로 인터셉터 없이 요청
                return try await provider.requestWithoutAuth(target: endPoint, responseType: SignUpResponse.self)
            },
            signIn: { request in
                let endPoint = UserEndPoint.signIn(request)
                // 로그인도 인증이 필요 없으므로 인터셉터 없이 요청
                return try await provider.requestWithoutAuth(target: endPoint, responseType: SignInResponse.self)
            },
            signInApple: { request in
                let endPoint = UserEndPoint.signInForApple(request)
                return try await provider.requestWithoutAuth(target: endPoint, responseType: SignInResponse.self)
            },
            signInKakao: { request in
                let endPoint = UserEndPoint.signInForKakao(request)
                return try await provider.requestWithoutAuth(target: endPoint, responseType: SignInResponse.self)
            }
        )
    }()
}
