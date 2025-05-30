//
//  UserRepository+LiveValue.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/15/25.
//

import Foundation

import Alamofire

extension AuthRepository: NetworkServiceProvider {
    typealias E = AuthEndPoint
    
    static let liveValue: AuthRepository = {
        
        return AuthRepository(
            checkEmailValidation: { request in
                let endPoint = AuthEndPoint.checkEmailValidation(request)
                try await Self.requestNonToken(endPoint)
            },
            signUp: { request in
                let endPoint = AuthEndPoint.signUp(request)
                return try await Self.requestNonToken(endPoint)
            },
            signIn: { request in
                let endPoint = AuthEndPoint.signIn(request)
                return try await Self.requestNonToken(endPoint)
            },
            signInApple: { request in
                let endPoint = AuthEndPoint.signInForApple(request)
                return try await Self.requestNonToken(endPoint)
            },
            signInKakao: { request in
                let endPoint = AuthEndPoint.signInForKakao(request)
                return try await Self.requestNonToken(endPoint)
            }
        )
    }()
}
