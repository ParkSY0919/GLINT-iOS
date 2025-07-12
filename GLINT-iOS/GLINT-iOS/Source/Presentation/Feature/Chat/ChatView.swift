//
//  ChatView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/8/25.
//

import SwiftUI

// MARK: - GLINT Design System
extension Color {
    // GLINT 브랜드 컬러
    static let glintPrimary = Color(red: 0.2, green: 0.6, blue: 1.0)
    static let glintSecondary = Color(red: 0.85, green: 0.95, blue: 1.0)
    static let glintAccent = Color(red: 1.0, green: 0.4, blue: 0.6)
    static let glintBackground = Color(red: 0.97, green: 0.98, blue: 1.0)
    static let glintCardBackground = Color.white
    static let glintTextPrimary = Color(red: 0.1, green: 0.1, blue: 0.2)
    static let glintTextSecondary = Color(red: 0.4, green: 0.4, blue: 0.5)
    static let glintSuccess = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let glintWarning = Color(red: 1.0, green: 0.6, blue: 0.2)
    static let glintError = Color(red: 1.0, green: 0.3, blue: 0.3)
}

struct ChatView: View {
    @Environment(ChatViewStore.self)
    private var store
    @FocusState
    private var isTextFieldFocused: Bool
    @State private var messageInputHeight: CGFloat = 44
    @State private var showTypingIndicator = false
    
    let roomID: String
    let nick: String
    let userID: String
    
    init(roomID: String, nick: String, userID: String) {
        self.roomID = roomID
        self.nick = nick
        self.userID = userID
    }
    
    var body: some View {
        ZStack {
            // 배경 그라데이션
            LinearGradient(
                colors: [Color.glintBackground, Color.glintSecondary.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 연결 상태 표시
                if !store.state.isConnected {
                    connectionStatusView
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // 채팅 메시지 리스트
                messagesListView
                
                // 파일 업로드 진행률
                if store.state.isUploading {
                    uploadProgressView
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // 선택된 파일 미리보기
                if !store.state.selectedFiles.isEmpty {
                    selectedFilesView
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // 타이핑 인디케이터
                if showTypingIndicator {
                    typingIndicatorView
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // 메시지 입력 영역
                messageInputView
            }
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
        .animation(.bouncy(duration: 0.6), value: store.state.isConnected)
        .animation(.smooth(duration: 0.4), value: store.state.isUploading)
        .animation(.smooth(duration: 0.3), value: !store.state.selectedFiles.isEmpty)
    }
}

private extension ChatView {
    var navigationTitle: String {
        var title = store.state.navTitle
        if !store.state.isConnected {
            title += " ⚡"
        } else if store.state.unreadCount > 0 {
            title += " (\(store.state.unreadCount))"
        }
        return title
    }
    
    var connectionStatusView: some View {
        HStack(spacing: 12) {
            Image(systemName: "wifi.slash")
                .foregroundStyle(.white)
                .font(.system(size: 16, weight: .medium))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("연결이 끊어졌습니다")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                
                Text("재연결을 시도하는 중...")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white.opacity(0.8))
            }
            
            Spacer()
            
            Button("재시도") {
                store.send(.refreshMessages)
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.white.opacity(0.2))
            .clipShape(Capsule())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [Color.glintError, Color.glintError.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .overlay(alignment: .bottom) {
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.white.opacity(0.3))
        }
    }
    
    var uploadProgressView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "icloud.and.arrow.up")
                    .foregroundStyle(Color.glintPrimary)
                    .font(.system(size: 16, weight: .medium))
                
                Text("파일 업로드 중...")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.glintTextPrimary)
                
                Spacer()
                
                Text("\(Int(store.state.uploadProgress * 100))%")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.glintPrimary)
                    .monospacedDigit()
            }
            
            ProgressView(value: store.state.uploadProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: Color.glintPrimary))
                .scaleEffect(y: 0.8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.glintCardBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
    }
    
