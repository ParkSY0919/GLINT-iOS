//
//  TodayAuthor.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/24/25.
//

import Foundation

// MARK: - TodayAuthor
extension ResponseDTO {
    struct TodayAuthor: Decodable {
        let author: Author
        let filters: [Filter]
        
        func toEntity() -> ResponseEntity.TodayAuthor {
            return ResponseEntity.TodayAuthor(
                author: author.toEntity(),
                filters: filters.map { $0.toEntity() }
            )
        }
    }
}

extension ResponseDTO.TodayAuthor {
    
}

// MARK: - Author
struct Author: Codable {
    let userID, nick, name, introduction: String
    let description: String?
    let profileImage: String?
    let hashTags: [String]

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick, name, introduction, description, profileImage, hashTags
    }
    
    func toEntity() -> AuthorEntity {
        return AuthorEntity(
            userID: self.userID,
            nick: self.nick,
            name: self.name,
            introduction: self.introduction,
            description: self.description,
            profileImage: self.profileImage?.imageURL ?? "",
            hashTags: self.hashTags
        )
    }
}

// MARK: - Filter
struct Filter: Codable {
    let filterID, title, description: String
    let category: String?
    let files: [String]
    let creator: Author
    let isLiked: Bool
    let likeCount, buyerCount: Int
    let createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case filterID = "filter_id"
        case category, title, description, files, creator
        case isLiked = "is_liked"
        case likeCount = "like_count"
        case buyerCount = "buyer_count"
        case createdAt, updatedAt
    }
    
    func toEntity() -> FilterEntity {
        var newFiles = [""]
        func toImageString() {
            for index in 0..<files.count {
                newFiles.append(files[index].imageURL)
            }
        }
        
        toImageString()
        let original = self.files.first
        let filtered = self.files.last
        
        return FilterEntity(
            id: self.filterID,
            category: self.category ?? "으음",
            title: self.title,
            description: self.description,
            original: original?.imageURL,
            filtered: filtered?.imageURL,
            creator: self.creator.toEntity(),
            isLiked: self.isLiked,
            likeCount: self.likeCount,
            buyerCount: self.buyerCount,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}
