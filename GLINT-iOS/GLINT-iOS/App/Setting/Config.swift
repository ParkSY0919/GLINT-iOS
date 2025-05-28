//
//  Config.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/10/25.
//

//TODO: 해야할 일
/// 1. 인터셉터 O
/// 1-1. Keychain Manager O
/// 1-2. LoginManager O
/// 2. 라우터
/// 3. 옵저버블 매크로 적용
/// 4. 뉴크

import Foundation
 
enum Config {
    enum Keys {
        static let baseURL = "BASE_URL"
        static let sesacKey = "SESAC_KEY"
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist cannot found !!!")
        }
        return dict
    }()
}


extension Config {
    
    static let baseURL: String = {
        guard let key = Config.infoDictionary[Keys.baseURL] as? String else {
            fatalError("BASE_URL is not set in plist for this configuration")
        }
        return key
    }()
    
    static let sesacKey: String = {
        guard let key = Config.infoDictionary[Keys.sesacKey] as? String else {
            fatalError("SESAC_KEY is not set in plist for this configuration")
        }
        return key
    }()
    
}


