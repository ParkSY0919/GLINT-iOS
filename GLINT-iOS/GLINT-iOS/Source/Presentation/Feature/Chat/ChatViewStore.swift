//
//  ChatViewStore.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/8/25.
//

import SwiftUI
//import Combine

struct ChatViewState {
    var roomID: String = ""
    var next: String? = ""
    var navTitle: String = ""
    var messages: [ChatMessage] = []
    var messageGroups: [MessageGroup] = [] // 시간 그룹화된 메시지들
    var newMessage: String = ""
    var isLoading: Bool = false
    var isLoadingMore: Bool = false // 추가 메시지 로딩 상태
    var hasMoreMessages: Bool = true // 더 불러올 메시지가 있는지 여부
    var oldestLoadedTimestamp: Date? // 현재 로드된 가장 오래된 메시지 시간
    var errorMessage: String?
    var isConnected: Bool = false
    var unreadCount: Int = 0
    var selectedImages: [UIImage] = [] // UIImage 배열로 변경
    var showImagePicker: Bool = false
    var showImageDetail: Bool = false // 이미지 상세보기 모달
    var detailImages: [String] = [] // 상세보기할 이미지 URL들
    var detailImageIndex: Int = 0 // 현재 선택된 이미지 인덱스
    var isUploading: Bool = false
    var uploadProgress: Double = 0.0
    var cacheSize: String = "0 MB"
    var relativeUserId: String = ""
    var myUserID: String = ""
    var myNickname: String = "" // nickname으로 isFromMe 판단용
    var myAccessToken: String = ""
    var fileUploadResponse: [String]?
    
    // MARK: - Search State
    var isSearchMode: Bool = false
    var searchText: String = ""
    var currentSearchQuery: String = ""
}

enum ChatViewAction {
    case viewAppeared(_ roomID: String, _ nick: String, _ userID: String)
    case viewDisappeared
    case messageTextChanged(String)
    case sendButtonTapped(String)
    case backButtonTapped
    case attachFileButtonTapped
    case imagesSelected([UIImage]) // 다중 이미지 선택으로 수정
    case removeSelectedImage(Int)
    case showImageDetail([String], Int) // 이미지 상세보기 표시
    case hideImageDetail // 이미지 상세보기 닫기
    case retryFailedMessage(String)
    case deleteMessage(String)
    case clearCache
    case refreshMessages
    case loadMoreMessages // 무한스크롤로 이전 메시지 로드
    case messageGroupAppearedAtIndex(Int) // 특정 인덱스 메시지 그룹이 화면에 나타남
    
    // MARK: - Search Actions
    case startSearch
    case endSearch
    case searchTextChanged(String)
    case performSearch(String)
    case navigateToNextSearchResult
    case navigateToPreviousSearchResult
    case scrollToSearchResult(String) // 검색 결과로 스크롤
}

@MainActor
@Observable
final class ChatViewStore {
    private(set) var state = ChatViewState()
    private let useCase: ChatViewUseCase
    private let router: NavigationRouter<MainTabRoute>
    private let coreDataManager = CoreDataManager.shared
    private let webSocketManager = WebSocketManager.shared
    private let keyChainManager = KeychainManager.shared
    private let appStateManager = AppStateManager.shared
    let searchManager = ChatSearchManager()
    
    @ObservationIgnored private var notificationObservers: [NSObjectProtocol] = []
    
    init(useCase: ChatViewUseCase, router: NavigationRouter<MainTabRoute>) {
        self.useCase = useCase
        self.router = router
        
        // 비동기로 설정 초기화
        Task {
            await setupAsync()
        }
    }
    
    deinit {
        // 등록된 모든 observer 제거
        for observer in notificationObservers {
            NotificationCenter.default.removeObserver(observer)
        }
        notificationObservers.removeAll()
        //위에서 놓쳤을 경우를 대비
        NotificationCenter.default.removeObserver(self)
        
        print("📱 ChatViewStore: 모든 Observer 제거 완료 (\(notificationObservers.count)개 정리)")
    }
    
