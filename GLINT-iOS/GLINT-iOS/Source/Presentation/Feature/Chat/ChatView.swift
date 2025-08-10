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
        Group {
            if store.state.isLoading && store.state.messages.isEmpty {
                StateViewBuilder.loadingView()
            } else if let errorMessage = store.state.errorMessage {
                StateViewBuilder.errorView(errorMessage: errorMessage) {
                    store.send(.refreshMessages)
                }
            } else {
                contentView
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Leading buttons
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { store.send(.backButtonTapped) }) {
                    Image(systemName: "arrow.left")
                        .frame(width: 32, height: 32)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray75)
                }
            }
            
            // Trailing buttons
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if store.state.isSearchMode {
                        store.send(.endSearch)
                    } else {
                        store.send(.startSearch)
                    }
                }) {
                    Image(systemName: store.state.isSearchMode ? "xmark" : "magnifyingglass")
                        .frame(width: 32, height: 32)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray75)
                }
            }
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
        .onViewDidLoad(perform: {
            store.send(.viewAppeared(roomID, nick, userID))
        })
        .onDisappear {
            store.send(.viewDisappeared)
        }
        .animation(.bouncy(duration: 0.6), value: store.state.isConnected)
        .animation(.smooth(duration: 0.4), value: store.state.isUploading)
        .animation(.smooth(duration: 0.3), value: !store.state.selectedImages.isEmpty)
        .sheet(isPresented: Binding(
            get: { store.state.showImagePicker },
            set: { _ in }
        )) {
            ImagePicker { images in
                store.send(.imagesSelected(images))
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { store.state.showImageDetail },
            set: { isPresented in
                if !isPresented {
                    store.send(.hideImageDetail)
                }
            }
        )) {
            ChatImageDetailView(
                imageUrls: store.state.detailImages,
                initialIndex: store.state.detailImageIndex
            )
        }
    }
}

private extension ChatView {
    var contentView: some View {
        ZStack {
            // 배경 그라데이션
            LinearGradient(
                colors: [Color.glintBackground, Color.glintSecondary.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 검색 헤더 (검색 모드일 때만 표시)
                if store.state.isSearchMode {
                    searchHeaderView
                }
                
                ConnectionStatusSectionView(
                    isConnected: store.state.isConnected,
                    onRetryTapped: {
                        store.send(.refreshMessages)
                    }
                )
                
                MessageListSectionView(
                    messages: store.state.messages,
                    messageGroups: store.state.messageGroups,
                    isLoading: store.state.isLoading,
                    isLoadingMore: store.state.isLoadingMore,
                    cacheSize: store.state.cacheSize,
                    searchQuery: store.state.currentSearchQuery,
                    onRetryMessage: { chatId in
                        store.send(.retryFailedMessage(chatId))
                    },
                    onDeleteMessage: { chatId in
                        store.send(.deleteMessage(chatId))
                    },
                    onImageTapped: { images, index in
                        store.send(.showImageDetail(images, index))
                    },
                    onClearCache: {
                        store.send(.clearCache)
                    },
                    onRefresh: {
                        store.send(.refreshMessages)
                    },
                    onLoadMore: {
                        store.send(.loadMoreMessages)
                    },
                    onMessageGroupAppeared: { index in
                        store.send(.messageGroupAppearedAtIndex(index))
                    }
                )
                
                FileUploadSectionView(
                    isUploading: store.state.isUploading,
                    uploadProgress: store.state.uploadProgress
                )
                
                TypingIndicatorSectionView(
                    showTypingIndicator: showTypingIndicator,
                    nick: nick
                )
                
                MessageInputSectionView(
                    newMessage: store.state.newMessage,
                    isConnected: store.state.isConnected,
                    isUploading: store.state.isUploading,
                    selectedImages: store.state.selectedImages,
                    onMessageChanged: { message in
                        store.send(.messageTextChanged(message))
                    },
                    onSendMessage: {
                        store.send(.sendButtonTapped(store.state.newMessage))
                    },
                    onAttachFile: {
                        store.send(.attachFileButtonTapped)
                    },
                    onRemoveImage: { index in
                        store.send(.removeSelectedImage(index))
                    }
                )
            }
        }
    }
    
    var navigationTitle: String {
        var title = store.state.navTitle
        if !store.state.isConnected {
            title += " ⚡"
        } else if store.state.unreadCount > 0 {
            title += " (\(store.state.unreadCount))"
        }
        return title
    }
    
    
    /// 검색 헤더 뷰
    var searchHeaderView: some View {
        ChatSearchHeader(
            searchText: Binding(
                get: { store.state.searchText },
                set: { store.send(.searchTextChanged($0)) }
            ),
            isSearchMode: Binding(
                get: { store.state.isSearchMode },
                set: { _ in }
            ),
            searchManager: store.searchManager,
            onSearch: { query in
                store.send(.performSearch(query))
            },
            onNavigatePrevious: {
                store.send(.navigateToPreviousSearchResult)
            },
            onNavigateNext: {
                store.send(.navigateToNextSearchResult)
            },
            onCloseSearch: {
                store.send(.endSearch)
            }
        )
    }
}
