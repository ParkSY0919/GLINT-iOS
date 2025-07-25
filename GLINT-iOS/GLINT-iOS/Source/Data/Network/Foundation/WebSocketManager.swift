//
//  WebSocketManager.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/10/25.
//

import UIKit
import SocketIO

enum WebSocketState {
    case disconnected
    case connecting
    case connected
    case reconnecting
}

final class WebSocketManager: NSObject {
    static let shared = WebSocketManager()
    
    // Socket.IO 관련 프로퍼티
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    private let socketURL = String(Config.baseURL.dropLast())
    
    
    // 연결 상태 관리
    private var currentState: WebSocketState = .disconnected
    private var reconnectTimer: Timer?
    private var heartbeatTimer: Timer?
    
    // 연결 관리 변수들
    private var isAppInForeground = true
    private var activeChatRooms: Set<String> = []
    private var currentRoomID: String? // 현재 활성 채팅방 ID 저장
    private var accessToken: String?
    private var lastDisconnectTime: Date?
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    
    // Core Data Manager
    private let coreDataManager = CoreDataManager.shared
    private let keychainManager = KeychainManager.shared
    
    private override init() {
        super.init()
        setupNotificationObservers()
    }
    
    // MARK: - Socket Setup
    private func setupSocket() {
        guard let url = URL(string: socketURL) else {
            print("❌ Invalid socket URL")
            return
        }
        
        guard let token = accessToken,
              let roomID = currentRoomID else {
            print("setupSocket: 실패~~~")
            return
        }
        
        print("현재의 aToken: \(token)")
        
        // SocketManager 설정
        manager = SocketManager(
            socketURL: url,
            config: [
                .log(true),
                .compress,
                .reconnects(true),
                .reconnectAttempts(maxReconnectAttempts),
                .reconnectWait(10),
                .forceWebsockets(true),
                .extraHeaders(["SeSACKey": Config.sesacKey, "Authorization": token])
            ]
        )
        
        socket = manager?.socket(forNamespace: "/chats-\(roomID)")
        print("✅ Socket 설정 완료 - 채팅방: \(roomID)")
        
        
        // Socket 이벤트 핸들러 설정
        setupSocketHandlers()
    }
    
    // MARK: - Socket Event Handlers
    private func setupSocketHandlers() {
        // 연결 성공
        socket?.on(clientEvent: .connect) { [weak self] data, ack in
            print("✅ Socket connected")
            self?.onConnected()
        }
        
        // 연결 해제
        socket?.on(clientEvent: .disconnect) { [weak self] data, ack in
            print("❌ Socket disconnected")
            self?.onDisconnected()
        }
        
        // 에러 발생
        socket?.on(clientEvent: .error) { data, ack in
            print("❌ Socket error: \(data)")
        }
        
        // 재연결 시도
        socket?.on(clientEvent: .reconnect) { data, ack in
            print("🔄 Socket reconnecting...")
        }
        
        // 재연결 시도 중
        socket?.on(clientEvent: .reconnectAttempt) { data, ack in
            print("🔄 Reconnect attempt: \(data)")
        }
        
        // 채팅 메시지 수신
        socket?.on("chat") { [weak self] data, ack in
            print("💬 Chat received: \(data)")
            self?.handleChatMessage(data)
        }
        
        // 채팅방 참여 성공
        socket?.on("joined_room") { data, ack in
            print("✅ Joined room: \(data)")
        }
        
        // 채팅방 퇴장 성공
        socket?.on("left_room") { data, ack in
            print("👋 Left room: \(data)")
        }
        
        // 하트비트 응답
        socket?.on("pong") { data, ack in
            print("💓 Pong received")
        }
    }
    
    // MARK: - Public Interface
    func joinChatRoom(roomId: String, accessToken: String) {
        activeChatRooms.insert(roomId)
        currentRoomID = roomId // 현재 채팅방 ID 업데이트
        self.accessToken = accessToken
        
        // 연결이 필요하면 연결
        connectIfNeeded()
        
        // 연결되어 있으면 바로 채팅방 참여
        if currentState == .connected {
            socket?.emit("join_room", ["roomId": roomId])
            print("Joining room: \(roomId)")
        }
    }
    
