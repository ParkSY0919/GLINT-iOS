//
//  ImagePicker.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/3/25.
//

import SwiftUI
import PhotosUI

// MARK: - ImagePicker Mode
enum ImagePickerMode {
    case single(onImageSelected: (UIImage, PhotoMetadataEntity?) -> Void)
    case multiple(maxCount: Int, onImagesSelected: ([UIImage]) -> Void)
}

struct ImagePicker: UIViewControllerRepresentable {
    let mode: ImagePickerMode
    @Environment(\.dismiss) private var dismiss
    
    // Chat용 다중 선택 초기화
    init(maxSelectionCount: Int = 5, onImagesSelected: @escaping ([UIImage]) -> Void) {
        self.mode = .multiple(maxCount: maxSelectionCount, onImagesSelected: onImagesSelected)
    }
    
    // Make용 단일 선택 초기화
    init(onImageSelected: @escaping (UIImage, PhotoMetadataEntity?) -> Void) {
        self.mode = .single(onImageSelected: onImageSelected)
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.preferredAssetRepresentationMode = .current
        
        // Mode에 따른 설정
        switch mode {
        case .single:
            configuration.selectionLimit = 1
        case .multiple(let maxCount, _):
            configuration.selectionLimit = maxCount
        }
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        
        // Mode에 따른 UI 구성
        switch mode {
        case .single:
            // Make용: 기본 PHPickerViewController 반환 (자동 dismiss)
            let navController = UINavigationController(rootViewController: picker)
            picker.navigationItem.title = "사진 선택"
            return navController
            
        case .multiple(let maxCount, _):
            // Chat용: 확인 버튼이 있는 NavigationController
            let navController = UINavigationController(rootViewController: picker)
            
            let confirmButton = UIBarButtonItem(
                title: "확인",
                style: .done,
                target: context.coordinator,
                action: #selector(context.coordinator.confirmSelection)
            )
            confirmButton.isEnabled = false
            
            let cancelButton = UIBarButtonItem(
                title: "취소",
                style: .plain,
                target: context.coordinator,
                action: #selector(context.coordinator.cancelSelection)
            )
            
            picker.navigationItem.rightBarButtonItem = confirmButton
            picker.navigationItem.leftBarButtonItem = cancelButton
            picker.navigationItem.title = "사진 선택 (최대 \(maxCount)개)"
            
            context.coordinator.confirmButton = confirmButton
            return navController
        }
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: PHPickerViewControllerDelegate {
        let parent: ImagePicker
        var confirmButton: UIBarButtonItem?
        private var selectedImages: [UIImage] = []
        private var selectedResults: [PHPickerResult] = []
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        @objc func confirmSelection() {
            if case .multiple(_, let onImagesSelected) = parent.mode {
                onImagesSelected(selectedImages)
            }
            parent.dismiss()
        }
        
        @objc func cancelSelection() {
            parent.dismiss()
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            switch parent.mode {
            case .single(let onImageSelected):
                // Make용: 단일 이미지 선택 + 메타데이터 추출
                parent.dismiss()
                guard let result = results.first else { return }
                
                Task {
                    await processSingleImage(result, onImageSelected: onImageSelected)
                }
                
            case .multiple(let maxCount, _):
                // Chat용: 다중 이미지 선택
                selectedResults = results
                confirmButton?.isEnabled = !results.isEmpty
                
                let selectedCount = results.count
                picker.navigationItem.title = "사진 선택됨 (\(selectedCount)/\(maxCount))"
                
                loadSelectedImages(from: results)
            }
        }
        
        // MARK: - Single Image Processing (Make용)
        @MainActor
        private func processSingleImage(_ result: PHPickerResult, onImageSelected: @escaping (UIImage, PhotoMetadataEntity?) -> Void) async {
            do {
                let image = try await loadImage(from: result)
                let metadata = await extractMetadata(from: result)
                onImageSelected(image, metadata)
            } catch {
                print("이미지 처리 중 오류 발생: \(error)")
                let fallbackImage = UIImage(systemName: "photo") ?? UIImage()
                onImageSelected(fallbackImage, nil)
            }
        }
        
        // MARK: - Multiple Images Processing (Chat용)
        private func loadSelectedImages(from results: [PHPickerResult]) {
            selectedImages.removeAll()
            
            let dispatchGroup = DispatchGroup()
            var loadedImages: [(Int, UIImage)] = []
            
            for (index, result) in results.enumerated() {
                dispatchGroup.enter()
                
                Task {
                    do {
                        let image = try await loadImage(from: result)
                        await MainActor.run {
                            loadedImages.append((index, image))
                            dispatchGroup.leave()
                        }
                    } catch {
                        print("이미지 로드 실패: \(error)")
                        await MainActor.run {
                            dispatchGroup.leave()
                        }
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                loadedImages.sort { $0.0 < $1.0 }
                self.selectedImages = loadedImages.map { $0.1 }
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
        
        // MARK: - 메타데이터 추출 (Make용)
        private func extractMetadata(from result: PHPickerResult) async -> PhotoMetadataEntity? {
            // PHAsset에서 추출 시도
            if let assetIdentifier = result.assetIdentifier {
                if let metadata = await extractFromPHAsset(identifier: assetIdentifier) {
                    return metadata
                }
            }
            
            // 파일에서 직접 추출
            return await extractFromFile(result: result)
        }
        
        private func extractFromPHAsset(identifier: String) async -> PhotoMetadataEntity? {
            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
            guard let asset = fetchResult.firstObject else { return nil }
            
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
        
        private func extractEXIFData(from imageData: Data, asset: PHAsset?) -> PhotoMetadataEntity? {
            guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil),
                  let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
                return nil
            }
            
            let exifData = properties[kCGImagePropertyExifDictionary as String] as? [String: Any] ?? [:]
            let tiffData = properties[kCGImagePropertyTIFFDictionary as String] as? [String: Any] ?? [:]
            let gpsData = properties[kCGImagePropertyGPSDictionary as String] as? [String: Any] ?? [:]
            
            let phoneInfo = extractPhoneInfo(from: tiffData)
            let (lensType, focalLength, aperture, iso) = extractPhotoMetaData(exifData: exifData, properties: properties)
            let (latitude, longitude) = extractGPSInfo(from: gpsData, asset: asset)
            let shutterSpeed = extractShutterSpeed(from: exifData)
            let fileSize = imageData.count
            let format = extractFileFormat(from: properties)
            let dateTime = extractDateTime(from: exifData)
            
            let pixelWidth = properties[kCGImagePropertyPixelWidth as String] as? Int ?? 0
            let pixelHeight = properties[kCGImagePropertyPixelHeight as String] as? Int ?? 0
            
            return PhotoMetadataEntity(
                camera: phoneInfo,
                lensInfo: lensType,
                focalLength: focalLength,
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
                    focalLength: focalLength,
                    aperture: aperture,
                    iso: iso),
                megapixelInfoString: MegapixelCalculator.calculateMPString(
                    width: pixelWidth,
                    height: pixelHeight,
                    fileSize: fileSize
                )
            )
        }
        
        // MARK: - Helper Methods
        private func extractPhoneInfo(from tiffData: [String: Any]) -> String {
            let make = tiffData[kCGImagePropertyTIFFMake as String] as? String ?? ""
            let model = tiffData[kCGImagePropertyTIFFModel as String] as? String ?? ""
            
            if make != "" && model != "" {
                return "\(make) \(model)".trimmingCharacters(in: .whitespaces)
            } else {
                return "정보 없음"
            }
        }
        
        private func extractPhotoMetaData(exifData: [String: Any], properties: [String: Any]) -> (String, Float, Float, Int) {
            var lensType = "카메라 정보 없음"
            var focalLength: Float = 0
            var aperture: Float = 0
            var iso: Int = 0
            
            if let focalLengthValue = exifData[kCGImagePropertyExifFocalLength as String] as? Double {
                lensType = determineCameraTypeByFocalLength(focalLengthValue)
            }
            
            if let focalLengthData = exifData[kCGImagePropertyExifFocalLength as String] as? Float,
               let apertureData = exifData[kCGImagePropertyExifFNumber as String] as? Float,
               let isoData = exifData[kCGImagePropertyExifISOSpeedRatings as String] as? [Int],
               let isoValue = isoData.first {
                focalLength = focalLengthData
                aperture = apertureData
                iso = isoValue
            }
            
            return (lensType, focalLength, aperture, iso)
        }
        
        private func extractGPSInfo(from gpsData: [String: Any], asset: PHAsset?) -> (Float, Float) {
            var latitude: Float = 0.0
            var longitude: Float = 0.0
            
            if !gpsData.isEmpty {
                if let lat = gpsData[kCGImagePropertyGPSLatitude as String] as? Float,
                   let latRef = gpsData[kCGImagePropertyGPSLatitudeRef as String] as? String,
                   let lon = gpsData[kCGImagePropertyGPSLongitude as String] as? Float,
                   let lonRef = gpsData[kCGImagePropertyGPSLongitudeRef as String] as? String {
                    
                    latitude = latRef == "S" ? -lat : lat
                    longitude = lonRef == "W" ? -lon : lon
                }
            } else if let asset = asset, let location = asset.location {
                latitude = Float(location.coordinate.latitude)
                longitude = Float(location.coordinate.longitude)
            }
            
            return (latitude, longitude)
        }
        
        private func determineCameraTypeByFocalLength(_ focalLength: Double) -> String {
            switch focalLength {
            case 0..<2.0:
                return "초광각 카메라"
            case 2.0..<5.0:
                return "와이드 카메라"
            case 5.0..<10.0:
                return "망원 카메라"
            case 10.0...:
                return "망원 카메라"
            default:
                return "와이드 카메라"
            }
        }
        
        private func extractFileFormat(from properties: [String: Any]) -> String {
            if let colorModel = properties[kCGImagePropertyColorModel as String] as? String {
                return colorModel == "RGB" ? "JPEG" : "Unknown"
            }
            return "JPEG"
        }
        
        private func extractShutterSpeed(from exifData: [String: Any]) -> String {
            if let exposureTime = exifData[kCGImagePropertyExifExposureTime as String] as? Double {
                if exposureTime < 1.0 {
                    let denominator = Int(1.0 / exposureTime)
                    return "1/\(denominator) sec"
                } else {
                    return "\(exposureTime) sec"
                }
            }
            
            if let shutterSpeedValue = exifData[kCGImagePropertyExifShutterSpeedValue as String] as? Double {
                let exposureTime = pow(2, -shutterSpeedValue)
                let denominator = Int(1.0 / exposureTime)
                return "1/\(denominator) sec"
            }
            
            return "정보 없음"
        }
        
        private func extractDateTime(from exifData: [String: Any]) -> String {
            if let dateTimeOriginal = exifData[kCGImagePropertyExifDateTimeOriginal as String] as? String {
                return convertExifDateToISO8601(dateTimeOriginal)
            }
            
            if let dateTimeDigitized = exifData[kCGImagePropertyExifDateTimeDigitized as String] as? String {
                return convertExifDateToISO8601(dateTimeDigitized)
            }
            
            return ISO8601DateFormatter().string(from: Date())
        }
        
        private func convertExifDateToISO8601(_ exifDate: String) -> String {
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

