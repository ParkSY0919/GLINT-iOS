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
    // MARK: - Author
    struct Author: Decodable {
        let userID, nick, name, introduction: String
        let description: String?
        let profileImage: String
        let hashTags: [String]

        enum CodingKeys: String, CodingKey {
            case userID = "user_id"
            case nick, name, introduction, description, profileImage, hashTags
        }
        
        func toEntity() -> ResponseEntity.TodayAuthor.AuthorEntity {
            return ResponseEntity.TodayAuthor.AuthorEntity(
                userID: self.userID,
                nick: self.nick,
                name: self.name,
                introduction: self.introduction,
                description: self.description,
                profileImage: self.profileImage.imageURL,
                hashTags: self.hashTags
            )
        }
    }
    
    // MARK: - Filter
    struct Filter: Decodable {
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
        
        func toEntity() -> ResponseEntity.TodayAuthor.FilterEntity {
            var newFiles = [""]
            func toImageString() {
                for index in 0..<files.count {
                    newFiles.append(files[index].imageURL)
                }
            }
            
            toImageString()
            
            return ResponseEntity.TodayAuthor.FilterEntity(
                filterID: self.filterID,
                category: self.category ?? "으음",
                title: self.title,
                description: self.description,
                files: newFiles,
                creator: self.creator.toEntity(),
                isLiked: self.isLiked,
                likeCount: self.likeCount,
                buyerCount: self.buyerCount,
                createdAt: self.createdAt,
                updatedAt: self.updatedAt
            )
        }
    }
}

