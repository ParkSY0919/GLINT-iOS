//
//  ChatMessage.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/8/25.
//

import Foundation

struct ChatMessage: Identifiable, Hashable {
    let id: String
    let content: String
    let senderId: String
    let senderName: String
    let timestamp: Date
    let isFromMe: Bool
    
    init(id: String = UUID().uuidString, content: String, senderId: String, senderName: String, timestamp: Date, isFromMe: Bool) {
        self.id = id
        self.content = content
        self.senderId = senderId
        self.senderName = senderName
        self.timestamp = timestamp
        self.isFromMe = isFromMe
    }
}

extension ChatMessage {
    /// 시간 포맷팅 (오전/오후 시:분)
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        return formatter.string(from: timestamp)
    }
    
    /// 날짜 포맷팅 (YYYY년 MM월 DD일)
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter.string(from: timestamp)
    }
    
    /// 같은 시간대 메시지인지 확인
    func isSameTimeAs(_ other: ChatMessage) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self.timestamp)
        let components2 = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: other.timestamp)
        
        return components1.year == components2.year &&
               components1.month == components2.month &&
               components1.day == components2.day &&
               components1.hour == components2.hour &&
               components1.minute == components2.minute
    }
    
    /// 같은 날짜인지 확인
    func isSameDateAs(_ other: ChatMessage) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self.timestamp, inSameDayAs: other.timestamp)
    }
}

// MARK: - 더미 데이터
extension ChatMessage {
    static let dummyMessages: [ChatMessage] = [
        ChatMessage(
            content: "안녕하세요! 필터 정말 예쁘네요.",
            senderId: "other",
            senderName: "김작가",
            timestamp: Date().addingTimeInterval(-3600 * 24), // 1일 전
            isFromMe: false
        ),
        ChatMessage(
            content: "감사합니다! 정말 열심히 만들었어요.",
            senderId: "me",
            senderName: "나",
            timestamp: Date().addingTimeInterval(-3600 * 24 + 300), // 1일 전 + 5분
            isFromMe: true
        ),
        ChatMessage(
            content: "혹시 이 필터는 어떤 카메라로 촬영하신 건가요?",
            senderId: "other",
            senderName: "김작가",
            timestamp: Date().addingTimeInterval(-3600 * 24 + 600), // 1일 전 + 10분
            isFromMe: false
        ),
        ChatMessage(
            content: "iPhone 15 Pro로 촬영했습니다! 야경 모드를 사용했어요.",
            senderId: "me",
            senderName: "나",
            timestamp: Date().addingTimeInterval(-3600 * 24 + 900), // 1일 전 + 15분
            isFromMe: true
        ),
        
        // 같은 시간에 온 메시지들 (오늘 오전 10:30)
        ChatMessage(
            content: "오늘 날씨가 정말 좋네요!",
            senderId: "other",
            senderName: "김작가",
            timestamp: createTimeForToday(hour: 10, minute: 30, second: 0),
            isFromMe: false
        ),
        ChatMessage(
            content: "맞아요! 사진 찍기 좋은 날씨입니다.",
            senderId: "me",
            senderName: "나",
            timestamp: createTimeForToday(hour: 10, minute: 30, second: 10),
            isFromMe: true
        ),
        ChatMessage(
            content: "특히 이런 날에는 자연 필터가 잘 어울려요",
            senderId: "me",
            senderName: "나",
            timestamp: createTimeForToday(hour: 10, minute: 30, second: 20),
            isFromMe: true
        ),
        ChatMessage(
            content: "네, 정말 그런 것 같아요!",
            senderId: "other",
            senderName: "김작가",
            timestamp: createTimeForToday(hour: 10, minute: 30, second: 30),
            isFromMe: false
        ),
        
        // 다른 시간 (오전 11:15)
        ChatMessage(
            content: "다음에 또 좋은 필터 기대할게요!",
            senderId: "other",
            senderName: "김작가",
            timestamp: createTimeForToday(hour: 11, minute: 15, second: 0),
            isFromMe: false
        ),
        
        // 같은 시간에 온 메시지들 (오후 2:45)
        ChatMessage(
            content: "네, 열심히 만들어볼게요!",
            senderId: "me",
            senderName: "나",
            timestamp: createTimeForToday(hour: 14, minute: 45, second: 0),
            isFromMe: true
        ),
        ChatMessage(
            content: "감사합니다 😊",
            senderId: "me",
            senderName: "나",
            timestamp: createTimeForToday(hour: 14, minute: 45, second: 5),
            isFromMe: true
        ),
        ChatMessage(
            content: "항상 응원하고 있어요!",
            senderId: "other",
            senderName: "김작가",
            timestamp: createTimeForToday(hour: 14, minute: 45, second: 10),
            isFromMe: false
        ),
        ChatMessage(
            content: "정말 감사해요 🙏",
            senderId: "me",
            senderName: "나",
            timestamp: createTimeForToday(hour: 14, minute: 45, second: 15),
            isFromMe: true
        ),
        
        // 최근 메시지 (방금 전)
        ChatMessage(
            content: "새로운 필터 작업 중이에요!",
            senderId: "me",
            senderName: "나",
            timestamp: Date().addingTimeInterval(-60), // 1분 전
            isFromMe: true
        )
    ]
    
    // 오늘 특정 시간으로 Date 생성 헬퍼 메서드
    private static func createTimeForToday(hour: Int, minute: Int, second: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        
        var components = calendar.dateComponents([.year, .month, .day], from: today)
        components.hour = hour
        components.minute = minute
        components.second = second
        
        return calendar.date(from: components) ?? today
    }
} 
