//
//  DateFormatterManager.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/10/25.
//

import Foundation

final class DateFormatterManager {
    
    static let shared = DateFormatterManager()
    
    private init() {}
    
    // MARK: - Chat Message Formatters
    
    /// 채팅 시간 포맷터 (오전/오후 h:mm)
    private lazy var chatTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        return formatter
    }()
    
    /// 채팅 날짜 포맷터 (yyyy년 MM월 dd일)
    private lazy var chatDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter
    }()
    
    /// 채팅 날짜 섹션 포맷터 (yyyy-MM-dd)
    private lazy var chatDateSectionFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    /// 채팅 시간 표시 포맷터 (HH:mm)
    private lazy var chatTimeDisplayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    // MARK: - Server Communication Formatters
    
    /// ISO8601 포맷터 (서버 통신용)
    private lazy var iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    /// ISO8601 포맷터 (기본)
    private lazy var iso8601BasicFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    // MARK: - Public Methods
    
    /// 채팅 시간 포맷팅 (오전/오후 h:mm)
    func formatChatTime(_ date: Date) -> String {
        return chatTimeFormatter.string(from: date)
    }
    
    /// 채팅 날짜 포맷팅 (yyyy년 MM월 dd일)
    func formatChatDate(_ date: Date) -> String {
        return chatDateFormatter.string(from: date)
    }
    
    /// 채팅 날짜 섹션 포맷팅 (yyyy-MM-dd)
    func formatChatDateSection(_ date: Date) -> String {
        return chatDateSectionFormatter.string(from: date)
    }
    
    /// 채팅 시간 표시 포맷팅 (HH:mm)
    func formatChatTimeDisplay(_ date: Date) -> String {
        return chatTimeDisplayFormatter.string(from: date)
    }
    
    /// ISO8601 문자열을 Date로 파싱 (여러 포맷 시도)
    func parseISO8601Date(from dateString: String) -> Date? {
        // 먼저 fractional seconds 포함 포맷 시도
        if let date = iso8601Formatter.date(from: dateString) {
            return date
        }
        
        // 기본 포맷 시도
        if let date = iso8601BasicFormatter.date(from: dateString) {
            return date
        }
        
        // 수동 파싱 시도 (서버에서 다른 포맷을 보낼 경우 대비)
        let manualFormatter = DateFormatter()
        manualFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd'T'HH:mm:ssZ"
        ]
        
        for format in formats {
            manualFormatter.dateFormat = format
            if let date = manualFormatter.date(from: dateString) {
                return date
            }
        }
        
        return nil
    }
    
    /// Date를 ISO8601 문자열로 변환
    func formatToISO8601(_ date: Date) -> String {
        return iso8601Formatter.string(from: date)
    }
    
    // MARK: - Utility Methods
    
    /// 같은 분인지 확인
    func isSameMinute(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date1)
        let components2 = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date2)
        
        return components1.year == components2.year &&
               components1.month == components2.month &&
               components1.day == components2.day &&
               components1.hour == components2.hour &&
               components1.minute == components2.minute
    }
    
    /// 같은 날인지 확인
    func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    /// 오늘 특정 시간으로 Date 생성
    func createTimeForToday(hour: Int, minute: Int, second: Int = 0) -> Date {
        let calendar = Calendar.current
        let today = Date()
        
        var components = calendar.dateComponents([.year, .month, .day], from: today)
        components.hour = hour
        components.minute = minute
        components.second = second
        
        return calendar.date(from: components) ?? today
    }
}
