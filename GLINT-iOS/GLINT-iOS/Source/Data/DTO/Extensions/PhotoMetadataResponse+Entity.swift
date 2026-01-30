//
//  PhotoMetadataResponse+Entity.swift
//  GLINT-iOS
//
//  Created by 박신영 on 7/3/25.
//

import Foundation

extension PhotoMetadataResponse {
    func toEntity() -> PhotoMetadataEntity {
        return .init(
            camera: self.camera,
            lensInfo: self.lensInfo,
            focalLength: self.focalLength,
            aperture: self.aperture,
            iso: self.iso,
            shutterSpeed: self.shutterSpeed,
            pixelWidth: self.pixelWidth,
            pixelHeight: self.pixelHeight,
            fileSize: self.fileSize,
            format: self.format,
            dateTimeOriginal: self.dateTimeOriginal,
            latitude: self.latitude,
            longitude: self.longitude,
            photoMetadataString: FilterValueFormatter.photoMetaDataFormat(
                lensInfo: self.lensInfo,
                focalLength: self.focalLength,
                aperture: self.aperture,
                iso: self.iso),
            megapixelInfoString: MegapixelCalculator.calculateMPString(
                width: self.pixelWidth,
                height: self.pixelHeight,
                fileSize: self.fileSize
            )
        )
    }
}