    /// 비동기 초기화
    private func setupAsync() async {
        let userId = keyChainManager.getUserId() ?? ""
        let nickname = keyChainManager.getNickname() ?? ""
        state.myUserID = userId
        state.myNickname = nickname
        print("🔑 ChatViewStore 초기화:")
        print("   - Keychain에서 가져온 사용자 ID: '\(userId)'")
        print("   - Keychain에서 가져온 닉네임: '\(nickname)'")
        print("   - state.myUserID 설정: '\(state.myUserID)'")
        print("   - state.myNickname 설정: '\(state.myNickname)'")
        print("   - 빈 문자열 여부 (ID): \(userId.isEmpty), (닉네임): \(nickname.isEmpty)")
        await setupNotificationObservers()
//        await setupRealtimeUpdates()
    }
    
    func send(_ action: ChatViewAction) {
        switch action {
        case .viewAppeared(let roomID, let nick, let userID):
            handleViewAppeared(roomID, nick, userID)
            
        case .viewDisappeared:
            handleViewDisappeared()
            
        case .messageTextChanged(let text):
            handleMessageTextChanged(text)
            
        case .sendButtonTapped(let content):
            handleSendMessage(content)
            
        case .backButtonTapped:
            handleBackButtonTapped()
            
        case .attachFileButtonTapped:
            handleAttachFile()
            
        case .imagesSelected(let images):
            handleImagesSelected(images)
            
        case .removeSelectedImage(let index):
            handleRemoveSelectedImage(index)
            
        case .showImageDetail(let images, let index):
            handleShowImageDetail(images, index)
            
        case .hideImageDetail:
            handleHideImageDetail()
            
        case .retryFailedMessage(let chatId):
            handleRetryFailedMessage(chatId)
            
        case .deleteMessage(let chatId):
            handleDeleteMessage(chatId)
            
        case .clearCache:
            handleClearCache()
            
        case .refreshMessages:
            handleRefreshMessages()
            
        case .loadMoreMessages:
            handleLoadMoreMessages()
            
        case .messageGroupAppearedAtIndex(let index):
            handleMessageGroupAppeared(at: index)
            
        case .startSearch:
            handleStartSearch()
            
        case .endSearch:
            handleEndSearch()
            
        case .searchTextChanged(let text):
            handleSearchTextChanged(text)
            
        case .performSearch(let query):
            handlePerformSearch(query)
            
        case .navigateToNextSearchResult:
            handleNavigateToNextSearchResult()
            
        case .navigateToPreviousSearchResult:
            handleNavigateToPreviousSearchResult()
            
        case .scrollToSearchResult(let messageId):
            handleScrollToSearchResult(messageId)
        }
    }
}

// MARK: - Private Action Handlers
@MainActor
private extension ChatViewStore {
    /// 뷰가 나타났을 때의 처리
    func handleViewAppeared(_ roomID: String, _ nick: String, _ userID: String) {
        state.roomID = roomID
        state.navTitle = nick
        state.relativeUserId = userID
        
        // AppStateManager에 현재 채팅방 입장 알림
        appStateManager.enterChatRoom(roomID)
        
        // WebSocket 채팅방 참여
        webSocketManager.joinChatRoom(roomId: roomID, accessToken: keyChainManager.getAccessToken() ?? "꽝")
        
        GTLogger.d("현재 내 닉네임: \(state.myNickname)")
        // 현재 사용자 생성/조회 (내 정보)
        _ = coreDataManager.fetchOrCreateUser(
            userId: state.myUserID,
            nickname: state.myNickname, // 키체인에서 가져온 실제 닉네임 사용
            profileImageUrl: nil,
            isCurrentUser: true
        )
        
        // 상대방 사용자 정보 생성/조회
        _ = coreDataManager.fetchOrCreateUser(
            userId: userID,
            nickname: nick,
            profileImageUrl: nil,
            isCurrentUser: false
        )
        
        // CoreData에서 초기 메시지 로드 (최신 20개)
        loadInitialMessagesFromCoreData()
        
        // 연결 상태 업데이트
        updateConnectionState()
        
        // 캐시 크기 업데이트
        updateCacheSize()
        
        // 서버에서 최신 메시지 동기화
        syncMessagesFromServer()
    }
    
