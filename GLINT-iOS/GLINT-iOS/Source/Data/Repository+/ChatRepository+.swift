//
//  ChatRepository+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/9/25.
//

import Foundation

extension ChatRepository {
    static let liveValue: ChatRepository = {
        let provider = NetworkService<ChatEndPoint>()
        
        return ChatRepository(
            postChats: { userID in
                return try await provider.request(.postChats(userID: userID))
            },
            getChats: {
                return try await provider.request(.getChats)
            }
            
        )
    }()
}
