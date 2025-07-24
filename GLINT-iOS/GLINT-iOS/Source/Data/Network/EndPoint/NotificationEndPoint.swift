//
//  NotificationEndPoint.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/24/25.
//

import Foundation

import Alamofire

enum NotificationEndPoint {
    case push(PushRequest)
}

extension NotificationEndPoint: EndPoint {
    var utilPath: String {
        switch self {
        case .push:
            return "v1/notifications/"
        }
    }
    
    var path: String {
        switch self {
        case .push:
            return utilPath + "push/group"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .push:
            return .post
        }
    }
    
    var requestType: RequestType {
        switch self {
        case .push(let pushRequest):
            return .bodyEncodable(pushRequest)
        }
    }
}
