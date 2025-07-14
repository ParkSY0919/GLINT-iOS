//
//  TypingIndicatorSectionView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/8/25.
//

import SwiftUI

struct TypingIndicatorSectionView: View {
    let showTypingIndicator: Bool
    let nick: String
    
    var body: some View {
        Group {
            if showTypingIndicator {
                typingIndicatorContent
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

private extension TypingIndicatorSectionView {
    var typingIndicatorContent: some View {
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
} 