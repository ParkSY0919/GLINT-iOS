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
    var newMessage: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var isConnected: Bool = false
    var unreadCount: Int = 0
    var selectedImages: [UIImage] = [] // UIImage 배열로 변경 (옵셔널 제거)
    var showImagePicker: Bool = false
    var showImageDetail: Bool = false // 이미지 상세보기 모달
    var detailImages: [String] = [] // 상세보기할 이미지 URL들
    var detailImageIndex: Int = 0 // 현재 선택된 이미지 인덱스
    var isUploading: Bool = false
    var uploadProgress: Double = 0.0
    var cacheSize: String = "0 MB"
    var relativeUserId: String = ""
    var myUserID: String = ""
    var myAccessToken: String = ""
    var fileUploadResponse: [String]?
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
        state.myUserID = keyChainManager.getUserId() ?? ""
        print("state.myUserID: \(state.myUserID)")
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
        
        // WebSocket 채팅방 참여
        webSocketManager.joinChatRoom(roomId: roomID, accessToken: keyChainManager.getAccessToken() ?? "꽝")
        
        // 현재 사용자 생성/조회 (내 정보)
        _ = coreDataManager.fetchOrCreateUser(
            userId: state.myUserID,
            nickname: "psy", // 내 닉네임
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
        
        // CoreData에서 메시지 로드
        loadMessagesFromCoreData()
        
        // 연결 상태 업데이트
        updateConnectionState()
        
        // 캐시 크기 업데이트
        updateCacheSize()
        
        // 서버에서 최신 메시지 동기화
        syncMessagesFromServer()
    }
    
    /// 뷰가 사라졌을 때의 처리
    func handleViewDisappeared() {
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
        loadMessagesFromCoreData()
        syncMessagesFromServer()
    }
}

// MARK: - CoreData Integration
@MainActor
private extension ChatViewStore {
    /// CoreData에서 메시지 로드
    func loadMessagesFromCoreData() {
        let gtChats = coreDataManager.fetchChats(for: state.roomID, limit: 100)
        let chatMessages = ChatMessage.from(gtChats, currentUserId: state.myUserID)
        
        // 시간순 정렬 (오래된 것부터)
        state.messages = chatMessages.sorted { $0.timestamp < $1.timestamp }
        
        print("📱 CoreData에서 \(chatMessages.count)개 메시지 로드")
    }
    
    /// 서버에서 메시지 동기화
    func syncMessagesFromServer() {
        state.isLoading = true
        state.errorMessage = nil
        
        // 1. 먼저 CoreData에서 기존 데이터 로드 (즉시 UI 업데이트)
        loadMessagesFromCoreData()
        
        Task {
            do {
                let chatResponses = try await useCase.getChatHistory(state.roomID, state.next ?? "")
                
                // 2. 서버 응답을 CoreData에 저장
                await saveChatHistoryToCoreData(chatResponses)
                
                // 3. CoreData에서 업데이트된 데이터 다시 로드하여 UI 업데이트
                await MainActor.run {
                    self.loadMessagesFromCoreData()
                    state.isLoading = false
                    print("🌐 서버 동기화 완료: \(chatResponses.count)개 메시지 처리")
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
                    
                    // 메시지 발신자 구분
                    print("   - 발신자 구분: \(chatResponse.sender.userID) == \(state.myUserID)")
                    let isMyMessage = chatResponse.sender.userID == state.myUserID
                    
                    let _ = coreDataManager.createChatFromServer(
                        chatId: chatResponse.chatID,
                        content: chatResponse.content,
                        roomId: chatResponse.roomID,
                        userId: chatResponse.sender.userID,
                        timestamp: timestamp,
                        files: chatResponse.files.isEmpty ? nil : chatResponse.files
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
            self.loadMessagesFromCoreData()
            let afterCount = self.state.messages.count
            
            print("   📱 메시지 로드 완료: \(beforeCount) → \(afterCount)")
            
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
