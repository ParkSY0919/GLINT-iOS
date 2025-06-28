//
//  ProfileEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/2/25.
//

import Foundation

struct ProfileEntity: ResponseData {
    let userID, nick, name, introduction: String?
    let description: String?
    var profileImageURL: String?
    let hashTags: [String]? 
}