    /// 뷰가 사라졌을 때의 처리
    func handleViewDisappeared() {
        // AppStateManager에 채팅방 퇴장 알림
        appStateManager.leaveChatRoom(state.roomID)
        
        // WebSocket 채팅방 떠나기
        webSocketManager.leaveChatRoom(state.roomID)
    }
    
    /// 메시지 텍스트 변경 처리
    func handleMessageTextChanged(_ text: String) {
        state.newMessage = text
    }
    
    /// 메시지 전송 처리
    func handleSendMessage(_ content: String) {
        let messageContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 메시지 내용이 없고 이미지도 없으면 전송하지 않음
        guard !messageContent.isEmpty || !state.selectedImages.isEmpty else { return }
        
        print("📤 메시지 전송 시작:")
        print("   - 내용: \(messageContent)")
        print("   - 이미지 개수: \(state.selectedImages.count)")
        print("   - 방 ID: \(state.roomID)")
        print("   - 내 사용자 ID: \(state.myUserID)")
        
        // 선택된 이미지들을 Data로 변환
        let selectedImages = state.selectedImages
        
        Task {
            do {
                state.isLoading = true
                
                // 이미지가 있는 경우 Data로 변환
                var imageDataArray: [Data] = []
                if !selectedImages.isEmpty {
                    do {
                        imageDataArray = try ImageConverter.convertToData(
                            images: selectedImages.map(Optional.some),
                            compressionQuality: 0.8
                        )
                        print("📸 이미지 변환 완료: \(imageDataArray.count)개")
                        
                        state.fileUploadResponse = try await useCase.chatRoomFileUpload(state.roomID, imageDataArray)
                    } catch {
                        print("❌ 이미지 변환 실패: \(error)")
                        await MainActor.run {
                            state.isLoading = false
                            state.errorMessage = "이미지 변환 중 오류가 발생했습니다."
                        }
                        return
                    }
                }
                
                // 서버에 메시지 전송 (이미지 포함)
                let finalContent = messageContent.isEmpty && !state.selectedImages.isEmpty ? "📷 사진" : messageContent
                let response = try await useCase.postChatMessage(
                    state.roomID, 
                    PostChatMessageRequest(
                        content: finalContent, 
                        files: state.fileUploadResponse
                    )
                )
                print("✅ 서버 메시지 전송 성공: \(response)")

                
                // 전송 성공 시에만 UI 초기화
                await MainActor.run {
                    state.newMessage = ""
                    state.selectedImages = [] // 선택된 이미지들 초기화
                    state.isLoading = false
                }
                
                // 키보드 숨기기
                await MainActor.run {
                    hideKeyboard()
                }
                
            } catch {
                await MainActor.run {
                    state.isLoading = false
                    state.errorMessage = error.localizedDescription
                    print("❌ 메시지 전송 실패: \(error)")
                }
            }
        }
    }
    
    /// 뒤로 가기 버튼 탭 처리
    func handleBackButtonTapped() {
        // AppStateManager에 채팅방 퇴장 알림
        appStateManager.leaveChatRoom(state.roomID)
        
        router.pop()
    }
    
    /// 파일 첨부 버튼 탭 처리
    func handleAttachFile() {
        // 최대 5개까지만 선택 가능하도록 제한
        guard state.selectedImages.count < 5 else {
            print("📎 최대 5개의 이미지만 선택할 수 있습니다.")
            return
        }
        state.showImagePicker = true
        print("📎 이미지 선택기 열기")
    }
    
    /// 이미지 선택 처리
    func handleImagesSelected(_ images: [UIImage]) {
        // 최대 5개까지만 추가
        guard state.selectedImages.count + images.count <= 5 else {
            print("📎 최대 5개의 이미지만 선택할 수 있습니다.")
            return
        }
        
        state.selectedImages.append(contentsOf: images)
        state.showImagePicker = false
        print("📁 이미지 선택됨: 총 \(state.selectedImages.count)개")
    }
    
    /// 선택된 이미지 제거 처리
    func handleRemoveSelectedImage(_ index: Int) {
        guard index >= 0 && index < state.selectedImages.count else { return }
        state.selectedImages.remove(at: index)
        print("📁 이미지 제거됨: 총 \(state.selectedImages.count)개")
    }
    
