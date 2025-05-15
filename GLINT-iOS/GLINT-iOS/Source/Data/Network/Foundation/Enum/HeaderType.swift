//
//  HeaderType.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/15/25.
//

import Alamofire

enum HeaderType {
    static var basic: HTTPHeaders {
        return [
            "Content-Type": "application/json",
            "SeSACKey": Config.Keys.sesacKey
        ]
    }
    
    static func withAccessToken(token: String) -> HTTPHeaders {
        return [
            "Content-Type": "application/json",
            "SeSACKey": Config.Keys.sesacKey,
            "Authorization": token
        ]
    }
}
