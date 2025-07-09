//
//  ChatViewStore.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/8/25.
//

import SwiftUI

struct ChatViewState {
    var roomID: String = ""
    var next: String? = ""
    var navTitle: String = ""
    var messages: [ChatMessage] = []
    var newMessage: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
}

enum ChatViewAction {
    case viewAppeared(_ roomID: String, _ nick: String)
    case messageTextChanged(String)
    case sendButtonTapped
    case backButtonTapped
}

@MainActor
@Observable
final class ChatViewStore {
    private(set) var state = ChatViewState()
    private let useCase: ChatViewUseCase
    private let router: NavigationRouter<MainTabRoute>
    
    init(useCase: ChatViewUseCase, router: NavigationRouter<MainTabRoute>) {
        self.useCase = useCase
        self.router = router
    }
    
    func send(_ action: ChatViewAction) {
        switch action {
        case .viewAppeared(let roomID, let nick):
            handleViewAppeared(roomID, nick)
            
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
    func handleViewAppeared(_ id: String, _ nick: String) {
        // 혹시 더미데이터가 로드되지 않았다면 다시 로드
        if state.messages.isEmpty {
            print("🔵 더미데이터가 비어있음, 다시 로드")
            loadDummyData()
        }
        state.roomID = id
        state.navTitle = nick
        loadRoomData()
    }
    
    func loadRoomData() {
        state.isLoading = true
        state.errorMessage = nil
        
        Task {
            do {
                let response = try await useCase.getChatHistory(state.roomID, state.next ?? "")
                print(response)
            } catch {
                state.isLoading = false
                state.errorMessage = error.localizedDescription
            }
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
        Task {
            let r = try await useCase.postChatMessage(state.roomID, PostChatMessageRequest(content: "케케", files: nil))
            print("response: \(r)")
        }
        
        state.newMessage = ""
        
        // 키보드 숨기기
        hideKeyboard()
        
        
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
} 