    /// 이미지 상세보기 표시 처리
    func handleShowImageDetail(_ images: [String], _ index: Int) {
        state.detailImages = images
        state.detailImageIndex = index
        state.showImageDetail = true
        print("📸 이미지 상세보기 모달 표시: 이미지 \(index)번")
    }
    
    /// 이미지 상세보기 닫기 처리
    func handleHideImageDetail() {
        state.showImageDetail = false
        state.detailImages = []
        state.detailImageIndex = 0
        print("📸 이미지 상세보기 모달 닫기")
    }
    
    /// 실패한 메시지 재전송 처리
    func handleRetryFailedMessage(_ chatId: String) {
        // 실패한 메시지 재전송
        coreDataManager.updateChatSendStatus(chatId: chatId, status: 0) // 전송 대기로 변경
        loadMessagesFromCoreData() // UI 업데이트
    }
    
    /// 메시지 삭제 처리
    func handleDeleteMessage(_ chatId: String) {
        // 메시지 삭제 (로컬에서만)
        state.messages.removeAll { $0.id == chatId }
        // CoreData에서도 삭제하는 로직 추가 필요
    }
    
    /// 캐시 정리 처리
    func handleClearCache() {
        coreDataManager.cleanupOldFiles()
        updateCacheSize()
        showToast("캐시가 정리되었습니다.")
    }
    
    /// 메시지 새로고침 처리
    func handleRefreshMessages() {
        loadInitialMessagesFromCoreData()
        syncMessagesFromServer()
    }
    
    /// 무한스크롤로 이전 메시지 로드
    func handleLoadMoreMessages() {
        guard !state.isLoadingMore && state.hasMoreMessages else { 
            print("⚠️ 이미 로딩 중이거나 더 이상 메시지가 없음")
            return 
        }
        
        state.isLoadingMore = true
        
        Task {
            do {
                let beforeTimestamp = state.oldestLoadedTimestamp
                let gtChats = coreDataManager.fetchChatsWithCursor(
                    for: state.roomID, 
                    beforeTimestamp: beforeTimestamp, 
                    limit: 20
                )
                
                await MainActor.run {
                    if gtChats.isEmpty {
                        state.hasMoreMessages = false
                        print("📱 더 이상 불러올 메시지 없음")
                    } else {
                        let newMessages = ChatMessage.from(gtChats, currentUserNickname: state.myNickname)
                        
                        // 기존 메시지와 합치기 (중복 제거)
                        let allMessages = (newMessages + state.messages).uniqued(by: \.id)
                        state.messages = allMessages.sorted { $0.timestamp < $1.timestamp }
                        
                        // 메시지 그룹화
                        state.messageGroups = MessageGroupFactory.createMessageGroups(from: state.messages)
                        
                        // 가장 오래된 메시지 시간 업데이트
                        if let oldestMessage = newMessages.min(by: { $0.timestamp < $1.timestamp }) {
                            state.oldestLoadedTimestamp = oldestMessage.timestamp
                        }
                        
                        print("📱 추가 메시지 로드 완료: \(newMessages.count)개")
                    }
                    
                    state.isLoadingMore = false
                }
                
            } catch {
                await MainActor.run {
                    state.isLoadingMore = false
                    state.errorMessage = error.localizedDescription
                    print("❌ 추가 메시지 로드 실패: \(error)")
                }
            }
        }
    }
    
    /// 메시지 그룹이 화면에 나타날 때 처리 (무한스크롤 트리거)
    func handleMessageGroupAppeared(at index: Int) {
        // 10번째 메시지 그룹에 도달하면 추가 로드
        if index == 9 && !state.isLoadingMore && state.hasMoreMessages {
            print("📱 10번째 메시지 그룹 도달, 추가 로드 시작")
            handleLoadMoreMessages()
        }
    }
    
    // MARK: - Search Action Handlers
    
    /// 검색 모드 시작
    func handleStartSearch() {
        state.isSearchMode = true
        state.searchText = ""
        state.currentSearchQuery = ""
        searchManager.clearSearch()
        print("🔍 검색 모드 시작")
    }
    
