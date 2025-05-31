//
//  CheckEmailValidation.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/29/25.
//

import Foundation

extension RequestEntity {
    struct CheckEmailValidation: Codable {
        let email: String
        
        func toRequest() -> RequestDTO.CheckEmailValidation {
            return .init(email: self.email)
        }
    }
}
