//
//  CoreDataManager.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/10/25.
//

import UIKit
import CoreData
import AVFoundation

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ChatDataModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("CoreData error: \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    // MARK: - Save Context
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("CoreData save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func saveBackgroundContext(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Background context save error: \(error)")
            }
        }
    }
}

// MARK: - User Management
extension CoreDataManager {
    func createUser(userId: String, nickname: String, profileImageUrl: String?, isCurrentUser: Bool) -> GTUser {
        let user = GTUser(context: context)
        user.userId = userId
        user.nickname = nickname
        user.profileImageUrl = profileImageUrl
        user.isCurrentUser = isCurrentUser
        
        saveContext()
        return user
    }
    
    func fetchUser(userId: String) -> GTUser? {
        let request: NSFetchRequest<GTUser> = GTUser.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId)
        request.fetchLimit = 1
        
        do {
            let users = try context.fetch(request)
            return users.first
        } catch {
            print("Fetch user error: \(error)")
            return nil
        }
    }
    
    func fetchOrCreateUser(userId: String, nickname: String, profileImageUrl: String?, isCurrentUser: Bool) -> GTUser {
        if let existingUser = fetchUser(userId: userId) {
            return existingUser
        }
        return createUser(userId: userId, nickname: nickname, profileImageUrl: profileImageUrl, isCurrentUser: isCurrentUser)
    }
}

// MARK: - Chat Room Management
extension CoreDataManager {
    func createChatRoom(roomId: String) -> GTChatRoom {
        let room = GTChatRoom(context: context)
        room.roomId = roomId
        room.unreadCount = 0
        
        saveContext()
        return room
    }
    
    func fetchChatRoom(roomId: String) -> GTChatRoom? {
        let request: NSFetchRequest<GTChatRoom> = GTChatRoom.fetchRequest()
        request.predicate = NSPredicate(format: "roomId == %@", roomId)
        request.fetchLimit = 1
        
        do {
            let rooms = try context.fetch(request)
            return rooms.first
        } catch {
            print("Fetch chat room error: \(error)")
            return nil
        }
    }
    
    func fetchOrCreateChatRoom(roomId: String) -> GTChatRoom {
        if let existingRoom = fetchChatRoom(roomId: roomId) {
            return existingRoom
        }
        return createChatRoom(roomId: roomId)
    }
    
    func updateChatRoom(roomId: String, lastMessage: String?, lastMessageDate: Date?, unreadCount: Int32) {
        guard let room = fetchChatRoom(roomId: roomId) else { return }
        
        room.lastMessage = lastMessage
        room.lastMessageDate = lastMessageDate
        room.unreadCount = unreadCount
        
        saveContext()
    }
}

// MARK: - Chat Management
extension CoreDataManager {
    func createChat(chatId: String, content: String, roomId: String, senderId: String, createdAt: Date = Date()) -> GTChat {
        let chat = GTChat(context: context)
        chat.chatId = chatId
        chat.content = content
        chat.roomId = roomId
        chat.createdAt = createdAt
        chat.updatedAt = createdAt
        chat.sendStatus = 1 // 전송 완료
        chat.isRead = false
        
        // 날짜 섹션 설정
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        chat.dateSection = formatter.string(from: createdAt)
        
        // 시간 표시 설정
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        chat.timeDisplay = timeFormatter.string(from: createdAt)
        
        // 관계 설정
        chat.room = fetchOrCreateChatRoom(roomId: roomId)
        chat.sender = fetchUser(userId: senderId)
        
        saveContext()
        return chat
    }
    
