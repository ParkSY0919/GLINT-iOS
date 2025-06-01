//
//  Encodable+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/30/25.
//

import Foundation

extension Encodable {
    func toDictionary() -> [String: Any]? {
        do {
            let data = try JSONEncoder().encode(self)
            let jsonData = try JSONSerialization.jsonObject(with: data)
            return jsonData as? [String: Any]
        } catch {
            print("Error encoding to dictionary: \(error)")
            return nil
        }
    }
}