    func leaveChatRoom(_ roomId: String) {
        activeChatRooms.remove(roomId)
        currentRoomID = nil // 현재 채팅방 ID 초기화
        
        // 연결되어 있으면 채팅방 퇴장
        if currentState == .connected {
            socket?.emit("leave_room", ["roomId": roomId])
        }
        
        print("Leaving room: \(roomId)")
        
        // 더 이상 활성 채팅방이 없으면 연결 해제 고려
        if activeChatRooms.isEmpty {
            scheduleDisconnection()
        }
    }
    
    func sendMessage(_ content: String, to roomId: String, files: [String]? = nil) {
        // 로컬에 먼저 저장
        let chat = coreDataManager.createLocalChat(
            content: content,
            fileURLs: nil, // 파일 URL 처리는 별도로
            roomId: roomId,
            userId: getCurrentUserId()
        )
        
        let message: [String: Any] = [
            "chatId": chat.chatId ?? UUID().uuidString,
            "roomId": roomId,
            "content": content,
            "userId": getCurrentUserId(),
            "files": files ?? [],
            "timestamp": Date().timeIntervalSince1970
        ]
        
        // 연결 상태에 따라 처리
        if currentState == .connected {
            socket?.emit("send_message", message)
            print("📤 Sending message: \(message)")
        } else {
            print("💾 Message saved offline, will send when connected")
        }
    }
}

// MARK: - Connection Management
extension WebSocketManager {
    private func connectIfNeeded() {
        guard shouldConnect() else { return }
        
        if currentState == .disconnected {
            connect()
        }
    }
    
    private func shouldConnect() -> Bool {
        return isAppInForeground &&
        !activeChatRooms.isEmpty &&
        currentState != .connected &&
        currentState != .connecting
    }
    
    private func connect() {
        guard currentState == .disconnected else { return }
        
        currentState = .connecting
        cancelReconnectTimer()
        
        // socket이 없으면 먼저 초기화
        if socket == nil {
            setupSocket()
        }
        
        // socket이 여전히 nil이면 에러 처리
        guard let socket = socket else {
            print("❌ Failed to initialize socket")
            currentState = .disconnected
            return
        }
        
        socket.connect()
        print("🔌 WebSocket connecting...")
    }
    
    private func scheduleDisconnection() {
        // 즉시 해제하지 않고 5초 대기
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            guard let self = self else { return }
            if self.activeChatRooms.isEmpty && self.isAppInForeground {
                self.disconnect()
            }
        }
    }
    
    private func disconnect() {
        guard currentState == .connected || currentState == .connecting else { return }
        
        currentState = .disconnected
        cancelHeartbeat()
        cancelReconnectTimer()
        
        socket?.disconnect()
        
        print("🔌 WebSocket disconnected")
        lastDisconnectTime = Date()
    }
    
    private func forceDisconnect() {
        disconnect()
        activeChatRooms.removeAll()
    }
}

extension WebSocketManager {
        private func setupNotificationObservers() {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(appWillEnterForeground),
                name: UIApplication.willEnterForegroundNotification,
                object: nil
            )
    
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(appDidEnterBackground),
                name: UIApplication.didEnterBackgroundNotification,
                object: nil
            )
    
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(appWillTerminate),
                name: UIApplication.willTerminateNotification,
                object: nil
            )
        }
    
    @objc private func appWillEnterForeground() {
        isAppInForeground = true
        
        // 백그라운드에서 너무 오래 있었으면 재연결
        if let lastDisconnect = lastDisconnectTime,
           Date().timeIntervalSince(lastDisconnect) > 300 { // 5분
            reconnectAttempts = 0
        }
        
        connectIfNeeded()
        processOfflineMessages()
    }
    
    @objc private func appDidEnterBackground() {
        isAppInForeground = false
        
        // 백그라운드에서는 30초 후 연결 해제
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) { [weak self] in
            guard let self = self else { return }
            if !self.isAppInForeground {
                self.disconnect()
            }
        }
    }
    
    @objc private func appWillTerminate() {
        forceDisconnect()
    }
}

