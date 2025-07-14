//
//  ChatEndPoint.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/9/25.
//

import Foundation

import Alamofire

enum ChatEndPoint {
    case createChatRoom(userID: String)
    case infoChatRooms
    case filesUpload(roomID: String, files: [Data])
    case getChatHistory(roomID: String, next: String)
    case postChatMessage(roomID: String, request: PostChatMessageRequest)
}

extension ChatEndPoint: EndPoint {
    var utilPath: String {
        switch self {
        case .createChatRoom, .infoChatRooms, .filesUpload, .getChatHistory, .postChatMessage:
            return "v1/chats"
        }
    }
    
    var path: String {
        switch self {
        case .createChatRoom, .infoChatRooms:
            return utilPath
        case .filesUpload(let roomID, _):
            return utilPath + "/\(roomID)/files"
        case .getChatHistory(let roomID, _), .postChatMessage(let roomID, _):
            return utilPath + "/\(roomID)"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .createChatRoom, .filesUpload, .postChatMessage:
            return .post
        case .infoChatRooms, .getChatHistory:
            return .get
        }
    }
    
    var requestType: RequestType {
        switch self {
        case .createChatRoom(let userID):
            return .bodyEncodable(["opponent_id": userID])
        case .infoChatRooms:
            return .none
        case .filesUpload(_, let files):
            return .multipartData(MultipartConfig(files: files))
        case .getChatHistory(_, let next):
            switch next == "" {
            case true:
                print("next: none")
                return .none
            case false:
                print("next: \(next)")
                return .queryEncodable(next)
            }
            
        case .postChatMessage(_, let request):
            return .bodyEncodable(request)
        }
    }
}
