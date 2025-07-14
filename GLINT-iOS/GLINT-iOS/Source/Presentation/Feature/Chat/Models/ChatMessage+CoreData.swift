//
//  ChatMessage+CoreData.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/10/25.
//

import Foundation
import CoreData

// MARK: - CoreData Mapping
extension ChatMessage {
    /// CoreData GTChat 엔티티에서 ChatMessage로 변환
    init(from gtChat: GTChat, currentUserId: String) {
        self.id = gtChat.chatId ?? UUID().uuidString
        self.content = gtChat.content ?? ""
        self.senderId = gtChat.sender?.userId ?? ""
        self.senderName = gtChat.sender?.nickname ?? "Unknown"
        self.timestamp = gtChat.createdAt ?? Date()
        self.isFromMe = gtChat.sender?.userId == currentUserId
    }
    
    /// GTChat 배열을 ChatMessage 배열로 변환
    static func from(_ gtChats: [GTChat], currentUserId: String) -> [ChatMessage] {
        return gtChats.map { ChatMessage(from: $0, currentUserId: currentUserId) }
    }
}

// MARK: - File Support Extensions
extension ChatMessage {
    /// 첨부된 파일들을 가져오기
    var attachedFiles: [ChatFile] {
        // 실제 구현에서는 GTChat의 files 관계에서 가져옴
        return []
    }
    
    /// 메시지에 파일이 첨부되어 있는지 확인
    var hasAttachedFiles: Bool {
        return !attachedFiles.isEmpty
    }
}

// MARK: - Chat File Model
struct ChatFile: Identifiable, Hashable {
    let id: String
    let fileName: String
    let fileType: String
    let fileSize: Int64
    let thumbnailPath: String?
    let localPath: String?
    let serverPath: String?
    let uploadProgress: Float
    let uploadStatus: FileUploadStatus
    
    init(from gtChatFile: GTChatFile) {
        self.id = gtChatFile.fileId ?? UUID().uuidString
        self.fileName = gtChatFile.fileName ?? "Unknown"
        self.fileType = gtChatFile.fileType ?? ""
        self.fileSize = gtChatFile.fileSize
        self.thumbnailPath = gtChatFile.thumbnailPath
        self.localPath = gtChatFile.localPath
        self.serverPath = gtChatFile.serverPath
        self.uploadProgress = gtChatFile.uploadProgress
        self.uploadStatus = FileUploadStatus(rawValue: Int(gtChatFile.uploadStatus)) ?? .pending
    }
}

enum FileUploadStatus: Int, CaseIterable {
    case pending = 0
    case uploading = 1
    case completed = 2
    case failed = 3
    
    var description: String {
        switch self {
        case .pending: return "대기 중"
        case .uploading: return "업로드 중"
        case .completed: return "완료"
        case .failed: return "실패"
        }
    }
} 
