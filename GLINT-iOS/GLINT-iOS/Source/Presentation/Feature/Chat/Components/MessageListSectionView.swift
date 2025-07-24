//
//  MessageListSectionView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/8/25.
//

import SwiftUI

struct MessageListSectionView: View {
    let messages: [ChatMessage]
    let isLoading: Bool
    let cacheSize: String
    let onRetryMessage: (String) -> Void
    let onDeleteMessage: (String) -> Void
    let onImageTapped: ([String], Int) -> Void // 새로 추가
    let onClearCache: () -> Void
    let onRefresh: () -> Void
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 4) {
                    // 로딩 인디케이터
                    if isLoading {
                        loadingIndicatorView
                    }
                    
                    ForEach(groupedMessages, id: \.0) { date, dateMessages in
                        // 날짜 구분선
                        DateSeparatorView(date: date)
                            .padding(.vertical, 20)
                        
                        // 해당 날짜의 메시지들
                        ForEach(Array(dateMessages.enumerated()), id: \.element.id) { index, message in
                            let isLastInTimeGroup = isLastMessageInTimeGroup(message: message, in: dateMessages, at: index)
                            
                            ModernChatMessageRow(
                                message: message,
                                showTime: isLastInTimeGroup,
                                onRetryTapped: onRetryMessage,
                                onDeleteTapped: onDeleteMessage,
                                onImageTapped: onImageTapped
                            )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 2)
                        }
                    }
                    
                    // 캐시 관리 정보 (개발/테스트용)
                    if !messages.isEmpty {
                        cacheManagementView
                    }
                }
                .padding(.top, 12)
            }
            .defaultScrollAnchor(.bottom)
            .refreshable {
                onRefresh()
            }
            .onChange(of: messages) { _, _ in
                // 새 메시지가 추가되면 자동으로 하단으로 스크롤
                if let lastMessage = messages.last {
                    withAnimation(.easeOut(duration: 0.5)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}

private extension MessageListSectionView {
    var loadingIndicatorView: some View {
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
    
    var cacheManagementView: some View {
        VStack(spacing: 8) {
            Text("캐시 크기: \(cacheSize)")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.glintTextSecondary)
            
            Button("캐시 정리") {
                onClearCache()
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
    
    // 날짜별 메시지 그룹핑
    var groupedMessages: [(String, [ChatMessage])] {
        let grouped = Dictionary(grouping: messages) { message in
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
