//
//  PhotoMetadataResponse.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/2/25.
//

import Foundation

// MARK: - PhotoMetadataResponse
struct PhotoMetadataResponse: Codable {
    let camera, lensInfo: String
    let iso: Int
    let focalLength, aperture: Double
    let shutterSpeed: String
    let pixelWidth, pixelHeight, fileSize: Int
    let format: String
    let dateTimeOriginal: String
    let latitude, longitude: Double?
    
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
}
