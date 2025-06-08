//
//  EmailValidationEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/29/25.
//

import Foundation

enum EmailValidationEntity {
    struct Request: Codable {
        let email: String
    }
}
