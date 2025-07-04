//
//  PhotoMetadataEntity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/3/25.
//

import Foundation

struct PhotoMetadataEntity: RequestData {
    let camera: String?
    let lensInfo: String?
    let focalLength: Float?
    let aperture: Float?
    let iso: Int?
    let shutterSpeed: String?
    let pixelWidth: Int?
    let pixelHeight: Int?
    let fileSize: Int?
    let format: String?
    let dateTimeOriginal: String?
    let latitude: Float?
    let longitude: Float?
    let photoMetadataString: String?
    let megapixelInfoString: String?

    enum CodingKeys: String, CodingKey {
        case camera
        case lensInfo = "lens_info"
        case focalLength = "focal_length"
        case aperture, iso
        case shutterSpeed = "shutter_speed"
        case pixelWidth = "pixel_width"
        case pixelHeight = "pixel_height"
        case fileSize = "file_size"
        case format
        case dateTimeOriginal = "date_time_original"
        case latitude, longitude
    }
    
    func getKoreanAddress() async -> String {
        return await KoreanAddressHelper.getKoreanAddress(
            latitude: latitude ?? 0,
            longitude: longitude ?? 0
        )
    }
}
