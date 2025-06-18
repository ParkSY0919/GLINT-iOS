//
//  Validator.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/18/25.
//

import Foundation

enum Validator {
    static func isValidEmailFormat(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    static func validatePasswordFormat(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
}

enum ValidationError: Error, LocalizedError {
    case invalidEmailFormat
    // ... 다른 유효성 에러들

    var errorDescription: String? {
        switch self {
        case .invalidEmailFormat:
            return "올바른 이메일 형식이 아닙니다."
        }
    }
}
