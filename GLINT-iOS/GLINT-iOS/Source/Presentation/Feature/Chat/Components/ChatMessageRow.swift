//
//  ChatMessageRow.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/8/25.
//

import SwiftUI

struct ChatMessageRow: View {
    let message: ChatMessage
    let showTime: Bool
    
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
    }
}

private extension ChatMessageRow {
    var myMessageBubble: some View {
            Text(message.content)
                .font(.system(size: 16))
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.yellow)
                .clipShape(
                    ChatBubbleShape(isFromMe: true)
                )
    }
    
    var otherMessageBubble: some View {
        Text(message.content)
            .font(.system(size: 16))
            .foregroundColor(.black)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white)
            .clipShape(
                ChatBubbleShape(isFromMe: false)
            )
    }
    
    var timeView: some View {
        Text(message.formattedTime)
            .font(.system(size: 11))
            .foregroundColor(.gray)
            .padding(.bottom, 2)
    }
}

// MARK: - 말풍선 모양
struct ChatBubbleShape: Shape {
    let isFromMe: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: isFromMe ? 
                [.topLeft, .topRight, .bottomLeft] : 
                [.topLeft, .topRight, .bottomRight],
            cornerRadii: CGSize(width: 16, height: 16)
        )
        return Path(path.cgPath)
    }
} 