    func createLocalChat(content: String, fileURLs: [URL]?, roomId: String, userId: String) -> GTChat {
        let chat = GTChat(context: context)
        chat.chatId = UUID().uuidString
        chat.content = content
        chat.roomId = roomId
        chat.createdAt = Date()
        chat.updatedAt = Date()
        chat.sendStatus = 0 // 전송 대기
        chat.isRead = true
        
        // 날짜 섹션 설정
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        chat.dateSection = formatter.string(from: Date())
        
        // 시간 표시 설정
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        chat.timeDisplay = timeFormatter.string(from: Date())
        
        // 관계 설정
        chat.room = fetchOrCreateChatRoom(roomId: roomId)
        chat.sender = fetchUser(userId: userId)
        
        // 파일 첨부 처리
        if let fileURLs = fileURLs {
            for fileURL in fileURLs {
                let chatFile = createChatFile(fileURL: fileURL, chat: chat)
                chat.addToFiles(chatFile)
            }
        }
        
        saveContext()
        return chat
    }
    
    func fetchChats(for roomId: String, limit: Int = 50) -> [GTChat] {
        let request: NSFetchRequest<GTChat> = GTChat.fetchRequest()
        request.predicate = NSPredicate(format: "roomId == %@", roomId)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        request.fetchLimit = limit
        
        do {
            let chats = try context.fetch(request)
            return chats
        } catch {
            print("Fetch chats error: \(error)")
            return []
        }
    }
    
    func updateChatSendStatus(chatId: String, status: Int16) {
        let request: NSFetchRequest<GTChat> = GTChat.fetchRequest()
        request.predicate = NSPredicate(format: "chatId == %@", chatId)
        request.fetchLimit = 1
        
        do {
            let chats = try context.fetch(request)
            if let chat = chats.first {
                chat.sendStatus = status
                saveContext()
            }
        } catch {
            print("Update chat send status error: \(error)")
        }
    }
    
    func fetchPendingChats() -> [GTChat] {
        let request: NSFetchRequest<GTChat> = GTChat.fetchRequest()
        request.predicate = NSPredicate(format: "sendStatus == 0") // 전송 대기
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        do {
            let chats = try context.fetch(request)
            return chats
        } catch {
            print("Fetch pending chats error: \(error)")
            return []
        }
    }
    
    func createChatFromServer(
        chatId: String,
        content: String,
        roomId: String,
        userId: String,
        timestamp: Date,
        files: [String]? = nil
    ) -> GTChat {
        // 중복 체크
        let existingChat = fetchChat(by: chatId)
        if let existing = existingChat {
            return existing
        }
        
        let chat = GTChat(context: context)
        chat.chatId = chatId
        chat.content = content
        chat.roomId = roomId
        chat.createdAt = timestamp
        chat.updatedAt = timestamp // 필수 필드 설정
        chat.sendStatus = 1 // 서버에서 받은 데이터이므로 전송 완료
        chat.isRead = false // 필수 필드 설정
        
        // 날짜 섹션 설정
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        chat.dateSection = formatter.string(from: timestamp)
        
        // 시간 표시 설정
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        chat.timeDisplay = timeFormatter.string(from: timestamp)
        
        // 채팅방 연결
        chat.room = fetchOrCreateChatRoom(roomId: roomId)
        
        // 사용자 연결
        chat.sender = fetchOrCreateUser(userId: userId, nickname: "사용자 \(userId)", profileImageUrl: nil, isCurrentUser: false)
        
        // 파일 정보가 있다면 처리
        if let fileList = files, !fileList.isEmpty {
            for filePath in fileList {
                let chatFile = GTChatFile(context: context)
                chatFile.fileId = UUID().uuidString
                chatFile.serverPath = filePath
                chatFile.fileName = (filePath as NSString).lastPathComponent
                chatFile.uploadStatus = 1 // 서버에서 받은 파일이므로 업로드 완료
                chatFile.createdAt = timestamp
                chatFile.chat = chat
                
                // 파일 확장자로 타입 설정
                let fileExtension = ((filePath as NSString).pathExtension).lowercased()
                chatFile.fileType = fileExtension
                chatFile.mimeType = getMimeType(for: fileExtension)
            }
        }
        
        saveContext()
        return chat
    }
    