// MARK: - Socket Event Callbacks
extension WebSocketManager {
    private func onConnected() {
        currentState = .connected
        reconnectAttempts = 0
        startHeartbeat()
        
        // 기존 채팅방들에 재참여
        if let currentRoomId = currentRoomID {
            socket?.emit("join_room", ["roomId": currentRoomId])
            print("🔄 Rejoining room: \(currentRoomId)")
        }
        
        // 오프라인 메시지 전송
        processOfflineMessages()
        
        // 연결 성공 알림
        ChatNotificationHelper.postWebSocketConnected()
    }
    
    private func onDisconnected() {
        currentState = .disconnected
        cancelHeartbeat()
        
        // 자동 재연결 시도
        if isAppInForeground && !activeChatRooms.isEmpty {
            scheduleReconnection()
        }
        
        // 연결 해제 알림
        ChatNotificationHelper.postWebSocketDisconnected()
    }
    
    private func handleChatMessage(_ data: [Any]) {
        guard let messageData = data.first as? [String: Any] else {
            print("❌ Invalid chat message format")
            return
        }
        
        // 메시지 데이터 파싱
        guard let chatId = messageData["chat_id"] as? String,
              let content = messageData["content"] as? String,
              let roomId = messageData["room_id"] as? String,
              let sender = messageData["sender"] as? [String: Any],
              let userId = sender["user_id"] as? String,
              let createdAtString = messageData["createdAt"] as? String,
              let timestamp = {
                  let formatter = ISO8601DateFormatter()
                  formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                  return formatter.date(from: createdAtString)?.timeIntervalSince1970
              }()
        else {
            print("❌ Missing required chat message fields")
            return
        }
        
        // 중복 메시지 체크
        let existingChat = coreDataManager.fetchChat(by: chatId)
        if existingChat != nil {
            print("⚠️ 이미 존재하는 메시지, 중복 처리 건너뜀: \(chatId)")
            return
        }
        
        // 사용자 정보 파싱
        let nickname = sender["nick"] as? String ?? "사용자"
        let profileImage = sender["profileImage"] as? String
        let files = messageData["files"] as? [String]
        
        // 메시지 시간 생성
        let messageDate = Date(timeIntervalSince1970: timestamp)
        
        // 현재 사용자 ID 가져오기
        let currentUserId = getCurrentUserId()
        let isMyMessage = userId == currentUserId
        
        print("🔍 WebSocket 메시지 분석:")
        print("   - 채팅 ID: \(chatId)")
        print("   - 보낸 사람: \(userId) (\(nickname))")
        print("   - 현재 사용자: \(currentUserId)")
        print("   - 내 메시지 여부: \(isMyMessage)")
        print("   - 내용: \(content)")
        
        // Core Data에 저장
        let chat = coreDataManager.createChatFromServer(
            chatId: chatId,
            content: content,
            roomId: roomId,
            userId: userId,
            timestamp: messageDate,
            files: files
        )
        
        // 사용자 정보 업데이트
        let _ = coreDataManager.fetchOrCreateUser(
            userId: userId,
            nickname: nickname,
            profileImageUrl: profileImage,
            isCurrentUser: isMyMessage
        )
        
        // UI 업데이트 알림
        DispatchQueue.main.async {
            ChatNotificationHelper.postNewMessage(
                roomId: roomId,
                chatId: chatId,
                content: content,
                userId: userId,
                nickname: nickname,
                timestamp: timestamp,
                isMyMessage: isMyMessage
            )
        }
        
        if isMyMessage {
            print("💬 내가 보낸 메시지 WebSocket 수신 처리 완료: \(content)")
        } else {
            print("💬 상대방 메시지 WebSocket 수신 처리 완료: \(content)")
        }
    }
}

// MARK: - Reconnection Logic
extension WebSocketManager {
    private func scheduleReconnection() {
        guard reconnectAttempts < maxReconnectAttempts else {
            print("❌ Max reconnection attempts reached")
            currentState = .disconnected
            return
        }
        
        let delay = min(pow(2.0, Double(reconnectAttempts)), 30.0) // Exponential backoff
        reconnectAttempts += 1
        
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            if self.shouldConnect() {
                self.currentState = .reconnecting
                self.connect()
            }
        }
        
