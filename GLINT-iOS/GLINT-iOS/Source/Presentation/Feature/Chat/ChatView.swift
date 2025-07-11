//
//  ChatView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/8/25.
//

import SwiftUI

struct ChatView: View {
    @Environment(ChatViewStore.self)
    private var store
    @FocusState
    private var isTextFieldFocused: Bool
    
    let roomID: String
    let nick: String
    let userID: String
    
    init(roomID: String, nick: String, userID: String) {
        self.roomID = roomID
        self.nick = nick
        self.userID = userID
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 연결 상태 표시
            connectionStatusView
            
            // 채팅 메시지 리스트
            messagesListView
            
            // 파일 업로드 진행률
            if store.state.isUploading {
                uploadProgressView
            }
            
            // 선택된 파일 미리보기
            if !store.state.selectedFiles.isEmpty {
                selectedFilesView
            }
            
            // 메시지 입력 영역
            messageInputView
        }
        .navigationSetup(
            title: navigationTitle,
            onBackButtonTapped: { store.send(.backButtonTapped) }
        )
        .onViewDidLoad(perform: {
            store.send(.viewAppeared(roomID, nick, userID))
        })
        .onDisappear {
            store.send(.viewDisappeared)
        }
        .background(Color(red: 0.71, green: 0.84, blue: 0.89))
        .alert("오류", isPresented: .constant(store.state.errorMessage != nil)) {
            Button("확인") {
                // store.send(.clearError) - 필요 시 추가
            }
            Button("다시 시도") {
                store.send(.refreshMessages)
            }
        } message: {
            Text(store.state.errorMessage ?? "")
        }
    }
}

private extension ChatView {
    var navigationTitle: String {
        var title = store.state.navTitle
        if !store.state.isConnected {
            title += " (연결 끊김)"
        } else if store.state.unreadCount > 0 {
            title += " (\(store.state.unreadCount))"
        }
        return title
    }
    
    var connectionStatusView: some View {
        Group {
            if !store.state.isConnected {
                HStack {
                    Image(systemName: "wifi.slash")
                        .foregroundColor(.white)
                    Text("연결이 끊어졌습니다. 재연결 중...")
                        .font(.caption)
                        .foregroundColor(.white)
                    Spacer()
                    Button("다시 시도") {
                        store.send(.refreshMessages)
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.red)
            }
        }
    }
    
    var uploadProgressView: some View {
        VStack(spacing: 4) {
            HStack {
                Text("파일 업로드 중...")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text("\(Int(store.state.uploadProgress * 100))%")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            ProgressView(value: store.state.uploadProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white)
    }
    
    var selectedFilesView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(store.state.selectedFiles.enumerated()), id: \.offset) { index, fileURL in
                    VStack {
                        Image(systemName: "doc.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text(fileURL.lastPathComponent)
                            .font(.caption)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        
                        Button("삭제") {
                            var files = store.state.selectedFiles
                            files.remove(at: index)
                            store.send(.filesSelected(files))
                        }
                        .font(.caption2)
                        .foregroundColor(.red)
                    }
                    .frame(width: 80)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
        .background(Color.white)
    }
    
    var messagesListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    // 로딩 인디케이터
                    if store.state.isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("메시지를 불러오는 중...")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                    
                    ForEach(groupedMessages, id: \.0) { date, messages in
                        // 날짜 구분선 (Components 폴더의 DateSeparatorView 사용)
                        DateSeparatorView(date: date)
                            .padding(.vertical, 16)
                        
                        // 해당 날짜의 메시지들
                        ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                            let isLastInTimeGroup = isLastMessageInTimeGroup(message: message, in: messages, at: index)
                            
                            ChatMessageRow(
                                message: message,
                                showTime: isLastInTimeGroup,
                                onRetryTapped: { chatId in
                                    store.send(.retryFailedMessage(chatId))
                                },
                                onDeleteTapped: { chatId in
                                    store.send(.deleteMessage(chatId))
                                }
                            )
                            .padding(.horizontal, 16)
                            .padding(.bottom, 4)
                        }
                    }
                    
                    // 캐시 관리 정보 (개발/테스트용)
                    if !store.state.messages.isEmpty {
                        VStack(spacing: 4) {
                            Text("캐시 크기: \(store.state.cacheSize)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            
                            Button("캐시 정리") {
                                store.send(.clearCache)
                            }
                            .font(.caption2)
                            .foregroundColor(.blue)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 8)
                    }
                }
                .padding(.top, 8)
            }
            .defaultScrollAnchor(.bottom)
            .refreshable {
                store.send(.refreshMessages)
            }
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
                // 파일 첨부 버튼
                Button {
                    store.send(.attachFileButtonTapped)
                } label: {
                    Image(systemName: "paperclip")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
                .disabled(store.state.isUploading)
                
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
                .disabled(store.state.isUploading)
                
                // 전송 버튼
                Button {
                    store.send(.sendButtonTapped(store.state.newMessage))
                } label: {
                    Image(systemName: store.state.isUploading ? "hourglass" : "paperplane.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(sendButtonColor)
                        .clipShape(Circle())
                }
                .disabled(isSendButtonDisabled)
                .opacity(isSendButtonDisabled ? 0.5 : 1.0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white)
        }
    }
    
    var sendButtonColor: Color {
        if store.state.isUploading {
            return .orange
        } else if !store.state.isConnected {
            return .red
        } else {
            return .yellow
        }
    }
    
    var isSendButtonDisabled: Bool {
        return store.state.isUploading || 
               (store.state.newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
                store.state.selectedFiles.isEmpty)
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

// MARK: - Enhanced Chat Message Row (기존 Components/ChatMessageRow.swift와 중복 방지를 위해 제거)
// Components 폴더의 ChatMessageRow.swift를 사용합니다. 
