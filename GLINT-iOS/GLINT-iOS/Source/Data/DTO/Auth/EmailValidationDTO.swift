//
//  EmailValidationDTO.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/13/25.
//

import Foundation

enum EmailValidationDTO {
    struct Request: RequestData {
        let email: String
    }
    
    struct Response: ResponseData {
        let email: String
    }
}

extension EmailValidationEntity.Request {
    func toDTO() -> EmailValidationDTO.Request {
        .init(email: self.email)
    }
}