    /// 검색 모드 종료
    func handleEndSearch() {
        state.isSearchMode = false
        state.searchText = ""
        state.currentSearchQuery = ""
        searchManager.clearSearch()
        print("🔍 검색 모드 종료")
    }
    
    /// 검색 텍스트 변경 처리
    func handleSearchTextChanged(_ text: String) {
        state.searchText = text
        
        // 실시간 검색 (빈 문자열이면 검색 초기화)
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            searchManager.clearSearch()
            state.currentSearchQuery = ""
        } else if searchManager.shouldUpdateSearch(for: text) {
            handlePerformSearch(text)
        }
    }
    
    /// 검색 실행 처리
    func handlePerformSearch(_ query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { 
            searchManager.clearSearch()
            state.currentSearchQuery = ""
            return 
        }
        
        state.currentSearchQuery = trimmedQuery
        searchManager.searchMessages(query: trimmedQuery, roomId: state.roomID, currentUserNickname: state.myNickname)
        print("🔍 검색 실행: '\(trimmedQuery)'")
    }
    
    /// 다음 검색 결과로 이동
    func handleNavigateToNextSearchResult() {
        guard searchManager.canNavigateNext else { 
            print("🔍 다음 검색 결과 없음")
            return 
        }
        
        searchManager.navigateToNext()
        if let currentResult = searchManager.currentResult {
            handleScrollToSearchResult(currentResult.messageId)
        }
    }
    
    /// 이전 검색 결과로 이동
    func handleNavigateToPreviousSearchResult() {
        guard searchManager.canNavigatePrevious else { 
            print("🔍 이전 검색 결과 없음")
            return 
        }
        
        searchManager.navigateToPrevious()
        if let currentResult = searchManager.currentResult {
            handleScrollToSearchResult(currentResult.messageId)
        }
    }
    
    /// 검색 결과로 스크롤 처리
    func handleScrollToSearchResult(_ messageId: String) {
        // UI에서 처리할 scrollToMessage 이벤트 발생
        // NotificationCenter를 통해 MessageListSectionView로 전달
        NotificationCenter.default.post(
            name: .scrollToMessage,
            object: nil,
            userInfo: ["messageId": messageId]
        )
        print("🔍 메시지로 스크롤 요청: \(messageId.prefix(8))")
    }
}

// MARK: - CoreData Integration
@MainActor
private extension ChatViewStore {
    /// CoreData에서 초기 메시지 로드 (최신 20개)
    func loadInitialMessagesFromCoreData() {
        print("📊 초기 메시지 로드 시작 - 현재 사용자 닉네임: '\(state.myNickname)'")
        let gtChats = coreDataManager.fetchChatsWithCursor(for: state.roomID, beforeTimestamp: nil, limit: 20)
        let chatMessages = ChatMessage.from(gtChats, currentUserNickname: state.myNickname)
        
        // 시간순 정렬 (오래된 것부터)
        state.messages = chatMessages.sorted { $0.timestamp < $1.timestamp }
        
        // 메시지 그룹화
        state.messageGroups = MessageGroupFactory.createMessageGroups(from: state.messages)
        
        // 가장 오래된 메시지 시간 설정
        if let oldestMessage = state.messages.first {
            state.oldestLoadedTimestamp = oldestMessage.timestamp
        }
        
        // 더 불러올 메시지가 있는지 확인
        state.hasMoreMessages = chatMessages.count == 20
        
        // isFromMe 검증을 위한 추가 로그
        let myMessages = chatMessages.filter { $0.isFromMe }
        let otherMessages = chatMessages.filter { !$0.isFromMe }
        print("📊 메시지 로드 완료:")
        print("   - 전체 메시지: \(chatMessages.count)개")
        print("   - 내 메시지: \(myMessages.count)개")
        print("   - 상대방 메시지: \(otherMessages.count)개")
        print("   - 그룹: \(state.messageGroups.count)개")
    }
    
    /// CoreData에서 메시지 로드 (호환성을 위해 유지)
    func loadMessagesFromCoreData() {
        let gtChats = coreDataManager.fetchChats(for: state.roomID, limit: 100)
        let chatMessages = ChatMessage.from(gtChats, currentUserNickname: state.myNickname)
        
        // 시간순 정렬 (오래된 것부터)
        state.messages = chatMessages.sorted { $0.timestamp < $1.timestamp }
        
        // 메시지 그룹화
        state.messageGroups = MessageGroupFactory.createMessageGroups(from: state.messages)
        
        print("📱 CoreData에서 \(chatMessages.count)개 메시지 로드, 그룹: \(state.messageGroups.count)개")
    }
    