    var selectedFilesView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(store.state.selectedFiles.enumerated()), id: \.offset) { index, fileURL in
                    VStack(spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.glintSecondary)
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "doc.fill")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(Color.glintPrimary)
                        }
                        
                        Text(fileURL.lastPathComponent)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.glintTextSecondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .frame(width: 80)
                        
                        Button {
                            var files = store.state.selectedFiles
                            files.remove(at: index)
                            store.send(.filesSelected(files))
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color.glintError)
                        }
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.glintCardBackground)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
        .background(Color.glintBackground)
    }
    
    var typingIndicatorView: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.glintTextSecondary)
                .frame(width: 6, height: 6)
                .scaleEffect(showTypingIndicator ? 1.2 : 0.8)
                .animation(.easeInOut(duration: 0.6).repeatForever(), value: showTypingIndicator)
            
            Circle()
                .fill(Color.glintTextSecondary)
                .frame(width: 6, height: 6)
                .scaleEffect(showTypingIndicator ? 1.2 : 0.8)
                .animation(.easeInOut(duration: 0.6).repeatForever().delay(0.2), value: showTypingIndicator)
            
            Circle()
                .fill(Color.glintTextSecondary)
                .frame(width: 6, height: 6)
                .scaleEffect(showTypingIndicator ? 1.2 : 0.8)
                .animation(.easeInOut(duration: 0.6).repeatForever().delay(0.4), value: showTypingIndicator)
            
            Text("\(nick)님이 입력 중...")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.glintTextSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.glintSecondary.opacity(0.6))
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
    
    var messagesListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 4) {
                    // 로딩 인디케이터
                    if store.state.isLoading {
                        HStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(Color.glintPrimary)
                            
                            Text("메시지를 불러오는 중...")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.glintTextSecondary)
                        }
                        .padding()
                        .background(
                            Capsule()
                                .fill(Color.glintCardBackground)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        )
                        .padding(.top, 16)
                    }
                    
                    ForEach(groupedMessages, id: \.0) { date, messages in
                        // 날짜 구분선
                        DateSeparatorView(date: date)
                            .padding(.vertical, 20)
                        
                        // 해당 날짜의 메시지들
                        ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                            let isLastInTimeGroup = isLastMessageInTimeGroup(message: message, in: messages, at: index)
                            
                            ModernChatMessageRow(
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
                            .padding(.vertical, 2)
                        }
                    }
                    
                    // 캐시 관리 정보 (개발/테스트용)
                    if !store.state.messages.isEmpty {
                        VStack(spacing: 8) {
                            Text("캐시 크기: \(store.state.cacheSize)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.glintTextSecondary)
                            
                            Button("캐시 정리") {
                                store.send(.clearCache)
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.glintPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.glintSecondary)
                            )
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 16)
                    }
                }
                .padding(.top, 12)
            }
            .defaultScrollAnchor(.bottom)
            .refreshable {
                store.send(.refreshMessages)
            }
            .onChange(of: store.state.messages) { _, _ in
                // 새 메시지가 추가되면 자동으로 하단으로 스크롤
                if let lastMessage = store.state.messages.last {
                    withAnimation(.easeOut(duration: 0.5)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    var messageInputView: some View {
        VStack(spacing: 0) {
            // 상단 구분선
            Rectangle()
                .frame(height: 0.5)
                .foregroundStyle(Color.glintTextSecondary.opacity(0.2))
            
            HStack(spacing: 12) {
                // 파일 첨부 버튼
                Button {
                    store.send(.attachFileButtonTapped)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(
                            store.state.isUploading ? Color.glintTextSecondary.opacity(0.5) : Color.glintPrimary
                        )
                }
                .disabled(store.state.isUploading)
                .scaleEffect(store.state.isUploading ? 0.9 : 1.0)
                .animation(.bouncy(duration: 0.3), value: store.state.isUploading)
                
                // 메시지 입력 필드
                HStack(spacing: 8) {
                    TextField("메시지를 입력하세요", text: Binding(
                        get: { store.state.newMessage },
                        set: { store.send(.messageTextChanged($0)) }
                    ), axis: .vertical)
                    .focused($isTextFieldFocused)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.glintTextPrimary)
                    .lineLimit(1...4)
                    .disabled(store.state.isUploading)
                    .onSubmit {
                        if !store.state.newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            store.send(.sendButtonTapped(store.state.newMessage))
                        }
                    }
                    
                    // 전송 버튼
                    Button {
                        store.send(.sendButtonTapped(store.state.newMessage))
                    } label: {
                        Image(systemName: sendButtonIcon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(sendButtonGradient)
                                    .shadow(color: sendButtonShadowColor, radius: 4, x: 0, y: 2)
                            )
                    }
                    .disabled(isSendButtonDisabled)
                    .scaleEffect(isSendButtonDisabled ? 0.8 : 1.0)
                    .opacity(isSendButtonDisabled ? 0.6 : 1.0)
                    .animation(.bouncy(duration: 0.3), value: isSendButtonDisabled)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.glintCardBackground)
                        .stroke(
                            isTextFieldFocused ? Color.glintPrimary.opacity(0.6) : Color.glintTextSecondary.opacity(0.2),
                            lineWidth: isTextFieldFocused ? 2 : 1
                        )
                        .shadow(
                            color: isTextFieldFocused ? Color.glintPrimary.opacity(0.1) : Color.black.opacity(0.02),
                            radius: isTextFieldFocused ? 8 : 2,
                            x: 0,
                            y: isTextFieldFocused ? 4 : 1
                        )
                )
                .animation(.smooth(duration: 0.2), value: isTextFieldFocused)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 16)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }
    
    // MARK: - Computed Properties
    
    var sendButtonIcon: String {
        if store.state.isUploading {
            return "hourglass"
        } else if !store.state.isConnected {
            return "wifi.slash"
        } else {
            return "paperplane.fill"
        }
    }
    
    var sendButtonGradient: LinearGradient {
        if store.state.isUploading {
            return LinearGradient(
                colors: [Color.glintWarning, Color.glintWarning.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if !store.state.isConnected {
            return LinearGradient(
                colors: [Color.glintError, Color.glintError.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.glintPrimary, Color.glintAccent],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var sendButtonShadowColor: Color {
        if store.state.isUploading {
            return Color.glintWarning.opacity(0.3)
        } else if !store.state.isConnected {
            return Color.glintError.opacity(0.3)
        } else {
            return Color.glintPrimary.opacity(0.3)
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

// MARK: - Modern Chat Message Row
struct ModernChatMessageRow: View {
    let message: ChatMessage
    let showTime: Bool
    let onRetryTapped: (String) -> Void
    let onDeleteTapped: (String) -> Void
    
    @State private var showContextMenu = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isFromMe {
                // 내 메시지: 오른쪽 정렬
                Spacer()
                
                // 시간과 말풍선을 가깝게 배치
                HStack(alignment: .bottom, spacing: 4) {
                    if showTime {
                        timeView
                    }
                    myMessageBubble
                }
            } else {
                // 상대방 메시지: 왼쪽 정렬
                HStack(alignment: .bottom, spacing: 4) {
                    otherMessageBubble
                    if showTime {
                        timeView
                    }
                }
                
                Spacer()
            }
        }
        .contextMenu {
            if message.isFromMe {
                Button("재전송", systemImage: "arrow.clockwise") {
                    onRetryTapped(message.id)
                }
                
                Button("삭제", systemImage: "trash", role: .destructive) {
                    onDeleteTapped(message.id)
                }
            }
        }
        .animation(.smooth(duration: 0.3), value: message.content)
    }
}

// MARK: - Private Views
private extension ModernChatMessageRow {
    var myMessageBubble: some View {
        Text(message.content)
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [Color.glintPrimary, Color.glintAccent],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(
                ModernChatBubbleShape(isFromMe: true)
            )
            .shadow(
                color: Color.glintPrimary.opacity(0.2),
                radius: 8,
                x: 0,
                y: 4
            )
    }
    
    var otherMessageBubble: some View {
        Text(message.content)
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(Color.glintTextPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [Color.glintCardBackground, Color.glintCardBackground],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(
                ModernChatBubbleShape(isFromMe: false)
            )
            .shadow(
                color: Color.black.opacity(0.05),
                radius: 4,
                x: 0,
                y: 2
            )
    }
    
    var timeView: some View {
        Text(message.formattedTime)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Color.glintTextSecondary)
            .padding(.bottom, 2)
    }
}

// MARK: - 모던 말풍선 모양
struct ModernChatBubbleShape: Shape {
    let isFromMe: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: isFromMe ?
                [.topLeft, .topRight, .bottomLeft] :
                [.topLeft, .topRight, .bottomRight],
            cornerRadii: CGSize(width: 20, height: 20)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Modern Date Separator
struct DateSeparatorView: View {
    let date: String
    
    var body: some View {
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.glintTextSecondary.opacity(0.3))
            
            Text(date)
                .font(.pretendardFont(.caption_semi, size: 10))
                .foregroundStyle(Color.glintTextSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(Color.glintTextSecondary.opacity(0.2), lineWidth: 1)
                        )
                )
            
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.glintTextSecondary.opacity(0.3))
        }
        .padding(.horizontal, 20)
    }
} 
