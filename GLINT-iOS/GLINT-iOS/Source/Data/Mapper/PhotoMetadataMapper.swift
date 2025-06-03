//
//  PhotoMetadataMapper.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/2/25.
//

import Foundation

struct PhotoMetadataMapper {
    static func map(from response: PhotoMetadataResponse) -> PhotoMetadataModel {
        return .init(
            camera: response.camera,
            photoMetadataString: FilterValueFormatter.photoMetaDataFormat(
                lensInfo: response.lensInfo,
                focalLength: response.focalLength,
                aperture: response.aperture,
                iso: response.iso),
            megapixelInfo: MegapixelCalculator.calculateMPString(
                width: response.pixelWidth,
                height: response.pixelHeight,
                fileSize: response.fileSize),
            latitude: response.latitude ?? 0.0,
            longitude: response.longitude ?? 0.0
        )
    }
}
