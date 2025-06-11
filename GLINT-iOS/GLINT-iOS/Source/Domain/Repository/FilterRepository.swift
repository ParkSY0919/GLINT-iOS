//
//  FilterRepository.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/10/25.
//

import Foundation

struct FilterRepository {
    var filterFiles: (_ files: [Data]) async throws -> FilesEntity.Response
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
    struct Request: Codable {
        let files: [Data]
        
        enum CodingKeys: String, CodingKey {
            case files
        }
        
        init(files: [Data]) {
            self.files = files
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            // Data를 base64 문자열로 인코딩
            let base64Files = files.map { $0.base64EncodedString() }
            try container.encode(base64Files, forKey: .files)
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let base64Files = try container.decode([String].self, forKey: .files)
            self.files = base64Files.compactMap { Data(base64Encoded: $0) }
        }
    }
    
    struct Response: Codable {
        let files: [String]
    }
}
