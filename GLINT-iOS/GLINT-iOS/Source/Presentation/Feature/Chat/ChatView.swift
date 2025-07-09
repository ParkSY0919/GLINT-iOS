//
//  ChatView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/8/25.
//

import SwiftUI

struct ChatView: View {
    @State private var store: ChatViewStore
    @FocusState private var isTextFieldFocused: Bool
    
    let otherUserId: String
    let otherUserName: String
    
    init(otherUserId: String, otherUserName: String, store: ChatViewStore) {
        self.otherUserId = otherUserId
        self.otherUserName = otherUserName
        self._store = State(initialValue: store)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 채팅 메시지 리스트
            messagesListView
            
            // 메시지 입력 영역
            messageInputView
        }
        .navigationSetup(
            title: store.state.otherUserName,
            onBackButtonTapped: { store.send(.backButtonTapped) }
        )
        .onAppear {
            print("🟢 ChatView: onAppear 호출됨")
            print("🟢 store.state.messages 개수: \(store.state.messages.count)")
            store.send(.viewAppeared)
        }
        .background(Color(red: 0.71, green: 0.84, blue: 0.89)) // 카카오톡 배경색
    }
}

private extension ChatView {
    var messagesListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(groupedMessages, id: \.0) { date, messages in
                        // 날짜 구분선
                        DateSeparatorView(date: date)
                            .padding(.vertical, 16)
                        
                        // 해당 날짜의 메시지들
                        ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                            let isLastInTimeGroup = isLastMessageInTimeGroup(message: message, in: messages, at: index)
                            
                            ChatMessageRow(
                                message: message,
                                showTime: isLastInTimeGroup
                            )
                            .padding(.horizontal, 16)
                            .padding(.bottom, 4)
                        }
                    }
                }
                .padding(.top, 8)
            }
            .defaultScrollAnchor(.bottom)
            .onChange(of: store.state.messages) { _, _ in
                // 새 메시지가 추가되면 자동으로 하단으로 스크롤
                if let lastMessage = store.state.messages.last {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    var messageInputView: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.gray.opacity(0.3))
            
            HStack(spacing: 8) {
                // 메시지 입력 필드
                TextField("메시지를 입력하세요", text: Binding(
                    get: { store.state.newMessage },
                    set: { store.send(.messageTextChanged($0)) }
                ), axis: .vertical)
                .focused($isTextFieldFocused)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .lineLimit(1...3)
                
                // 전송 버튼
                Button {
                    store.send(.sendButtonTapped)
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.yellow)
                        .clipShape(Circle())
                }
                .disabled(store.state.newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(store.state.newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white)
        }
    }
    
    // 날짜별 메시지 그룹핑
    var groupedMessages: [(String, [ChatMessage])] {
        let grouped = Dictionary(grouping: store.state.messages) { message in
            message.formattedDate
        }
        
        return grouped.map { (date, messages) in
            (date, messages.sorted { $0.timestamp < $1.timestamp })
        }.sorted { group1, group2 in
            // 날짜순으로 정렬
            guard let date1 = group1.1.first?.timestamp,
                  let date2 = group2.1.first?.timestamp else { return false }
            return date1 < date2
        }
    }
    
    // 시간 그룹에서 마지막 메시지인지 확인
    func isLastMessageInTimeGroup(message: ChatMessage, in messages: [ChatMessage], at index: Int) -> Bool {
        // 마지막 메시지면 시간 표시
        if index == messages.count - 1 { return true }
        
        // 다음 메시지와 시간이 다르면 시간 표시
        let nextMessage = messages[index + 1]
        return !message.isSameTimeAs(nextMessage) || message.isFromMe != nextMessage.isFromMe
    }
} 
