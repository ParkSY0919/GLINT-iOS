//
//  RequestType.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/15/25.
//

import Foundation

enum RequestType {
    case queryEncodable(Encodable?) // Encodable 객체를 쿼리로
    case bodyEncodable(Encodable?)  // Encodable 객체를 바디로
    case none                       // 파라미터 없음
}
