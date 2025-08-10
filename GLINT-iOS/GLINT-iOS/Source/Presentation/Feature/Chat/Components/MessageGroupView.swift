//
//  MessageGroupView.swift
//  GLINT-iOS
//
//  Created by Claude on 8/9/25.
//

import SwiftUI

struct MessageGroupView: View {
    let messageGroup: MessageGroup
    let showTime: Bool
    let searchQuery: String // 검색어 (하이라이팅용)
    let onRetryTapped: (String) -> Void
    let onDeleteTapped: (String) -> Void
    let onImageTapped: ([String], Int) -> Void
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if messageGroup.isFromMe {
                // 내 메시지: 오른쪽 정렬
                Spacer()
                
                HStack(alignment: .bottom, spacing: 4) {
                    if showTime {
                        timeView
                    }
                    myMessageGroupContent
                }
            } else {
                // 상대방 메시지: 왼쪽 정렬
                HStack(alignment: .bottom, spacing: 4) {
                    otherMessageGroupContent
                    if showTime {
                        timeView
                    }
                }
                
                Spacer()
            }
        }
        .contextMenu {
            if messageGroup.isFromMe {
                ForEach(messageGroup.messages, id: \.id) { message in
                    Button("메시지 재전송", systemImage: "arrow.clockwise") {
                        onRetryTapped(message.id)
                    }
                    
                    Button("메시지 삭제", systemImage: "trash", role: .destructive) {
                        onDeleteTapped(message.id)
                    }
                }
            }
        }
        .animation(.smooth(duration: 0.3), value: messageGroup.messages.count)
    }
}

// MARK: - Private Views
private extension MessageGroupView {
    var myMessageGroupContent: some View {
        VStack(alignment: .trailing, spacing: 6) {
            // 그룹 내 모든 메시지 표시
            ForEach(messageGroup.messages, id: \.id) { message in
                VStack(alignment: .trailing, spacing: 4) {
                    // 이미지들 (있는 경우)
                    if !message.images.isEmpty {
                        ChatImageLayoutView(imageUrls: message.images) { index in
                            onImageTapped(message.images, index)
                        }
                    }
                    
                    // 텍스트 메시지 (있는 경우)
                    if !message.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        myMessageBubble(content: message.content)
                    }
                }
            }
        }
    }
    
    var otherMessageGroupContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 그룹 내 모든 메시지 표시
            ForEach(messageGroup.messages, id: \.id) { message in
                VStack(alignment: .leading, spacing: 4) {
                    // 이미지들 (있는 경우)
                    if !message.images.isEmpty {
                        ChatImageLayoutView(imageUrls: message.images) { index in
                            onImageTapped(message.images, index)
                        }
                    }
                    
                    // 텍스트 메시지 (있는 경우)
                    if !message.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        otherMessageBubble(content: message.content)
                    }
                }
            }
        }
    }
    
    func myMessageBubble(content: String) -> some View {
        HighlightedText.chatMessage(
            text: content,
            searchQuery: searchQuery,
            isFromMe: true
        )
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
    
    func otherMessageBubble(content: String) -> some View {
        HighlightedText.chatMessage(
            text: content,
            searchQuery: searchQuery,
            isFromMe: false
        )
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
        Text(messageGroup.formattedTime)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Color.glintTextSecondary)
            .padding(.bottom, 2)
    }
}

// MARK: - 무한스크롤 감지용 래퍼
struct InfiniteScrollMessageGroupView: View {
    let messageGroup: MessageGroup
    let index: Int
    let showTime: Bool
    let searchQuery: String // 검색어 (하이라이팅용)
    let onRetryTapped: (String) -> Void
    let onDeleteTapped: (String) -> Void
    let onImageTapped: ([String], Int) -> Void
    let onMessageGroupAppeared: (Int) -> Void
    
    var body: some View {
        MessageGroupView(
            messageGroup: messageGroup,
            showTime: showTime,
            searchQuery: searchQuery,
            onRetryTapped: onRetryTapped,
            onDeleteTapped: onDeleteTapped,
            onImageTapped: onImageTapped
        )
        .onAppear {
            // 메시지 그룹이 화면에 나타날 때 콜백 호출
            onMessageGroupAppeared(index)
        }
    }
}