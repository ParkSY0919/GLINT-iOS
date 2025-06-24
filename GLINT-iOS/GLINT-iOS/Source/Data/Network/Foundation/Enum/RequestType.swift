//
//  RequestType.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/15/25.
//

import Foundation

enum RequestType {
    //query는 base path 끝 ? 이후 들어가는 것들 연결
    case queryEncodable(Encodable?)      // Encodable 객체를 쿼리로
    case bodyEncodable(Encodable?)       // Encodable 객체를 바디로
    case multipartData(MultipartConfig)  // MultipartConfig
    case none                            // 파라미터 없음
}

struct MultipartConfig {
    let files: [Data]
    let fieldName: String = "files"
    let fileExtension: String = "jpg"
    let mimeType: String = "image/jpeg"
    
    init(files: [Data]) {
        self.files = files
    }
}
