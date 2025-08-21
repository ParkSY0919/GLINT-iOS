//
//  ImagePicker.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/3/25.
//

import SwiftUI
import PhotosUI
import Photos
import UniformTypeIdentifiers

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
            
            // Live Photo 체크 및 처리
            if asset.mediaSubtypes.contains(.photoLive) {
                return await extractFromLivePhoto(asset: asset)
            }
            
            return await withCheckedContinuation { continuation in
                let options = PHImageRequestOptions()
                options.isSynchronous = false
                options.deliveryMode = .highQualityFormat
                options.isNetworkAccessAllowed = true
                
                // HEIC 포맷 호환성 개선
                if let filename = asset.value(forKey: "filename") as? String,
                   filename.lowercased().contains("heic") {
                    options.resizeMode = .exact
                    options.deliveryMode = .opportunistic
                }
                
                PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, dataUTI, orientation, info in
                    guard let imageData = data else {
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    let metadata = self.extractEXIFData(from: imageData, asset: asset, dataUTI: dataUTI)
                    continuation.resume(returning: metadata)
                }
            }
        }
        
        private func extractFromFile(result: PHPickerResult) async -> PhotoMetadataEntity? {
            return await withCheckedContinuation { continuation in
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
                    guard let url = url, error == nil else {
                        // 권한 제한 시 대체 처리
                        let fallbackMetadata = self.createFallbackMetadata()
                        continuation.resume(returning: fallbackMetadata)
                        return
                    }
                    
                    do {
                        let imageData = try Data(contentsOf: url)
                        let metadata = self.extractEXIFData(from: imageData, asset: nil)
                        continuation.resume(returning: metadata)
                    } catch {
                        print("파일 읽기 실패: \(error)")
                        let fallbackMetadata = self.createFallbackMetadata()
                        continuation.resume(returning: fallbackMetadata)
                    }
                }
            }
        }
        
        private func extractEXIFData(from imageData: Data, asset: PHAsset?, dataUTI: String? = nil) -> PhotoMetadataEntity? {
            guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil),
                  let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
                print("이미지 소스 생성 실패 - fallback 메타데이터 사용")
                return createFallbackMetadata()
            }
            
            // 메타데이터 추출 시 예외 처리 강화
            let exifData: [String: Any]
            let tiffData: [String: Any]
            let gpsData: [String: Any]
            
            do {
                exifData = properties[kCGImagePropertyExifDictionary as String] as? [String: Any] ?? [:]
                tiffData = properties[kCGImagePropertyTIFFDictionary as String] as? [String: Any] ?? [:]
                gpsData = properties[kCGImagePropertyGPSDictionary as String] as? [String: Any] ?? [:]
            } catch {
                print("메타데이터 파싱 오류: \(error)")
                return createFallbackMetadata()
            }
            
            let phoneInfo = extractPhoneInfo(from: tiffData)
            let (lensType, focalLength, aperture, iso) = extractPhotoMetaData(exifData: exifData, properties: properties)
            let (latitude, longitude) = extractGPSInfo(from: gpsData, asset: asset)
            let shutterSpeed = extractShutterSpeed(from: exifData)
            let fileSize = imageData.count
            let format = extractFileFormat(from: properties, dataUTI: dataUTI)
            let dateTime = extractDateTime(from: exifData, asset: asset)
            
            let pixelWidth = properties[kCGImagePropertyPixelWidth as String] as? Int ?? 0
            let pixelHeight = properties[kCGImagePropertyPixelHeight as String] as? Int ?? 0
            
            let metadata = PhotoMetadataEntity(
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
            
            // 서드파티 편집 감지 로그
            if detectThirdPartyEditing(metadata: metadata, asset: asset) {
                print("서드파티 편집된 이미지 감지: \(metadata.camera ?? "알 수 없음")")
            }
            
            return metadata
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
            
            // 1. PHAsset.location을 우선 시도 (더 신뢰할 수 있음)
            if let asset = asset, let location = asset.location {
                let lat = Float(location.coordinate.latitude)
                let lon = Float(location.coordinate.longitude)
                
                if isValidCoordinate(latitude: lat, longitude: lon) {
                    print("✅ GPS 정보 PHAsset에서 추출: lat=\(lat), lon=\(lon)")
                    return (lat, lon)
                } else {
                    print("⚠️ PHAsset GPS 좌표가 유효하지 않음: lat=\(lat), lon=\(lon)")
                }
            } else {
                print("ℹ️ PHAsset location 정보 없음")
            }
            
            // 2. EXIF GPS 데이터에서 추출 시도
            if !gpsData.isEmpty {
                print("ℹ️ EXIF GPS 데이터 시도 중...")
                
                if let extractedLat = extractGPSValue(from: gpsData, key: kCGImagePropertyGPSLatitude as String),
                   let latRef = gpsData[kCGImagePropertyGPSLatitudeRef as String] as? String,
                   let extractedLon = extractGPSValue(from: gpsData, key: kCGImagePropertyGPSLongitude as String),
                   let lonRef = gpsData[kCGImagePropertyGPSLongitudeRef as String] as? String {
                    
                    latitude = latRef == "S" ? -extractedLat : extractedLat
                    longitude = lonRef == "W" ? -extractedLon : extractedLon
                    
                    if isValidCoordinate(latitude: latitude, longitude: longitude) {
                        print("✅ GPS 정보 EXIF에서 추출: lat=\(latitude), lon=\(longitude)")
                        return (latitude, longitude)
                    } else {
                        print("⚠️ EXIF GPS 좌표가 유효하지 않음: lat=\(latitude), lon=\(longitude)")
                    }
                } else {
                    print("⚠️ EXIF GPS 데이터 파싱 실패")
                }
            } else {
                print("ℹ️ EXIF GPS 데이터 없음")
            }
            
            print("❌ GPS 정보를 찾을 수 없음")
            return (0.0, 0.0)
        }
        
        // MARK: - GPS Helper Methods
        private func extractGPSValue(from gpsData: [String: Any], key: String) -> Float? {
            if let floatValue = gpsData[key] as? Float {
                return floatValue
            } else if let doubleValue = gpsData[key] as? Double {
                return Float(doubleValue)
            } else if let numberValue = gpsData[key] as? NSNumber {
                return numberValue.floatValue
            }
            return nil
        }
        
        private func isValidCoordinate(latitude: Float, longitude: Float) -> Bool {
            // 0,0 좌표는 유효하지 않은 것으로 간주
            if latitude == 0.0 && longitude == 0.0 {
                return false
            }
            
            // 유효한 위도/경도 범위 확인
            let isLatValid = latitude >= -90.0 && latitude <= 90.0
            let isLonValid = longitude >= -180.0 && longitude <= 180.0
            
            return isLatValid && isLonValid
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
        
        private func extractFileFormat(from properties: [String: Any], dataUTI: String? = nil) -> String {
            // dataUTI를 우선적으로 사용하여 정확한 형식 식별
            if let uti = dataUTI {
                let lowerUTI = uti.lowercased()
                if lowerUTI.contains("heic") || lowerUTI.contains("public.heic") {
                    return "HEIC"
                } else if lowerUTI.contains("heif") || lowerUTI.contains("public.heif") {
                    return "HEIF"
                } else if lowerUTI.contains("jpeg") || lowerUTI.contains("jpg") || lowerUTI.contains("public.jpeg") {
                    return "JPEG"
                } else if lowerUTI.contains("png") || lowerUTI.contains("public.png") {
                    return "PNG"
                }
                
                print("🔍 감지된 UTI: \(uti) -> 형식을 특정할 수 없음")
            }
            
            // 기존 로직 유지
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
        
        private func extractDateTime(from exifData: [String: Any], asset: PHAsset? = nil) -> String {
            // EXIF에서 날짜 추출 시도
            if let dateTimeOriginal = exifData[kCGImagePropertyExifDateTimeOriginal as String] as? String {
                let convertedDate = convertExifDateToISO8601(dateTimeOriginal)
                if !is1970Date(convertedDate) {
                    return convertedDate
                }
            }
            
            if let dateTimeDigitized = exifData[kCGImagePropertyExifDateTimeDigitized as String] as? String {
                let convertedDate = convertExifDateToISO8601(dateTimeDigitized)
                if !is1970Date(convertedDate) {
                    return convertedDate
                }
            }
            
            // PHAsset의 creationDate 사용 (1970년 오류 방지)
            if let asset = asset, let creationDate = asset.creationDate {
                return ISO8601DateFormatter().string(from: creationDate)
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
        
        // MARK: - Live Photo 처리
        private func extractFromLivePhoto(asset: PHAsset) async -> PhotoMetadataEntity? {
            return await withCheckedContinuation { continuation in
                let options = PHLivePhotoRequestOptions()
                options.deliveryMode = .highQualityFormat
                options.isNetworkAccessAllowed = true
                
                PHImageManager.default().requestLivePhoto(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { livePhoto, info in
                    // Live Photo에서 스틸 이미지 메타데이터 추출
                    let imageOptions = PHImageRequestOptions()
                    imageOptions.deliveryMode = .highQualityFormat
                    imageOptions.isNetworkAccessAllowed = true
                    
                    PHImageManager.default().requestImageDataAndOrientation(for: asset, options: imageOptions) { data, dataUTI, orientation, info in
                        guard let imageData = data else {
                            continuation.resume(returning: nil)
                            return
                        }
                        
                        let metadata = self.extractEXIFData(from: imageData, asset: asset, dataUTI: dataUTI)
                        continuation.resume(returning: metadata)
                    }
                }
            }
        }
        
        // MARK: - 예외 처리 및 유틸리티
        private func is1970Date(_ dateString: String) -> Bool {
            return dateString.hasPrefix("1970-")
        }
        
        private func createFallbackMetadata() -> PhotoMetadataEntity {
            return PhotoMetadataEntity(
                camera: "정보 없음",
                lensInfo: "정보 없음",
                focalLength: 0,
                aperture: 0,
                iso: 0,
                shutterSpeed: "정보 없음",
                pixelWidth: 0,
                pixelHeight: 0,
                fileSize: 0,
                format: "Unknown",
                dateTimeOriginal: ISO8601DateFormatter().string(from: Date()),
                latitude: 0,
                longitude: 0,
                photoMetadataString: "정보 없음",
                megapixelInfoString: "정보 없음"
            )
        }
        
        // MARK: - 이미지 품질 평가
        private func evaluateImageQuality(metadata: PhotoMetadataEntity) -> Double {
            var score: Double = 0.0
            
            // 해상도 점수 (30%)
            let pixels = Double((metadata.pixelWidth ?? 0) * (metadata.pixelHeight ?? 0))
            let resolutionScore = min(pixels / 12_000_000, 1.0) * 0.3 // 12MP를 기준으로 정규화
            score += resolutionScore
            
            // 메타데이터 완성도 점수 (40%)
            var metadataCompleteness: Double = 0.0
            let fields = [
                metadata.camera != nil && metadata.camera != "정보 없음",
                metadata.lensInfo != nil && metadata.lensInfo != "카메라 정보 없음",
                metadata.focalLength != nil && metadata.focalLength! > 0,
                metadata.aperture != nil && metadata.aperture! > 0,
                metadata.iso != nil && metadata.iso! > 0,
                metadata.latitude != nil && metadata.latitude! != 0,
                metadata.longitude != nil && metadata.longitude! != 0
            ]
            metadataCompleteness = Double(fields.filter { $0 }.count) / Double(fields.count)
            score += metadataCompleteness * 0.4
            
            // 파일 크기 점수 (30%)
            let fileSizeScore = min(Double(metadata.fileSize ?? 0) / 5_000_000, 1.0) * 0.3 // 5MB를 기준으로 정규화
            score += fileSizeScore
            
            return score
        }
        
        // MARK: - 서드파티 편집 감지
        private func detectThirdPartyEditing(metadata: PhotoMetadataEntity, asset: PHAsset?) -> Bool {
            guard let asset = asset else { return false }
            
            // 편집된 이미지인지 확인
            if asset.mediaSubtypes.contains(.photoScreenshot) {
                return true
            }
            
            // 소프트웨어 정보로 편집 여부 감지 (추후 EXIF에서 Software 태그 확인 가능)
            if let camera = metadata.camera,
               !camera.contains("iPhone") && !camera.contains("iPad") && camera != "정보 없음" {
                return true
            }
            
            return false
        }
    }
    
   
}

// MARK: - 에러 타입 정의
enum ImagePickerError: Error {
    case imageLoadFailed
    case imageNotSupported
    case metadataExtractionFailed
}