    /// 서버에서 메시지 동기화 (개선된 버전)
    func syncMessagesFromServer() {
        state.isLoading = true
        state.errorMessage = nil
        
        Task {
            do {
                // 1. 현재 시간 기준으로 서버에서 최신 메시지 가져오기
                let chatResponses = try await useCase.getChatHistory(state.roomID, state.next ?? "")
                
                // 2. 새로운 메시지만 필터링하여 CoreData에 저장
                let newMessagesCount = coreDataManager.saveNewMessagesFromServer(chatResponses, roomId: state.roomID, currentUserNickname: state.myNickname)
                
                // 3. CoreData에서 업데이트된 데이터 다시 로드하여 UI 업데이트
                await MainActor.run {
                    if newMessagesCount > 0 {
                        // 새 메시지가 있으면 전체 다시 로드
                        self.loadInitialMessagesFromCoreData()
                        print("🌐 서버 동기화 완료: \(newMessagesCount)개 새 메시지 추가")
                    } else {
                        print("🌐 서버 동기화 완료: 새 메시지 없음")
                    }
                    state.isLoading = false
                }
                
            } catch {
                await MainActor.run {
                    state.isLoading = false
                    state.errorMessage = error.localizedDescription
                    print("❌ 서버 동기화 실패: \(error)")
                }
            }
        }
    }
    
    /// 서버 응답을 CoreData에 저장
    private func saveChatHistoryToCoreData(_ response: [ChatResponse]) async {
        print("📥 서버 응답 처리 시작: \(response.count)개 메시지")
        
        await MainActor.run {
            // 중복 체크를 위해 기존 메시지 ID들 수집
            let existingMessageIds = Set(state.messages.map { $0.id })
            var newMessagesCount = 0
            
            print("🔍 현재 화면에 있는 메시지 ID들: \(existingMessageIds)")
            
            // 서버에서 받은 메시지들을 CoreData에 저장
            for (index, chatResponse) in response.enumerated() {
                print("📨 메시지 \(index + 1)/\(response.count) 처리:")
                print("   - 메시지 ID: \(chatResponse.chatID)")
                print("   - 보낸 사람: \(chatResponse.sender.userID) (\(chatResponse.sender.nick))")
                print("   - 내용: \(chatResponse.content)")
                
                if !existingMessageIds.contains(chatResponse.chatID) {
                    // 새로운 메시지만 CoreData에 저장
                    let timestamp = parseDate(from: chatResponse.createdAt) ?? Date()
                    
                    // 메시지 발신자 구분 (nickname으로 비교)
                    print("   - 발신자 구분: \(chatResponse.sender.nick) == \(state.myNickname)")
                    let isMyMessage = chatResponse.sender.nick == state.myNickname
                    
                    let _ = coreDataManager.createChatFromServer(
                        chatId: chatResponse.chatID,
                        content: chatResponse.content,
                        roomId: chatResponse.roomID,
                        userId: chatResponse.sender.userID,
                        senderNickname: chatResponse.sender.nick,
                        timestamp: timestamp,
                        files: chatResponse.files.isEmpty ? nil : chatResponse.files,
                        currentUserNickname: state.myNickname
                    )
                    
                    // 사용자 정보 업데이트 (발신자 구분 포함)
                    let _ = coreDataManager.fetchOrCreateUser(
                        userId: chatResponse.sender.userID,
                        nickname: chatResponse.sender.nick,
                        profileImageUrl: chatResponse.sender.profileImage,
                        isCurrentUser: isMyMessage
                    )
                    
                    newMessagesCount += 1
                    
                    if isMyMessage {
                        print("✅ 내가 보낸 메시지로 CoreData에 저장: \(chatResponse.content)")
                    } else {
                        print("✅ 상대방이 보낸 메시지로 CoreData에 저장: \(chatResponse.content)")
                    }
                } else {
                    print("⚠️ 이미 존재하는 메시지, 건너뜀: \(chatResponse.chatID)")
                }
            }
            
            // CoreData 저장
            coreDataManager.saveContext()
            
            print("💾 서버 데이터 CoreData 저장 완료: \(newMessagesCount)개의 새 메시지")
        }
    }
    
