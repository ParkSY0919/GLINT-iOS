//
//  PhotoMetadataModel.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/2/25.
//

import Foundation

struct PhotoMetadataModel: Codable {
    let camera: String
    let metaData: [String]
    let latitude: Double
    let longitude: Double
    
    func getKoreanAddress() async -> String {
        return await KoreanAddressHelper.getKoreanAddress(
            latitude: latitude,
            longitude: longitude
        )
    }   
}
