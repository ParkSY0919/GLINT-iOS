//
//  CheckEmailValidationEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/29/25.
//

import Foundation

struct CheckEmailValidationRequestEntity: Codable {
    let email: String
    
    func toRequest() -> CheckEmailValidationRequest {
        return .init(email: self.email)
    }
}
