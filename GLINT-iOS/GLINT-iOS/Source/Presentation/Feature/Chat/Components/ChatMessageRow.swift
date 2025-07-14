//
//  ChatMessageRow.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/8/25.
//

import SwiftUI

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

// MARK: - Legacy ChatMessageRow (호환성을 위해 유지)
struct ChatMessageRow: View {
    let message: ChatMessage
    let showTime: Bool
    let onRetryTapped: ((String) -> Void)?
    let onDeleteTapped: ((String) -> Void)?
    
    init(message: ChatMessage, 
         showTime: Bool, 
         onRetryTapped: ((String) -> Void)? = nil, 
         onDeleteTapped: ((String) -> Void)? = nil) {
        self.message = message
        self.showTime = showTime
        self.onRetryTapped = onRetryTapped
        self.onDeleteTapped = onDeleteTapped
    }
    
    var body: some View {
        ModernChatMessageRow(
            message: message,
            showTime: showTime,
            onRetryTapped: onRetryTapped ?? { _ in },
            onDeleteTapped: onDeleteTapped ?? { _ in }
        )
    }
} 
