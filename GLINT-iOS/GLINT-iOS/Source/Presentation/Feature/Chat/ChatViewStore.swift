//
//  ChatViewStore.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/8/25.
//

import SwiftUI
import Combine

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
    var selectedFiles: [URL] = []
    var isUploading: Bool = false
    var uploadProgress: Double = 0.0
    var cacheSize: String = "0 MB"
    var relativeUserId: String = ""
    var myUserID: String = ""
    var myAccessToken: String = ""
}

enum ChatViewAction {
    case viewAppeared(_ roomID: String, _ nick: String, _ userID: String)
    case viewDisappeared
    case messageTextChanged(String)
    case sendButtonTapped(String)
    case backButtonTapped
    case attachFileButtonTapped
    case filesSelected([URL])
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
    
    nonisolated private var cancellables = Set<AnyCancellable>()
    
    init(useCase: ChatViewUseCase, router: NavigationRouter<MainTabRoute>) {
        self.useCase = useCase
        self.router = router
        
        // 비동기로 설정 초기화
        Task {
            await setupAsync()
        }
    }
    
    deinit {
        cancellables.removeAll()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupAsync() async {
        state.myUserID = keyChainManager.getUserId() ?? ""
        print("state.myUserID: \(state.myUserID)")
        await setupNotificationObservers()
        await setupRealtimeUpdates()
    }
    
    func send(_ action: ChatViewAction) {
        switch action {
        case .viewAppeared(let roomID, let nick, let userID):
            handleViewAppeared(roomID, nick, userID)
            
        case .viewDisappeared:
            handleViewDisappeared()
            
        case .messageTextChanged(let text):
            state.newMessage = text
            
        case .sendButtonTapped(let content):
            handleSendMessage(content)
            
        case .backButtonTapped:
            router.pop()
            
        case .attachFileButtonTapped:
            handleAttachFile()
            
        case .filesSelected(let urls):
            handleFilesSelected(urls)
            
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

// MARK: - Private Methods
private extension ChatViewStore {
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
    
    func handleViewDisappeared() {
        // WebSocket 채팅방 떠나기
        webSocketManager.leaveChatRoom(state.roomID)
    }
    
    func handleSendMessage(_ content: String) {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let messageContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("📤 메시지 전송 시작:")
        print("   - 내용: \(messageContent)")
        print("   - 방 ID: \(state.roomID)")
        print("   - 내 사용자 ID: \(state.myUserID)")
        
        // 파일이 첨부된 경우
        let fileURLs = state.selectedFiles.isEmpty ? nil : state.selectedFiles
        
        Task {
            do {
                state.isLoading = true
                
                // 서버에 메시지 전송
                let response = try await useCase.postChatMessage(state.roomID, PostChatMessageRequest(content: messageContent, files: nil))
                print("✅ 서버 메시지 전송 성공: \(response)")
                
                // 전송 성공 시에만 UI 초기화
                await MainActor.run {
                    state.newMessage = ""
                    state.selectedFiles = []
                    state.isLoading = false
                }
                
                // 파일 업로드 (별도 처리)
                if let fileURLs = fileURLs {
                    uploadFiles(chatId: state.roomID, fileURLs: fileURLs)
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
    
    func handleAttachFile() {
        // 파일 선택 UI 표시 (실제 구현에서는 DocumentPicker나 ImagePicker 사용)
//        ImagePicker
        print("📎 파일 첨부 버튼 클릭")
    }
    
    func handleFilesSelected(_ urls: [URL]) {
        state.selectedFiles = urls
        print("📁 선택된 파일: \(urls.count)개")
    }
    
    func handleRetryFailedMessage(_ chatId: String) {
        // 실패한 메시지 재전송
        coreDataManager.updateChatSendStatus(chatId: chatId, status: 0) // 전송 대기로 변경
        coreDataManager.processOfflineData() // 오프라인 데이터 처리
        loadMessagesFromCoreData() // UI 업데이트
    }
    
    func handleDeleteMessage(_ chatId: String) {
        // 메시지 삭제 (로컬에서만)
        state.messages.removeAll { $0.id == chatId }
        // CoreData에서도 삭제하는 로직 추가 필요
    }
    
    func handleClearCache() {
        coreDataManager.cleanupOldFiles()
        updateCacheSize()
        showToast("캐시가 정리되었습니다.")
    }
    
    func handleRefreshMessages() {
        loadMessagesFromCoreData()
        syncMessagesFromServer()
    }
}

// MARK: - CoreData Integration
private extension ChatViewStore {
    func loadMessagesFromCoreData() {
        let gtChats = coreDataManager.fetchChats(for: state.roomID, limit: 100)
        let chatMessages = ChatMessage.from(gtChats, currentUserId: state.myUserID)
        
        // 시간순 정렬 (오래된 것부터)
        state.messages = chatMessages.sorted { $0.timestamp < $1.timestamp }
        
        print("📱 CoreData에서 \(chatMessages.count)개 메시지 로드")
    }
    
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
                        print("   ✅ 내가 보낸 메시지로 CoreData에 저장: \(chatResponse.content)")
                    } else {
                        print("   ✅ 상대방이 보낸 메시지로 CoreData에 저장: \(chatResponse.content)")
                    }
                } else {
                    print("   ⚠️ 이미 존재하는 메시지, 건너뜀: \(chatResponse.chatID)")
                }
            }
            
            // CoreData 저장
            coreDataManager.saveContext()
            
            print("💾 서버 데이터 CoreData 저장 완료: \(newMessagesCount)개의 새 메시지")
        }
    }
    
    private func parseDate(from dateString: String) -> Date? {
        return DateFormatterManager.shared.parseISO8601Date(from: dateString)
    }
}

// MARK: - WebSocket Integration
private extension ChatViewStore {
    func setupNotificationObservers() async {
        // 새 메시지 수신 알림
        NotificationCenter.default.addObserver(
            forName: .newMessageReceived,
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
                  let timestamp = userInfo["timestamp"] as? TimeInterval,
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
        
        // 연결 상태 변경 알림
        NotificationCenter.default.addObserver(
            forName: .webSocketConnected,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateConnectionState()
            print("🔗 WebSocket 연결됨")
        }
        
        NotificationCenter.default.addObserver(
            forName: .webSocketDisconnected,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateConnectionState()
            print("🔗 WebSocket 연결 해제됨")
        }
    }
    
    nonisolated private func setupRealtimeUpdates() async {
        await MainActor.run {
            Timer.publish(every: 1.0, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    Task { @MainActor in
                        self?.updateConnectionState()
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    func updateConnectionState() {
        state.isConnected = webSocketManager.isConnected
    }
}

// MARK: - File Upload
private extension ChatViewStore {
    func uploadFiles(chatId: String, fileURLs: [URL]) {
        state.isUploading = true
        state.uploadProgress = 0.0
        
        Task {
            for (index, fileURL) in fileURLs.enumerated() {
                do {
                    // 실제 파일 업로드 로직
                    // 추후 return 값 사용
                    let _ = try await uploadFile(fileURL)
                    
                    // 진행률 업데이트
                    let progress = Float(index + 1) / Float(fileURLs.count)
                    await MainActor.run {
                        state.uploadProgress = Double(progress)
                    }
                    
                    // CoreData 업데이트
                    // coreDataManager.updateFileServerPath(fileId: fileId, serverPath: uploadedPath)
                    
                } catch {
                    print("❌ 파일 업로드 실패: \(error)")
                }
            }
            
            await MainActor.run {
                state.isUploading = false
                state.uploadProgress = 0.0
            }
        }
    }
    
    private func uploadFile(_ fileURL: URL) async throws -> String {
        // 실제 파일 업로드 구현
        // URLSession을 사용한 multipart/form-data 업로드
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2초 시뮬레이션
        return "https://server.com/files/\(UUID().uuidString)"
    }
}

// MARK: - Utility Methods
private extension ChatViewStore {
    func updateCacheSize() {
        let sizeInBytes = coreDataManager.getCacheSize()
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        state.cacheSize = formatter.string(fromByteCount: sizeInBytes)
    }
    
    func showToast(_ message: String) {
        // Toast 메시지 표시 구현
        print("🍞 Toast: \(message)")
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
} 
