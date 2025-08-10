//
//  MessageListSectionView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/8/25.
//

import SwiftUI

struct MessageListSectionView: View {
    let messages: [ChatMessage]
    let messageGroups: [MessageGroup] // 그룹화된 메시지들
    let isLoading: Bool
    let isLoadingMore: Bool // 추가 로딩 상태
    let cacheSize: String
    let searchQuery: String // 검색어 (하이라이팅용)
    let onRetryMessage: (String) -> Void
    let onDeleteMessage: (String) -> Void
    let onImageTapped: ([String], Int) -> Void
    let onClearCache: () -> Void
    let onRefresh: () -> Void
    let onLoadMore: () -> Void // 무한스크롤 콜백
    let onMessageGroupAppeared: (Int) -> Void // 메시지 그룹 나타남 콜백
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 4) {
                    // 상단 추가 로딩 인디케이터 (무한스크롤용)
                    if isLoadingMore {
                        loadMoreIndicatorView
                    }
                    
                    // 초기 로딩 인디케이터
                    if isLoading && messageGroups.isEmpty {
                        loadingIndicatorView
                    }
                    
                    // 메시지 그룹들을 날짜별로 표시
                    ForEach(groupedMessageGroups, id: \.0) { date, dateGroups in
                        // 날짜 구분선
                        DateSeparatorView(date: date)
                            .padding(.vertical, 20)
                        
                        // 해당 날짜의 메시지 그룹들
                        ForEach(Array(dateGroups.enumerated()), id: \.element.id) { groupIndex, messageGroup in
                            let isLastInTimeGroup = isLastGroupInTimeGroup(group: messageGroup, in: dateGroups, at: groupIndex)
                            let absoluteIndex = getAbsoluteGroupIndex(for: messageGroup)
                            
                            InfiniteScrollMessageGroupView(
                                messageGroup: messageGroup,
                                index: absoluteIndex,
                                showTime: isLastInTimeGroup,
                                searchQuery: searchQuery,
                                onRetryTapped: onRetryMessage,
                                onDeleteTapped: onDeleteMessage,
                                onImageTapped: onImageTapped,
                                onMessageGroupAppeared: onMessageGroupAppeared
                            )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 2)
                        }
                    }
                    
                    // 캐시 관리 정보 (개발/테스트용)
                    if !messageGroups.isEmpty {
                        cacheManagementView
                    }
                }
                .padding(.top, 12)
            }
            // .defaultScrollAnchor(.bottom) // iOS 18+ API - iOS 17 지원을 위해 제거
            .refreshable {
                onRefresh()
            }
            .onAppear {
                // 채팅방 입장 시 즉시 최하단으로 스크롤 (iOS 17 호환)
                if let lastGroup = messageGroups.last,
                   let lastMessage = lastGroup.messages.last {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                } else if let lastMessage = messages.last {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
            .onChange(of: messageGroups) { newGroups in
                // iOS 17 호환: 메시지 그룹이 변경되면 최하단으로 스크롤
                if !newGroups.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let lastGroup = newGroups.last,
                           let lastMessage = lastGroup.messages.last {
                            withAnimation(.easeOut(duration: 0.5)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .onChange(of: messages) { newMessages in
                // iOS 17 호환: 새 메시지가 추가되면 자동으로 하단으로 스크롤
                if !newMessages.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let lastMessage = newMessages.last {
                            withAnimation(.easeOut(duration: 0.5)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .scrollToMessage)) { notification in
                if let messageId = notification.userInfo?["messageId"] as? String {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        proxy.scrollTo(messageId, anchor: .center)
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
                .foregroundColor(Color.glintTextSecondary)
        }
        .padding()
        .background(
            Capsule()
                .fill(Color.glintCardBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .padding(.top, 16)
    }
    
    var loadMoreIndicatorView: some View {
        HStack(spacing: 12) {
            ProgressView()
                .scaleEffect(0.7)
                .tint(Color.glintPrimary)
            
            Text("이전 메시지 불러오는 중...")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.glintTextSecondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            Capsule()
                .fill(Color.glintCardBackground.opacity(0.8))
                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
        )
        .padding(.bottom, 8)
    }
    
    var cacheManagementView: some View {
        VStack(spacing: 8) {
            Text("캐시 크기: \(cacheSize)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.glintTextSecondary)
            
            Button("캐시 정리") {
                onClearCache()
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Color.glintPrimary)
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
    
    // 날짜별 메시지 그룹핑 (MessageGroup 버전)
    var groupedMessageGroups: [(String, [MessageGroup])] {
        return MessageGroup.groupedByDate(messageGroups)
    }
    
    // 메시지 그룹의 절대 인덱스 가져오기
    func getAbsoluteGroupIndex(for targetGroup: MessageGroup) -> Int {
        return messageGroups.firstIndex { $0.id == targetGroup.id } ?? 0
    }
    
    // 시간 그룹에서 마지막 메시지 그룹인지 확인
    func isLastGroupInTimeGroup(group: MessageGroup, in groups: [MessageGroup], at index: Int) -> Bool {
        // 마지막 그룹이면 시간 표시
        if index == groups.count - 1 { return true }
        
        // 다음 그룹과 발신자가 다르면 시간 표시
        let nextGroup = groups[index + 1]
        return group.senderId != nextGroup.senderId || 
               !group.isSameTimeGroup || 
               group.isFromMe != nextGroup.isFromMe
    }
} 