    /// 날짜 문자열을 Date 객체로 변환
    func parseDate(from dateString: String) -> Date? {
        return DateFormatterManager.shared.parseISO8601Date(from: dateString)
    }
}

private extension ChatViewStore {
    /// 알림 옵저버 설정
    func setupNotificationObservers() async {
        
        // 새 메시지 수신 알림
        let newMessageObserver = NotificationCenter.default.addObserver(
            forName: .chatNewMessageReceived,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let userInfo = notification.userInfo,
                  let roomId = userInfo["roomId"] as? String,
                  roomId == self.state.roomID else { 
                print("🔔 메시지 알림 무시: 다른 채팅방 또는 유효하지 않은 데이터")
                return 
            }
            
            // 새 메시지 정보 추출
            guard let chatId = userInfo["chatId"] as? String,
                  let content = userInfo["content"] as? String,
                  let userId = userInfo["userId"] as? String,
                  let nickname = userInfo["nickname"] as? String,
                  let _ = userInfo["timestamp"] as? TimeInterval,
                  let isMyMessage = userInfo["isMyMessage"] as? Bool else {
                print("❌ Invalid message notification data")
                return
            }
            
            
            print("🔔 새 메시지 알림 수신:")
            print("   - 메시지 ID: \(chatId)")
            print("   - 보낸 사람: \(userId) (\(nickname))")
            print("   - 내용: \(content)")
            print("   - 내 메시지: \(isMyMessage)")
            print("   - 현재 화면 메시지 수: \(self.state.messages.count)")
            
            // 중복 체크 (이미 화면에 있는 메시지인지 확인)
            let existingMessage = self.state.messages.first { $0.id == chatId }
            if existingMessage != nil {
                print("   ⚠️ 이미 화면에 있는 메시지, 새로고침 건너뜀: \(chatId)")
                return
            }
            
            print("   🔄 새로운 메시지, CoreData에서 다시 로드 중...")
            
            // CoreData에서 새로운 메시지 로드하여 화면에 추가
            
            let beforeCount = self.state.messages.count
            self.loadInitialMessagesFromCoreData()
            let afterCount = self.state.messages.count
            
            print("   📱 메시지 로드 완료: \(beforeCount) → \(afterCount), 그룹: \(self.state.messageGroups.count)개")
            
            // 새 메시지 알림 로그
            if isMyMessage {
                print("   ✅ 내가 보낸 메시지가 화면에 추가됨: \(content)")
            } else {
                print("   ✅ 상대방 메시지가 화면에 추가됨: \(content)")
            }
        }
        notificationObservers.append(newMessageObserver)
        
        // WebSocket 연결 상태 변경 알림
        let webSocketConnectedObserver = NotificationCenter.default.addObserver(
            forName: .chatWebSocketConnected,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateConnectionState()
            print("🔗 WebSocket 연결됨")
        }
        notificationObservers.append(webSocketConnectedObserver)
        
        let webSocketDisconnectedObserver = NotificationCenter.default.addObserver(
            forName: .chatWebSocketDisconnected,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateConnectionState()
            print("🔗 WebSocket 연결 해제됨")
        }
        notificationObservers.append(webSocketDisconnectedObserver)
    }
    
    /// 연결 상태 업데이트
    func updateConnectionState() {
        state.isConnected = webSocketManager.isConnected
    }
}


// MARK: - Utility Methods
@MainActor
private extension ChatViewStore {
    /// 캐시 크기 업데이트
    func updateCacheSize() {
        let sizeInBytes = coreDataManager.getCacheSize()
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        state.cacheSize = formatter.string(fromByteCount: sizeInBytes)
    }
    
    /// 토스트 메시지 표시
    func showToast(_ message: String) {
        // Toast 메시지 표시 구현
        print("🍞 Toast: \(message)")
    }
    
    /// 키보드 숨기기
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
} 