        print("🔄 Scheduling reconnection in \(delay) seconds (attempt \(reconnectAttempts))")
    }
    
    private func cancelReconnectTimer() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
    }
}

// MARK: - Heartbeat
extension WebSocketManager {
    private func startHeartbeat() {
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.socket?.emit("ping", ["timestamp": Date().timeIntervalSince1970])
            print("💓 Sending heartbeat")
        }
    }
    
    private func cancelHeartbeat() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
    }
}

// MARK: - Offline Message Handling
extension WebSocketManager {
    private func processOfflineMessages() {
        // sendStatus가 0인 메시지들 조회
        let pendingChats = coreDataManager.fetchChats(for: "").filter { $0.sendStatus == 0 }
        
        for chat in pendingChats {
            guard let roomId = chat.roomId,
                  let content = chat.content else { continue }
            
            let message: [String: Any] = [
                "chatId": chat.chatId ?? UUID().uuidString,
                "roomId": roomId,
                "content": content,
                "userId": chat.sender?.userId ?? "",
                "timestamp": (chat.createdAt ?? Date()).timeIntervalSince1970
            ]
            
            socket?.emit("send_message", message)
            
            // 전송 상태 업데이트
            chat.sendStatus = 1
            coreDataManager.saveContext()
        }
        
        print("📤 Processed \(pendingChats.count) offline messages")
    }
    
    private func getCurrentUserId() -> String {
        // 실제 구현에서는 로그인한 사용자 ID 반환
        return keychainManager.getUserId() ?? "test_user"
    }
}

// MARK: - Public Status Methods
extension WebSocketManager {
    var isConnected: Bool {
        return currentState == .connected
    }
    
    var connectionState: WebSocketState {
        return currentState
    }
    
    var activeRoomsCount: Int {
        return activeChatRooms.count
    }
    
    // 연결 상태 UI 업데이트용
    func addConnectionStateObserver(_ observer: Any, selector: Selector) {
        NotificationCenter.default.addObserver(
            observer,
            selector: selector,
            name: .chatWebSocketConnected,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            observer,
            selector: selector,
            name: .chatWebSocketDisconnected,
            object: nil
        )
    }
    
    /// FCM 푸시 알림을 통해 특정 채팅방 동기화
    func syncChatRoom(roomId: String) {
        print("💬 FCM을 통한 채팅방 동기화 요청: \(roomId)")
        
        // 현재 해당 채팅방에 있지 않은 경우에만 동기화
        guard currentRoomID != roomId else {
            print("📱 현재 채팅방과 동일 - 동기화 건너뜀")
            return
        }
        
        // WebSocket이 연결된 상태에서 실시간 데이터 요청
        if isConnected {
            socket?.emit("sync_room", ["roomId": roomId])
            print("🔄 WebSocket을 통한 채팅방 동기화 요청 전송: \(roomId)")
        }
        
        // CoreData에서 해당 채팅방의 최신 데이터 확인
        let localMessages = coreDataManager.fetchChats(for: roomId, limit: 50)
        print("📱 로컬 메시지 개수: \(localMessages.count)")
        
        // 서버와 동기화 (필요시 REST API 호출)
        Task {
            await performServerSync(for: roomId)
        }
    }
    
    /// 서버와 채팅방 동기화 (REST API)
    private func performServerSync(for roomId: String) async {
        // TODO: ChatViewUseCase를 통한 서버 동기화
        print("🌐 서버와 채팅방 동기화 시작: \(roomId)")
        
        // 실제 구현에서는 ChatRepository를 통해 최신 메시지 가져오기
        // 예시: 
        // let chatRepo = ChatRepository.liveValue
        // let messages = try await chatRepo.getChatHistory(roomId, "")
        
        // 동기화는 내부적으로 처리하고 별도 알림 없이 완료
        print("🌐 서버와 채팅방 동기화 완료: \(roomId)")
    }
}

// MARK: - Notification Names are now managed in ChatNotifications.swift
