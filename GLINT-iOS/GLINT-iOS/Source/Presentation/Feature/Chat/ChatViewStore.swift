//
//  ChatViewStore.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/8/25.
//

import SwiftUI

struct ChatViewState {
    var messages: [ChatMessage] = []
    var newMessage: String = ""
    var roomID: String = ""
    var isLoading: Bool = false
}

enum ChatViewAction {
    case viewAppeared
    case messageTextChanged(String)
    case sendButtonTapped
    case backButtonTapped
}

@MainActor
@Observable
final class ChatViewStore {
    private(set) var state = ChatViewState()
    private let router: NavigationRouter<MainTabRoute>
    
    init(router: NavigationRouter<MainTabRoute>, roomID: String) {
        self.router = router
        self.state.roomID = roomID
        
        // 초기화 시점에 더미데이터 로드
        print("🔵 ChatViewStore 초기화 - 더미데이터 로드 시작")
        loadDummyData()
    }
    
    func send(_ action: ChatViewAction) {
        switch action {
        case .viewAppeared:
            handleViewAppeared()
            
        case .messageTextChanged(let text):
            state.newMessage = text
            
        case .sendButtonTapped:
            handleSendMessage()
            
        case .backButtonTapped:
            router.pop()
        }
    }
    
    private func loadDummyData() {
        print("🔵 loadDummyData 호출됨")
        let sortedMessages = ChatMessage.dummyMessages.sorted { $0.timestamp < $1.timestamp }
        print("🔵 정렬된 메시지 개수: \(sortedMessages.count)")
        
        state.messages = sortedMessages
        print("🔵 state.messages 업데이트 완료: \(state.messages.count)개")
    }
}

private extension ChatViewStore {
    func handleViewAppeared() {
        print("🔵 ChatViewStore: handleViewAppeared 호출됨")
        print("🔵 현재 state.messages 개수: \(state.messages.count)")
        
        // 혹시 더미데이터가 로드되지 않았다면 다시 로드
        if state.messages.isEmpty {
            print("🔵 더미데이터가 비어있음, 다시 로드")
            loadDummyData()
        }
    }
    
    func handleSendMessage() {
        guard !state.newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newMessage = ChatMessage(
            content: state.newMessage.trimmingCharacters(in: .whitespacesAndNewlines),
            senderId: "me",
            senderName: "나",
            timestamp: Date(),
            isFromMe: true
        )
        
        state.messages.append(newMessage)
        state.newMessage = ""
        
        // 키보드 숨기기
        hideKeyboard()
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
} 
