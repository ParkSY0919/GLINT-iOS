//
//  PhotoMetadata.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/23/25.
//

import Foundation
//TODO: 이거 PhotoMetadataEntity로 분리
struct PhotoMetadata: ResponseData {
    let camera: String
    let lensInfo: String
    let focalLength: Int
    let aperture: Double
    let iso: Int
    let shutterSpeed: String
    let pixelWidth: Int
    let pixelHeight: Int
    let fileSize: Int
    let format: String
    let dateTimeOriginal: String
    let latitude: Double
    let longitude: Double
    var photoMetadataString: String? {
        return FilterValueFormatter.photoMetaDataFormat(
            lensInfo: self.lensInfo,
            focalLength: Double(self.focalLength),
            aperture: self.aperture,
            iso: self.iso)
    }
    var megapixelInfoString: String? {
        return MegapixelCalculator.calculateMPString(
            width: self.pixelWidth,
            height: self.pixelHeight,
            fileSize: self.fileSize
        )
    }

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
            latitude: latitude,
            longitude: longitude
        )
    }
}
