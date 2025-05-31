//
//  String+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/30/25.
//

import Foundation

extension String {
    var imageURL: String {
        return Config.baseURL + "v1" + self
    }
}
