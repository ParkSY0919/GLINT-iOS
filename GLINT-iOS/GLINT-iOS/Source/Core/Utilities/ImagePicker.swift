//
//  ImagePicker.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/3/25.
//

import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    let onImageSelected: (UIImage, PhotoMetadataEntity?) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        configuration.preferredAssetRepresentationMode = .current // 원본 이미지 우선
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            guard let result = results.first else { return }
            
            Task {
                await processSelectedImage(result)
            }
        }
        
        
        @MainActor  //image 추출
        private func processSelectedImage(_ result: PHPickerResult) async {
            do {
                // 1. 이미지 로드
                let image = try await loadImage(from: result)
                
                // 2. 메타데이터 추출
                let metadata = await extractMetadata(from: result)
                
                // 3. 결과 전달
                parent.onImageSelected(image, metadata)
                
            } catch {
                print("이미지 처리 중 오류 발생: \(error)")
                let image = UIImage(systemName: "x.mark") ?? UIImage()
                parent.onImageSelected(image, nil)
            }
        }
        
        // MARK: - 이미지 로드
        private func loadImage(from result: PHPickerResult) async throws -> UIImage {
            return try await withCheckedThrowingContinuation { continuation in
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let image = image as? UIImage {
                            continuation.resume(returning: image)
                        } else {
                            continuation.resume(throwing: ImagePickerError.imageLoadFailed)
                        }
                    }
                } else {
                    continuation.resume(throwing: ImagePickerError.imageNotSupported)
                }
            }
        }
        
        // MARK: - 메타데이터 추출
        private func extractMetadata(from result: PHPickerResult) async -> PhotoMetadataEntity? {
            // PHAsset
            if let assetIdentifier = result.assetIdentifier {
                if let metadata = await extractFromPHAsset(identifier: assetIdentifier) {
                    return metadata
                }
            }
            
            // 파일 다이렉트
            return await extractFromFile(result: result)
        }
        
        // MARK: - PHAsset을 통한 메타데이터 추출
        private func extractFromPHAsset(identifier: String) async -> PhotoMetadataEntity? {
            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
            guard let asset = fetchResult.firstObject else {
                return nil
            }
            
            return await withCheckedContinuation { continuation in
                let options = PHImageRequestOptions()
                options.isSynchronous = false
                options.deliveryMode = .highQualityFormat
                options.isNetworkAccessAllowed = true
                
                PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
                    guard let imageData = data else {
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    let metadata = self.extractEXIFData(from: imageData, asset: asset)
                    continuation.resume(returning: metadata)
                }
            }
        }
        
        // MARK: - 파일에서 직접 메타데이터 추출
        private func extractFromFile(result: PHPickerResult) async -> PhotoMetadataEntity? {
            return await withCheckedContinuation { continuation in
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
                    guard let url = url, error == nil else {
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    guard let imageData = try? Data(contentsOf: url) else {
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    let metadata = self.extractEXIFData(from: imageData, asset: nil)
                    continuation.resume(returning: metadata)
                }
            }
        }
        
        // MARK: - EXIF 데이터 추출 및 변환 (동기 함수 - 변경 없음)
        private func extractEXIFData(from imageData: Data, asset: PHAsset?) -> PhotoMetadataEntity? {
            guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil),
                  let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
                return nil
            }
            
            // 각 딕셔너리 추출
            let exifData = properties[kCGImagePropertyExifDictionary as String] as? [String: Any] ?? [:]
            let tiffData = properties[kCGImagePropertyTIFFDictionary as String] as? [String: Any] ?? [:]
            let gpsData = properties[kCGImagePropertyGPSDictionary as String] as? [String: Any] ?? [:]
            
            // 기존 추출
            let phoneInfo = extractPhoneInfo(from: tiffData)
            let (lensType, focalLength, aperture, iso) = extractPhotoMetaData(exifData: exifData, properties: properties)
            let (latitude, longitude) = extractGPSInfo(from: gpsData, asset: asset)
            
            // 추가 추출
            let shutterSpeed = extractShutterSpeed(from: exifData)
            let fileSize = imageData.count
            let format = extractFileFormat(from: properties)
            let dateTime = extractDateTime(from: exifData)
            
            // 픽셀 크기
            let pixelWidth = properties[kCGImagePropertyPixelWidth as String] as? Int ?? 0
            let pixelHeight = properties[kCGImagePropertyPixelHeight as String] as? Int ?? 0
            
            return PhotoMetadataEntity(
                camera: phoneInfo,
                lensInfo: lensType,
                focalLength: Int(focalLength),
                aperture: aperture,
                iso: iso,
                shutterSpeed: shutterSpeed,
                pixelWidth: pixelWidth,
                pixelHeight: pixelHeight,
                fileSize: fileSize,
                format: format,
                dateTimeOriginal: dateTime,
                latitude: latitude,
                longitude: longitude,
                photoMetadataString: FilterValueFormatter.photoMetaDataFormat(
                    lensInfo: lensType,
                    focalLength: Double(Int(focalLength)),
                    aperture: aperture,
                    iso: iso),
                megapixelInfoString: MegapixelCalculator.calculateMPString(
                    width: pixelWidth,
                    height: pixelHeight,
                    fileSize: fileSize
                )
            )
            
        }
        
        private func extractPhoneInfo(from tiffData: [String: Any]) -> String {
            // 카메라 제조사
            let make = tiffData[kCGImagePropertyTIFFMake as String] as? String ?? ""
            
            // 카메라 모델
            let model = tiffData[kCGImagePropertyTIFFModel as String] as? String ?? ""
            
            if make != "" && model != "" {
                return "\(make) \(model)".trimmingCharacters(in: .whitespaces)
            } else {
                return "정보 없음"
            }
        }
        
        
        // MARK: - 촬영 정보 추출
        private func extractPhotoMetaData(exifData: [String: Any], properties: [String: Any]) -> (String, Double, Double, Int) {
            // 렌즈 정보
            var lensType = "카메라 정보 없음"
            var focalLengh: Double = 0
            var aperture: Double = 0
            var iso: Int = 0
            
            if let focalLength = exifData[kCGImagePropertyExifFocalLength as String] as? Double {
                lensType = determineCameraTypeByFocalLength(focalLength)
            }
            
            // 초점거리mm, 조리개𝒇, ISO
            if let focalLengthData = exifData[kCGImagePropertyExifFocalLength as String] as? Double,
               let apertureData = exifData[kCGImagePropertyExifFNumber as String] as? Double,
               let isoData = exifData[kCGImagePropertyExifISOSpeedRatings as String] as? [Int],
               let isoValue = isoData.first {
                focalLengh = focalLengthData
                aperture = apertureData
                iso = isoValue
            }
            
            return (lensType, focalLengh, aperture, iso)
        }
        
        private func extractMegaPixels(fileSize: Int, properties: [String: Any]) -> String {
            guard let pixelWidth = properties[kCGImagePropertyPixelWidth as String] as? Int,
                  let pixelHeight = properties[kCGImagePropertyPixelHeight as String] as? Int else {
                return "정보 없음"
            }
            guard let mp = MegapixelCalculator.calculateMPString(width: pixelWidth, height: pixelHeight, fileSize: 0) else { return "정보 없음" }
            return mp
        }
        
        // MARK: - GPS 정보 추출
        private func extractGPSInfo(from gpsData: [String: Any], asset: PHAsset?) -> (Double, Double) {
            var latitude: Double = 0.0
            var longitude: Double = 0.0
            
            // EXIF GPS 데이터에서 추출
            if !gpsData.isEmpty {
                if let lat = gpsData[kCGImagePropertyGPSLatitude as String] as? Double,
                   let latRef = gpsData[kCGImagePropertyGPSLatitudeRef as String] as? String,
                   let lon = gpsData[kCGImagePropertyGPSLongitude as String] as? Double,
                   let lonRef = gpsData[kCGImagePropertyGPSLongitudeRef as String] as? String {
                    
                    latitude = latRef == "S" ? -lat : lat
                    longitude = lonRef == "W" ? -lon : lon
                }
            }
            // PHAsset의 location에서 추출
            else if let asset = asset, let location = asset.location {
                latitude = location.coordinate.latitude
                longitude = location.coordinate.longitude
            }
            
            return (latitude, longitude)
        }
        
        private func determineCameraTypeByFocalLength(_ focalLength: Double) -> String {
            // iPhone 실제 센서 초점거리 기준
            switch focalLength {
            case 0..<2.0:       // iPhone 초광각 (약 1.5mm)
                return "초광각 카메라"
            case 2.0..<5.0:     // iPhone 와이드 (약 4.2mm)
                return "와이드 카메라"
            case 5.0..<10.0:    // iPhone 망원 (약 6-9mm)
                return "망원 카메라"
            case 10.0...:       // 고배율 망원
                return "망원 카메라"
            default:
                return "와이드 카메라"
            }
        }
        
        private func extractFileFormat(from properties: [String: Any]) -> String {
            // ColorModel로 포맷 추정
            if let colorModel = properties[kCGImagePropertyColorModel as String] as? String {
                // RGB = JPEG, Gray = 흑백 등
                return colorModel == "RGB" ? "JPEG" : "Unknown"
            }
            
            // 또는 UTType으로 확인
            // 이미지 파일의 확장자나 타입으로 판단
            return "JPEG"  // 대부분의 사진은 JPEG
        }
        
        private func extractShutterSpeed(from exifData: [String: Any]) -> String {
            // 노출 시간 (초 단위)
            if let exposureTime = exifData[kCGImagePropertyExifExposureTime as String] as? Double {
                if exposureTime < 1.0 {
                    // 1초 미만일 때는 분수로 표시 (예: 1/125)
                    let denominator = Int(1.0 / exposureTime)
                    return "1/\(denominator) sec"
                } else {
                    // 1초 이상일 때
                    return "\(exposureTime) sec"
                }
            }
            
            // ExposureTime이 없으면 ShutterSpeedValue로 시도
            if let shutterSpeedValue = exifData[kCGImagePropertyExifShutterSpeedValue as String] as? Double {
                let exposureTime = pow(2, -shutterSpeedValue)
                let denominator = Int(1.0 / exposureTime)
                return "1/\(denominator) sec"
            }
            
            return "정보 없음"
        }
        
        private func extractDateTime(from exifData: [String: Any]) -> String {
            // 촬영 날짜 (DateTimeOriginal)
            if let dateTimeOriginal = exifData[kCGImagePropertyExifDateTimeOriginal as String] as? String {
                // EXIF 날짜 형식: "2024:01:20 15:30:00"
                return convertExifDateToISO8601(dateTimeOriginal)
            }
            
            // DateTimeOriginal이 없으면 DateTimeDigitized 시도
            if let dateTimeDigitized = exifData[kCGImagePropertyExifDateTimeDigitized as String] as? String {
                return convertExifDateToISO8601(dateTimeDigitized)
            }
            
            // 그것도 없으면 현재 시간
            return ISO8601DateFormatter().string(from: Date())
        }

        // EXIF 날짜를 ISO8601 형식으로 변환
        private func convertExifDateToISO8601(_ exifDate: String) -> String {
            // "2024:01:20 15:30:00" → "2024-01-20T15:30:00Z"
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            
            if let date = formatter.date(from: exifDate) {
                return ISO8601DateFormatter().string(from: date)
            }
            
            return ISO8601DateFormatter().string(from: Date())
        }
    }
    
   
}

// MARK: - 에러 타입 정의
enum ImagePickerError: Error {
    case imageLoadFailed
    case imageNotSupported
    case metadataExtractionFailed
}

