//
//  Validator+Auth.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/21/25.
//

import Foundation
//TODO: Validator+Auth로 네이밍이 돼있지만 국한되지 말고, 더 넓은 범위의 의미있는 네이밍을 하는게 좋을 것 같다.
extension Validator {
    static func validateEmail(_ email: String) throws {
        guard isValidEmailFormat(email) else {
            throw AuthError.invalidEmailFormat
        }
    }
    
    static func validatePassword(_ password: String) throws {
        guard isValidPasswordFormat(password) else {
            throw AuthError.invalidPasswordFormat
        }
    }
}
