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
                try await provider.request(target: endPoint, interceptor: nil).awaitCompletion()
            },
            signUp: { request in
                let endPoint = UserEndPoint.signUp(request)
                return try await provider.request(target: endPoint, responseType: SignUpResponse.self, interceptor: nil).firstValue()
            }
        )
    }()
}




