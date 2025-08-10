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
    init(from gtChat: GTChat, currentUserNickname: String) {
        let senderId = (gtChat.sender?.userId ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let senderName = (gtChat.sender?.nickname ?? "Unknown").trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 키체인에서 현재 사용자 닉네임 가져오기 (1순위)
        let keychain = KeychainManager.shared
        let myNickFromKeychain = (keychain.getNickname() ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 파라미터로 받은 닉네임 (2순위, 폴백용)
        let paramNickname = currentUserNickname.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 실제 비교에 사용할 현재 사용자 닉네임 결정
        let actualMyNickname = !myNickFromKeychain.isEmpty ? myNickFromKeychain : paramNickname
        
        self.id = gtChat.chatId ?? UUID().uuidString
        self.content = gtChat.content ?? ""
        self.senderId = senderId
        self.senderName = senderName
        self.timestamp = gtChat.createdAt ?? Date()
        self.isFromMe = actualMyNickname == actualMyNickname
        
        // 상세 디버깅 로그
        print("💬 ChatMessage 생성:")
        print("   - 메시지 ID: \(self.id)")
        print("   - 발신자 ID: '\(senderId)'")
        print("   - 발신자 닉네임: '\(senderName)'")
        print("   - 키체인 닉네임: '\(myNickFromKeychain)'")
        print("   - 파라미터 닉네임: '\(paramNickname)'")
        print("   - 실제 사용 닉네임: '\(actualMyNickname)'")
        print("   - 닉네임 비교: '\(senderName)' == '\(actualMyNickname)' → \(senderName == actualMyNickname)")
        print("   - isFromMe: \(self.isFromMe)")
        print("   - 메시지 내용: \(self.content)")
        print("   - GTChat sender.isCurrentUser: \(gtChat.sender?.isCurrentUser ?? false)")
        print("   ---")
        
        // 이미지 URL들 추출
        if let files = gtChat.files as? Set<GTChatFile> {
            self.images = files.compactMap { file in
                // 이미지 파일만 필터링 (확장자 또는 MIME 타입으로 구분)
                if let serverPath = file.serverPath,
                   let fileName = file.fileName,
                   (fileName.lowercased().hasSuffix(".jpg") || 
                    fileName.lowercased().hasSuffix(".jpeg") || 
                    fileName.lowercased().hasSuffix(".png") || 
                    fileName.lowercased().hasSuffix(".gif")) {
                    return serverPath
                }
                return nil
            }.sorted() // 정렬하여 일관된 순서 보장
        } else {
            self.images = []
        }
    }
    
    /// GTChat 배열을 ChatMessage 배열로 변환
    static func from(_ gtChats: [GTChat], currentUserNickname: String) -> [ChatMessage] {
        return gtChats.map { ChatMessage(from: $0, currentUserNickname: currentUserNickname) }
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
