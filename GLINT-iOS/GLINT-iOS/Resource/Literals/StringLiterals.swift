//
//  StringLiterals.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/10/25.
//

import Foundation

enum StringLiterals {}

extension StringLiterals {
    
    static let categories: [FilterCategory] = [
        FilterCategory(icon: ImageLiterals.Main.food, name: "푸드"),
        FilterCategory(icon: ImageLiterals.Main.person, name: "인물"),
        FilterCategory(icon: ImageLiterals.Main.landscape, name: "풍경"),
        FilterCategory(icon: ImageLiterals.Main.nightscape, name: "야경"),
        FilterCategory(icon: ImageLiterals.Main.star, name: "별")
    ]
    
}
