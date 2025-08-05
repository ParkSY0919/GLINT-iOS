//
//  ChatNotifications.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/15/25.
//

import Foundation

/// 채팅 관련 NotificationCenter 알림 정의
/// 모든 채팅 관련 알림을 한 곳에서 관리하여 일관성과 유지보수성 향상
extension Notification.Name {
    
    // MARK: - WebSocket 연결 관련
    /// WebSocket 연결 성공 시 발송
    static let chatWebSocketConnected = Notification.Name("chatWebSocketConnected")
    
    /// WebSocket 연결 해제 시 발송
    static let chatWebSocketDisconnected = Notification.Name("chatWebSocketDisconnected")
    
    // MARK: - 메시지 관련  
    /// 새로운 채팅 메시지 수신 시 발송
    /// UserInfo: roomId, chatId, content, userId, nickname, timestamp, isMyMessage
    static let chatNewMessageReceived = Notification.Name("chatNewMessageReceived")
    
    // MARK: - 네비게이션 관련
    /// FCM 푸시 알림 탭 시 채팅방으로 이동 요청
    /// UserInfo: roomId
    static let chatNavigateToRoom = Notification.Name("chatNavigateToRoom")
}

/// 채팅 알림 관련 유틸리티
struct ChatNotificationHelper {
    
    /// 새 메시지 알림 발송
    static func postNewMessage(
        roomId: String,
        chatId: String, 
        content: String,
        userId: String,
        nickname: String,
        timestamp: TimeInterval,
        isMyMessage: Bool
    ) {
        NotificationCenter.default.post(
            name: .chatNewMessageReceived,
            object: nil,
            userInfo: [
                "roomId": roomId,
                "chatId": chatId,
                "content": content,
                "userId": userId,
                "nickname": nickname,
                "timestamp": timestamp,
                "isMyMessage": isMyMessage
            ]
        )
    }
    
    /// WebSocket 연결 상태 알림 발송
    static func postWebSocketConnected() {
        NotificationCenter.default.post(
            name: .chatWebSocketConnected,
            object: nil
        )
    }
    
    static func postWebSocketDisconnected() {
        NotificationCenter.default.post(
            name: .chatWebSocketDisconnected,
            object: nil
        )
    }
    
    /// 채팅방 이동 요청 알림 발송
    static func postNavigateToRoom(_ roomId: String) {
        NotificationCenter.default.post(
            name: .chatNavigateToRoom,
            object: nil,
            userInfo: ["roomId": roomId]
        )
    }
} 