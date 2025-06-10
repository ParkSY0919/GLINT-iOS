//
//  FilterRepository.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/10/25.
//

import Foundation

struct FilterRepository {
    var filterFiles: (_ files: [String]) async throws -> FilesEntity.Response
}

enum FilesDTO {
//    struct Re: Codable {
//        let files: [String]
//    }
    
    struct Response: Codable {
        let files: [String]
    }
}

enum FilesEntity {
    struct Response: Codable {
        let files: [String]
    }
}
