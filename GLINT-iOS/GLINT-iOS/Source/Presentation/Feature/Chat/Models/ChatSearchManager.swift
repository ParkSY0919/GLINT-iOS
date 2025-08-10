//
//  ChatSearchManager.swift
//  GLINT-iOS
//
//  Created by Claude on 8/9/25.
//

import Foundation
import CoreData

// MARK: - SearchResult
struct ChatSearchResult: Identifiable, Equatable {
    let id: String
    let messageId: String
    let content: String
    let senderId: String
    let senderName: String
    let timestamp: Date
    let isFromMe: Bool
    let roomId: String
    
    init(from gtChat: GTChat, currentUserNickname: String) {
        self.id = gtChat.chatId ?? UUID().uuidString
        self.messageId = gtChat.chatId ?? UUID().uuidString
        self.content = gtChat.content ?? ""
        self.senderId = gtChat.sender?.userId ?? ""
        self.senderName = gtChat.sender?.nickname ?? "Unknown"
        self.timestamp = gtChat.createdAt ?? Date()
        self.isFromMe = (gtChat.sender?.nickname ?? "") == currentUserNickname
        self.roomId = gtChat.roomId ?? ""
    }
}

// MARK: - ChatSearchManager
@Observable
class ChatSearchManager {
    private let coreDataManager = CoreDataManager.shared
    
    // MARK: - State
    var searchResults: [ChatSearchResult] = []
    var currentSearchQuery: String = ""
    var currentResultIndex: Int = 0
    var isSearching: Bool = false
    
    // MARK: - Computed Properties
    var totalResultsCount: Int {
        return searchResults.count
    }
    
    var hasResults: Bool {
        return !searchResults.isEmpty
    }
    
    var currentResult: ChatSearchResult? {
        guard currentResultIndex >= 0 && currentResultIndex < searchResults.count else { return nil }
        return searchResults[currentResultIndex]
    }
    
    var canNavigatePrevious: Bool {
        return currentResultIndex > 0
    }
    
    var canNavigateNext: Bool {
        return currentResultIndex < searchResults.count - 1
    }
    
    // MARK: - Search Methods
    
    /// 메시지 검색 수행
    func searchMessages(query: String, roomId: String, currentUserNickname: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            clearSearch()
            return
        }
        
        currentSearchQuery = query
        isSearching = true
        
        Task {
            let results = await performSearch(query: query, roomId: roomId, currentUserNickname: currentUserNickname)
            
            await MainActor.run {
                self.searchResults = results
                self.currentResultIndex = 0
                self.isSearching = false
                
                print("🔍 검색 완료: '\(query)' - \(results.count)개 결과")
            }
        }
    }
    
    /// 실제 검색 수행 (백그라운드)
    private func performSearch(query: String, roomId: String, currentUserNickname: String) async -> [ChatSearchResult] {
        let request: NSFetchRequest<GTChat> = GTChat.fetchRequest()
        
        // 검색 조건: 방 ID 일치 + 메시지 내용에 검색어 포함
        let roomPredicate = NSPredicate(format: "roomId == %@", roomId)
        let contentPredicate = NSPredicate(format: "content CONTAINS[cd] %@", query)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [roomPredicate, contentPredicate])
        
        // 최신순 정렬
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let gtChats = try coreDataManager.context.fetch(request)
            return gtChats.map { ChatSearchResult(from: $0, currentUserNickname: currentUserNickname) }
        } catch {
            print("❌ 메시지 검색 실패: \(error)")
            return []
        }
    }
    
    // MARK: - Navigation Methods
    
    /// 이전 검색 결과로 이동
    func navigateToPrevious() {
        guard canNavigatePrevious else { return }
        currentResultIndex -= 1
        print("🔍 이전 결과로 이동: \(currentResultIndex + 1)/\(totalResultsCount)")
    }
    
    /// 다음 검색 결과로 이동
    func navigateToNext() {
        guard canNavigateNext else { return }
        currentResultIndex += 1
        print("🔍 다음 결과로 이동: \(currentResultIndex + 1)/\(totalResultsCount)")
    }
    
    /// 특정 인덱스로 이동
    func navigateToIndex(_ index: Int) {
        guard index >= 0 && index < searchResults.count else { return }
        currentResultIndex = index
        print("🔍 결과 \(index + 1)/\(totalResultsCount)로 이동")
    }
    
    // MARK: - Utility Methods
    
    /// 검색 초기화
    func clearSearch() {
        searchResults.removeAll()
        currentSearchQuery = ""
        currentResultIndex = 0
        isSearching = false
        print("🔍 검색 초기화")
    }
    
    /// 검색어가 변경되었는지 확인
    func shouldUpdateSearch(for newQuery: String) -> Bool {
        let trimmedQuery = newQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedQuery != currentSearchQuery
    }
    
    /// 검색 결과에서 특정 메시지 찾기
    func findResultIndex(for messageId: String) -> Int? {
        return searchResults.firstIndex { $0.messageId == messageId }
    }
}

// MARK: - Extensions
extension ChatSearchManager {
    /// 검색 결과 상태 텍스트
    var searchStatusText: String {
        if isSearching {
            return "검색 중..."
        } else if searchResults.isEmpty && !currentSearchQuery.isEmpty {
            return "검색 결과 없음"
        } else if hasResults {
            return "\(currentResultIndex + 1)/\(totalResultsCount)"
        } else {
            return ""
        }
    }
    
    /// 현재 검색 결과의 ChatMessage 생성
    var currentResultAsChatMessage: ChatMessage? {
        guard let result = currentResult else { return nil }
        
        return ChatMessage(
            id: result.messageId,
            content: result.content,
            senderId: result.senderId,
            senderName: result.senderName,
            timestamp: result.timestamp,
            isFromMe: result.isFromMe,
            images: [] // 검색에서는 이미지 정보 생략
        )
    }
}