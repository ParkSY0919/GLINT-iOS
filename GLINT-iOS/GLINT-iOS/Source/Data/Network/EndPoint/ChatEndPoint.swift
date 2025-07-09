//
//  ChatEndPoint.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/9/25.
//

import Foundation

import Alamofire

enum ChatEndPoint {
    case postChats(userID: String)
    case getChats
}

extension ChatEndPoint: EndPoint {
    var utilPath: String {
        switch self {
        case .postChats, .getChats: "v1/chats"
        }
    }
    
    var path: String {
        switch self {
        case .postChats, .getChats: utilPath
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .postChats: .post
        case .getChats: .get
        }
    }
    
    var requestType: RequestType {
        switch self {
        case .postChats(let userID):
            return .bodyEncodable(["opponent_id": userID])
        case .getChats:
            return .none
        }
    }
}