    func fetchChat(by chatId: String) -> GTChat? {
        let request: NSFetchRequest<GTChat> = GTChat.fetchRequest()
        request.predicate = NSPredicate(format: "chatId == %@", chatId)
        request.fetchLimit = 1
        
        do {
            let chats = try context.fetch(request)
            return chats.first
        } catch {
            print("Fetch chat by ID error: \(error)")
            return nil
        }
    }
}

// MARK: - File Management
extension CoreDataManager {
    func createChatFile(fileURL: URL, chat: GTChat) -> GTChatFile {
        let chatFile = GTChatFile(context: context)
        chatFile.fileId = UUID().uuidString
        chatFile.fileName = fileURL.lastPathComponent
        chatFile.localPath = fileURL.path
        chatFile.createdAt = Date()
        chatFile.uploadStatus = 0 // 업로드 대기
        chatFile.uploadProgress = 0.0
        
        // 파일 정보 설정
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            chatFile.fileSize = fileAttributes[.size] as? Int64 ?? 0
        } catch {
            print("File attributes error: \(error)")
        }
        
        // MIME 타입 설정
        let fileExtension = fileURL.pathExtension.lowercased()
        chatFile.fileType = fileExtension
        chatFile.mimeType = getMimeType(for: fileExtension)
        
        // 썸네일 생성 (이미지/비디오인 경우)
        if isMediaFile(fileExtension) {
            generateThumbnail(for: chatFile, sourceURL: fileURL)
        }
        
        chatFile.chat = chat
        
        saveContext()
        return chatFile
    }
    
    //TODO: 함수 활용하기
    func updateFileUploadProgress(fileId: String, progress: Float) {
        let request: NSFetchRequest<GTChatFile> = GTChatFile.fetchRequest()
        request.predicate = NSPredicate(format: "fileId == %@", fileId)
        request.fetchLimit = 1
        
        do {
            let files = try context.fetch(request)
            if let file = files.first {
                file.uploadProgress = progress
                if progress >= 1.0 {
                    file.uploadStatus = 1 // 업로드 완료
                }
                saveContext()
            }
        } catch {
            print("Update file upload progress error: \(error)")
        }
    }
    
    func updateFileServerPath(fileId: String, serverPath: String) {
        let request: NSFetchRequest<GTChatFile> = GTChatFile.fetchRequest()
        request.predicate = NSPredicate(format: "fileId == %@", fileId)
        request.fetchLimit = 1
        
        do {
            let files = try context.fetch(request)
            if let file = files.first {
                file.serverPath = serverPath
                file.uploadStatus = 1 // 업로드 완료
                saveContext()
            }
        } catch {
            print("Update file server path error: \(error)")
        }
    }
    
    func fetchPendingFiles() -> [GTChatFile] {
        let request: NSFetchRequest<GTChatFile> = GTChatFile.fetchRequest()
        request.predicate = NSPredicate(format: "uploadStatus == 0") // 업로드 대기
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        do {
            let files = try context.fetch(request)
            return files
        } catch {
            print("Fetch pending files error: \(error)")
            return []
        }
    }
}

// MARK: - Thumbnail Generation
extension CoreDataManager {
    private func generateThumbnail(for chatFile: GTChatFile, sourceURL: URL) {
        guard let fileExtension = chatFile.fileType else { return }
        
        DispatchQueue.global(qos: .background).async {
            var thumbnailImage: UIImage?
            
            if self.isImageFile(fileExtension) {
                thumbnailImage = self.generateImageThumbnail(from: sourceURL)
            } else if self.isVideoFile(fileExtension) {
                thumbnailImage = self.generateVideoThumbnail(from: sourceURL)
            }
            
            if let thumbnail = thumbnailImage {
                let thumbnailPath = self.saveThumbnail(thumbnail, for: chatFile.fileId ?? "")
                
                DispatchQueue.main.async {
                    chatFile.thumbnailPath = thumbnailPath
                    self.saveContext()
                }
            }
        }
    }
    
