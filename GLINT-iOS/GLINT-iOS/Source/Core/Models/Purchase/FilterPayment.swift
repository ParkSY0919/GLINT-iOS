//
//  FilterPayment.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/24/25.
//

import Foundation

struct FilterPayment: ResponseData {
    let id, category, title, description: String
    let files: [String]
    let price: Int
    let creator: CreatorPayment
    let filterValues: [String: Double]?
    let createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, category, title, description, files, price, creator
        case filterValues = "filter_values"
        case createdAt, updatedAt
    }
}
