//
//  MessageGroup.swift
//  GLINT-iOS
//
//  Created by Claude on 8/9/25.
//

import Foundation

// MARK: - MessageGroup
struct MessageGroup: Identifiable, Equatable {
    let id: String
    let timestamp: Date
    let senderId: String
    let senderName: String
    let isFromMe: Bool
    let messages: [ChatMessage]
    
    init(messages: [ChatMessage]) {
        // 첫 번째 메시지 기준으로 그룹 정보 설정
        guard let firstMessage = messages.first else {
            // 빈 메시지 그룹의 경우 키체인에서 현재 사용자 정보 가져와서 안전한 기본값 설정
            let keychain = KeychainManager.shared
            let currentUserId = keychain.getUserId() ?? ""
            let currentUserNickname = keychain.getNickname() ?? ""
            
            self.id = UUID().uuidString
            self.timestamp = Date()
            self.senderId = currentUserId
            self.senderName = currentUserNickname
            self.isFromMe = !currentUserNickname.isEmpty // 유효한 닉네임이 있으면 내 메시지로 가정
            self.messages = []
            
            print("⚠️ MessageGroup: 빈 메시지 배열로 초기화, 기본값으로 isFromMe = \(self.isFromMe)")
            return
        }
        
        self.id = firstMessage.id + "_group"
        self.timestamp = firstMessage.timestamp
        self.senderId = firstMessage.senderId
        self.senderName = firstMessage.senderName
        self.isFromMe = firstMessage.isFromMe
        self.messages = messages.sorted { $0.timestamp < $1.timestamp }
        
        // 디버깅 로그 추가
        print("📋 MessageGroup 생성 - 발신자: \(self.senderId), isFromMe: \(self.isFromMe), 메시지 수: \(messages.count)")
    }
    
    /// 그룹의 마지막 메시지 시간 (시간 표시용)
    var lastMessageTimestamp: Date {
        return messages.last?.timestamp ?? timestamp
    }
    
    /// 그룹 내 모든 이미지들
    var allImages: [String] {
        return messages.flatMap { $0.images }
    }
    
    /// 텍스트가 있는 메시지들만
    var textMessages: [ChatMessage] {
        return messages.filter { !$0.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
    
    /// 이미지가 있는 메시지들만
    var imageMessages: [ChatMessage] {
        return messages.filter { !$0.images.isEmpty }
    }
    
    /// 그룹 내 메시지가 모두 같은 시간대인지 확인
    var isSameTimeGroup: Bool {
        guard messages.count > 1 else { return true }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let firstTime = formatter.string(from: messages.first!.timestamp)
        return messages.allSatisfy { formatter.string(from: $0.timestamp) == firstTime }
    }
}

// MARK: - MessageGroupFactory
struct MessageGroupFactory {
    /// ChatMessage 배열을 MessageGroup 배열로 변환 (시간 그룹화)
    static func createMessageGroups(from messages: [ChatMessage], timeIntervalThreshold: TimeInterval = 60) -> [MessageGroup] {
        guard !messages.isEmpty else { return [] }
        
        let sortedMessages = messages.sorted { $0.timestamp < $1.timestamp }
        var groups: [MessageGroup] = []
        var currentGroupMessages: [ChatMessage] = []
        
        for message in sortedMessages {
            if shouldStartNewGroup(
                currentGroup: currentGroupMessages,
                newMessage: message,
                timeThreshold: timeIntervalThreshold
            ) {
                // 이전 그룹 완성
                if !currentGroupMessages.isEmpty {
                    groups.append(MessageGroup(messages: currentGroupMessages))
                }
                // 새 그룹 시작
                currentGroupMessages = [message]
            } else {
                // 현재 그룹에 추가
                currentGroupMessages.append(message)
            }
        }
        
        // 마지막 그룹 추가
        if !currentGroupMessages.isEmpty {
            groups.append(MessageGroup(messages: currentGroupMessages))
        }
        
        print("📱 메시지 그룹화 완료: \(messages.count)개 메시지 → \(groups.count)개 그룹")
        return groups
    }
    
    /// 새로운 그룹을 시작해야 하는지 판단
    private static func shouldStartNewGroup(
        currentGroup: [ChatMessage],
        newMessage: ChatMessage,
        timeThreshold: TimeInterval
    ) -> Bool {
        // 첫 번째 메시지면 새 그룹 시작
        guard let lastMessage = currentGroup.last else { return false }
        
        // 발신자가 다르면 새 그룹
        if lastMessage.senderId != newMessage.senderId {
            return true
        }
        
        // 시간 간격이 임계값보다 크면 새 그룹
        let timeInterval = newMessage.timestamp.timeIntervalSince(lastMessage.timestamp)
        if timeInterval > timeThreshold {
            return true
        }
        
        return false
    }
}

// MARK: - Extensions
extension MessageGroup {
    /// 날짜별로 그룹화된 메시지 그룹들을 반환
    static func groupedByDate(_ messageGroups: [MessageGroup]) -> [(String, [MessageGroup])] {
        let grouped = Dictionary(grouping: messageGroups) { group in
            group.messages.first?.formattedDate ?? ""
        }
        
        return grouped.map { (date, groups) in
            (date, groups.sorted { $0.timestamp < $1.timestamp })
        }.sorted { group1, group2 in
            guard let date1 = group1.1.first?.timestamp,
                  let date2 = group2.1.first?.timestamp else { return false }
            return date1 < date2
        }
    }
    
    /// 그룹 내 마지막 메시지의 포맷된 시간
    var formattedTime: String {
        return messages.last?.formattedTime ?? ""
    }
}