    private func generateImageThumbnail(from url: URL) -> UIImage? {
        guard let image = UIImage(contentsOfFile: url.path) else { return nil }
        
        let thumbnailSize = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: thumbnailSize)
        
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: thumbnailSize))
        }
    }
    
    private func generateVideoThumbnail(from url: URL) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTime.zero, actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            
            let thumbnailSize = CGSize(width: 200, height: 200)
            let renderer = UIGraphicsImageRenderer(size: thumbnailSize)
            
            return renderer.image { _ in
                thumbnail.draw(in: CGRect(origin: .zero, size: thumbnailSize))
            }
        } catch {
            print("Video thumbnail generation error: \(error)")
            return nil
        }
    }
    
    private func saveThumbnail(_ image: UIImage, for fileId: String) -> String {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let thumbnailsPath = documentsPath.appendingPathComponent("thumbnails")
        
        // 썸네일 디렉터리 생성
        try? FileManager.default.createDirectory(at: thumbnailsPath, withIntermediateDirectories: true)
        
        let thumbnailPath = thumbnailsPath.appendingPathComponent("\(fileId)_thumbnail.jpg")
        
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: thumbnailPath)
        }
        
        return thumbnailPath.path
    }
}

// MARK: - Cache Management
extension CoreDataManager {
    func cleanupOldFiles(olderThan days: Int = 30) {
        let calendar = Calendar.current
        let cutoffDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        backgroundContext.perform {
            let request: NSFetchRequest<GTChatFile> = GTChatFile.fetchRequest()
            request.predicate = NSPredicate(format: "createdAt < %@", cutoffDate as NSDate)
            
            do {
                let oldFiles = try self.backgroundContext.fetch(request)
                
                for file in oldFiles {
                    // 로컬 파일 삭제
                    if let localPath = file.localPath {
                        try? FileManager.default.removeItem(atPath: localPath)
                    }
                    
                    // 썸네일 파일 삭제
                    if let thumbnailPath = file.thumbnailPath {
                        try? FileManager.default.removeItem(atPath: thumbnailPath)
                    }
                    
                    // CoreData에서 삭제
                    self.backgroundContext.delete(file)
                }
                
                self.saveBackgroundContext(self.backgroundContext)
                print("Cleaned up \(oldFiles.count) old files")
                
            } catch {
                print("Cache cleanup error: \(error)")
            }
        }
    }
    
    func getCacheSize() -> Int64 {
        let request: NSFetchRequest<GTChatFile> = GTChatFile.fetchRequest()
        
        do {
            let files = try context.fetch(request)
            return files.reduce(0) { $0 + $1.fileSize }
        } catch {
            print("Get cache size error: \(error)")
            return 0
        }
    }
}

// MARK: - Utility Functions
extension CoreDataManager {
    private func getMimeType(for fileExtension: String) -> String {
        switch fileExtension.lowercased() {
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "gif":
            return "image/gif"
        case "mp4":
            return "video/mp4"
        case "mov":
            return "video/quicktime"
        case "pdf":
            return "application/pdf"
        case "doc", "docx":
            return "application/msword"
        case "txt":
            return "text/plain"
        default:
            return "application/octet-stream"
        }
    }
    
    private func isMediaFile(_ fileExtension: String) -> Bool {
        return isImageFile(fileExtension) || isVideoFile(fileExtension)
    }
    
    private func isImageFile(_ fileExtension: String) -> Bool {
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "tiff"]
        return imageExtensions.contains(fileExtension.lowercased())
    }
    
    private func isVideoFile(_ fileExtension: String) -> Bool {
        let videoExtensions = ["mp4", "mov", "avi", "mkv", "wmv"]
        return videoExtensions.contains(fileExtension.lowercased())
    }
}
