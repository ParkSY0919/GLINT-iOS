//
//  CheckEmailValidation.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/13/25.
//

import Foundation

// MARK: - Request
extension RequestDTO {
    struct CheckEmailValidation: Encodable {
        let email: String
    }
}
