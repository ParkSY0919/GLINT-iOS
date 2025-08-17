//
//  ImageConverter.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/25/25.
//

import SwiftUI

struct ImageConverter {
    enum ImageConversionError: Error {
        case originalImageConversionFailed
        case filteredImageConversionFailed
        case imageResizingFailed
        case allCompressionLevelsFailed
        case heicHEIFConversionFailed(reason: String)
        case jpegValidationFailed(reason: String)
        case unsupportedFormat(format: String)
        
        var errorDescription: String? {
            switch self {
            case .originalImageConversionFailed:
                return "원본 이미지 데이터 변환 실패"
            case .filteredImageConversionFailed:
                return "필터 이미지 데이터 변환 실패"
            case .imageResizingFailed:
                return "이미지 크기 조정 실패"
            case .allCompressionLevelsFailed:
                return "모든 압축 품질에서 변환 실패"
            case .heicHEIFConversionFailed(let reason):
                return "HEIC/HEIF 변환 실패: \(reason)"
            case .jpegValidationFailed(let reason):
                return "JPEG 유효성 검사 실패: \(reason)"
            case .unsupportedFormat(let format):
                return "지원하지 않는 형식: \(format)"
            }
        }
    }
    
    static func convertToData(
        originalImage: UIImage?,
        filteredImage: UIImage?,
        compressionQuality: Double = 0.7
    ) throws -> [Data] {
        guard let originalImage = originalImage else {
            throw ImageConversionError.originalImageConversionFailed
        }
        
        let originalData = try convertImageToData(originalImage, compressionQuality: compressionQuality)
        
        let filteredData: Data
        if let filteredImage = filteredImage {
            do {
                filteredData = try convertImageToData(filteredImage, compressionQuality: compressionQuality)
            } catch {
                throw ImageConversionError.filteredImageConversionFailed
            }
        } else {
            filteredData = originalData
        }
        
        return [originalData, filteredData]
    }
    
    // MARK: - JPEG Validation
    private static func validateJPEGData(_ data: Data, strict: Bool = false) -> Bool {
        guard data.count >= 4 else {
            print("❌ JPEG 검증 실패: 데이터가 너무 작음 (\(data.count) bytes)")
            return false
        }
        
        // JPEG 헤더 확인 (SOI - Start of Image: 0xFF 0xD8)
        let hasValidHeader = data[0] == 0xFF && data[1] == 0xD8
        
        // JPEG 푸터 확인 (EOI - End of Image: 0xFF 0xD9)
        let hasValidFooter = data[data.count - 2] == 0xFF && data[data.count - 1] == 0xD9
        
        let headerHex = String(format: "%02X %02X", data[0], data[1])
        let footerHex = String(format: "%02X %02X", data[data.count - 2], data[data.count - 1])
        
        print("🔍 JPEG 구조 검증:")
        print("   크기: \(data.count) bytes")
        print("   헤더: \(headerHex) - \(hasValidHeader ? "✅ 유효" : "❌ 무효")")
        print("   푸터: \(footerHex) - \(hasValidFooter ? "✅ 유효" : "❌ 무효")")
        
        let isValid = hasValidHeader && hasValidFooter
        
        // strict 모드가 아니면 헤더만 검사
        if !strict {
            print("🔍 관대한 JPEG 검증: 헤더만 확인")
            return hasValidHeader
        }
        
        // strict 모드에서는 전체 구조 검사
        if isValid {
            print("🔍 엄격한 JPEG 검증: 전체 구조 분석")
            analyzeJPEGSegments(data)
        }
        
        return isValid
    }
    
    private static func analyzeJPEGSegments(_ data: Data) {
        var index = 2 // SOI 이후부터 시작
        var segmentCount = 0
        
        print("📊 JPEG 세그먼트 분석:")
        
        while index < data.count - 1 && segmentCount < 10 { // 최대 10개 세그먼트만 분석
            guard data[index] == 0xFF else { break }
            
            let marker = data[index + 1]
            let markerName = getJPEGMarkerName(marker)
            
            if marker == 0xD9 { // EOI
                print("   세그먼트 \(segmentCount): FF\(String(format: "%02X", marker)) (\(markerName))")
                break
            }
            
            if index + 3 < data.count {
                let length = (Int(data[index + 2]) << 8) | Int(data[index + 3])
                print("   세그먼트 \(segmentCount): FF\(String(format: "%02X", marker)) (\(markerName)) - 길이: \(length)")
                index += 2 + length
            } else {
                break
            }
            
            segmentCount += 1
        }
        
        print("   총 \(segmentCount)개 세그먼트 발견")
    }
    
    private static func getJPEGMarkerName(_ marker: UInt8) -> String {
        switch marker {
        case 0xD8: return "SOI (Start of Image)"
        case 0xD9: return "EOI (End of Image)"
        case 0xE0: return "APP0 (JFIF)"
        case 0xE1: return "APP1 (EXIF)"
        case 0xDB: return "DQT (Quantization Table)"
        case 0xC0: return "SOF0 (Baseline DCT)"
        case 0xC4: return "DHT (Huffman Table)"
        case 0xDA: return "SOS (Start of Scan)"
        default: return "기타 (0x\(String(format: "%02X", marker)))"
        }
    }

    // MARK: - Private Helper Methods
    private static func convertImageToData(_ image: UIImage, compressionQuality: Double) throws -> Data {
        // 이미지 정보 로깅
        let imageSize = image.size
        let scale = image.scale
        let hasAlpha = image.cgImage?.alphaInfo != .none
        
        print("🖼️ 이미지 변환 시작:")
        print("   크기: \(imageSize.width) x \(imageSize.height)")
        print("   스케일: \(scale)")
        print("   알파 채널: \(hasAlpha)")
        print("   CGImage 존재: \(image.cgImage != nil)")
        
        // HEIC/HEIF 이미지 감지 (CGImage가 있지만 jpegData 변환이 실패하는 경우)
        let isLikelyHEICOrHEIF = detectPossibleHEICOrHEIF(image)
        if isLikelyHEICOrHEIF {
            print("⚠️ HEIC/HEIF 이미지로 추정됨 - 특별 처리 시도")
            if let convertedData = convertHEICOrHEIFToJPEG(image, compressionQuality: compressionQuality) {
                print("✅ HEIC/HEIF → JPEG 변환 성공: \(convertedData.count) bytes")
                
                // JPEG 데이터 검증 (HEIC/HEIF는 엄격하게)
                if validateJPEGData(convertedData, strict: true) {
                    print("✅ HEIC/HEIF → JPEG 구조 검증 통과")
                    return convertedData
                } else {
                    print("⚠️ HEIC/HEIF → JPEG 구조 검증 실패 - 일반 변환으로 fallback")
                }
            } else {
                print("❌ HEIC/HEIF → JPEG 변환 실패")
            }
        }
        
        // 다양한 압축 품질로 시도
        let compressionLevels: [Double] = [compressionQuality, 0.5, 0.3, 0.1]
        
        for (index, quality) in compressionLevels.enumerated() {
            print("📤 JPEG 변환 시도 \(index + 1)/\(compressionLevels.count) (품질: \(quality))")
            if let data = tryImageConversion(image, compressionQuality: quality) {
                print("✅ JPEG 변환 성공: \(data.count) bytes")
                
                // JPEG 데이터 검증 (관대한 모드)
                if validateJPEGData(data, strict: false) {
                    print("✅ JPEG 구조 검증 통과")
                    return data
                } else {
                    print("⚠️ JPEG 구조 검증 실패하지만 일반 이미지는 통과")
                    return data
                }
            }
        }
        
        print("⚠️ 모든 JPEG 변환 실패 - 이미지 리사이징 시도")
        // 모든 압축 품질 실패 시 이미지 리사이징 후 재시도
        if let resizedImage = resizeImageIfNeeded(image) {
            print("🔄 리사이징 완료: \(resizedImage.size.width) x \(resizedImage.size.height)")
            for (index, quality) in compressionLevels.enumerated() {
                print("📤 리사이징 후 JPEG 변환 시도 \(index + 1)/\(compressionLevels.count) (품질: \(quality))")
                if let data = tryImageConversion(resizedImage, compressionQuality: quality) {
                    print("✅ 리사이징 후 JPEG 변환 성공: \(data.count) bytes")
                    
                    // JPEG 데이터 검증 (관대한 모드)
                    if validateJPEGData(data, strict: false) {
                        print("✅ 리사이징 후 JPEG 구조 검증 통과")
                        return data
                    } else {
                        print("⚠️ 리사이징 후 JPEG 구조 검증 실패하지만 통과")
                        return data
                    }
                }
            }
        }
        
        print("❌ 모든 변환 시도 실패")
        
        // 마지막 에러 복구 시도: 원본 데이터 fallback
        print("🔄 최종 fallback: 원본 이미지 데이터 사용 시도")
        if let fallbackData = tryFallbackConversion(image) {
            print("✅ Fallback 변환 성공: \(fallbackData.count) bytes")
            return fallbackData
        }
        
        // 모든 시도 실패 시 구체적인 에러 정보 포함
        let imageInfo = "크기: \(image.size), 스케일: \(image.scale), 방향: \(image.imageOrientation.rawValue)"
        throw ImageConversionError.allCompressionLevelsFailed
    }
    
    private static func tryImageConversion(_ image: UIImage, compressionQuality: Double) -> Data? {
        return autoreleasepool {
            return image.jpegData(compressionQuality: compressionQuality)
        }
    }
    
    private static func resizeImageIfNeeded(_ image: UIImage) -> UIImage? {
        let maxDimension: CGFloat = 2048
        let size = image.size
        
        // 이미지가 이미 작으면 리사이징 불필요
        if size.width <= maxDimension && size.height <= maxDimension {
            return image
        }
        
        let aspectRatio = size.width / size.height
        let newSize: CGSize
        
        if size.width > size.height {
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }
        
        return autoreleasepool {
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            defer { UIGraphicsEndImageContext() }
            
            image.draw(in: CGRect(origin: .zero, size: newSize))
            return UIGraphicsGetImageFromCurrentImageContext()
        }
    }
    
    static func convertToData(
        images: [UIImage?],
        compressionQuality: Double = 0.7
    ) throws -> [Data] {
        var result = [Data]()
        
        for (index, image) in images.enumerated() {
            guard let image = image else {
                throw ImageConversionError.originalImageConversionFailed
            }
            
            do {
                let data = try convertImageToData(image, compressionQuality: compressionQuality)
                result.append(data)
            } catch {
                print("이미지 \(index) 변환 실패: \(error)")
                throw ImageConversionError.originalImageConversionFailed
            }
        }
        
        return result
    }
    
    // MARK: - Fallback 변환
    private static func tryFallbackConversion(_ image: UIImage) -> Data? {
        print("🆘 Fallback 변환 시도:")
        
        // 1. PNG 변환 시도 (무손실이지만 크기가 클 수 있음)
        print("   1. PNG 변환 시도")
        if let pngData = image.pngData() {
            print("   ✅ PNG 변환 성공: \(pngData.count) bytes")
            print("   ⚠️ PNG는 서버에서 거부될 수 있음")
            return pngData
        }
        
        // 2. 극도로 낮은 품질 JPEG 시도
        print("   2. 극저품질 JPEG 시도")
        let veryLowQualities: [Double] = [0.05, 0.02, 0.01]
        
        for quality in veryLowQualities {
            if let jpegData = image.jpegData(compressionQuality: quality) {
                print("   ✅ 극저품질 JPEG 성공: \(jpegData.count) bytes (품질: \(quality))")
                return jpegData
            }
        }
        
        // 3. 이미지 크기를 극도로 줄여서 시도
        print("   3. 극소 크기 이미지 변환 시도")
        if let tinyImage = createTinyImage(from: image) {
            if let tinyJPEGData = tinyImage.jpegData(compressionQuality: 0.1) {
                print("   ✅ 극소 이미지 JPEG 성공: \(tinyJPEGData.count) bytes")
                return tinyJPEGData
            }
        }
        
        print("   ❌ 모든 Fallback 시도 실패")
        return nil
    }
    
    private static func createTinyImage(from image: UIImage) -> UIImage? {
        let tinySize = CGSize(width: 100, height: 100)
        
        return autoreleasepool {
            UIGraphicsBeginImageContextWithOptions(tinySize, false, 1.0)
            defer { UIGraphicsEndImageContext() }
            
            image.draw(in: CGRect(origin: .zero, size: tinySize))
            return UIGraphicsGetImageFromCurrentImageContext()
        }
    }
    
    // MARK: - HEIC/HEIF 처리 로직
    private static func detectPossibleHEICOrHEIF(_ image: UIImage) -> Bool {
        // HEIC/HEIF 이미지의 특징들을 확인
        guard let cgImage = image.cgImage else { return false }
        
        // 1. 색상 공간 확인 (HEIC/HEIF는 sRGB, DisplayP3, Rec2020 등 사용)
        let colorSpace = cgImage.colorSpace
        let colorSpaceName = colorSpace?.name
        
        // 2. 비트 깊이 확인 (HEIC/HEIF는 8, 10, 12비트 지원)
        let bitsPerComponent = cgImage.bitsPerComponent
        
        // 3. 알파 정보 확인 (HEIF는 다양한 알파 모드 지원)
        let alphaInfo = cgImage.alphaInfo
        
        // 4. jpegData 변환 시도가 실패하는지 확인
        let jpegConversionFails = autoreleasepool {
            return image.jpegData(compressionQuality: 0.8) == nil
        }
        
        print("🔍 HEIC/HEIF 감지 분석:")
        print("   색상 공간: \(String(describing: colorSpaceName))")
        print("   비트/컴포넌트: \(bitsPerComponent)")
        print("   알파 정보: \(alphaInfo)")
        print("   JPEG 변환 실패: \(jpegConversionFails)")
        
        // HEIC/HEIF일 가능성이 높은 조건들
        let hasDisplayP3 = colorSpaceName == CGColorSpace.displayP3
//        let hasRec2020 = colorSpaceName == CGColorSpace.rec2020
        let hasExtendedSRGB = colorSpaceName == CGColorSpace.extendedSRGB
        let hasHighBitDepth = bitsPerComponent > 8
        let hasAdvancedColorSpace = hasDisplayP3 || hasExtendedSRGB
        
        // HEIF는 더 다양한 알파 모드를 지원
        let hasComplexAlpha = alphaInfo == .premultipliedFirst || alphaInfo == .first
        
        return jpegConversionFails || hasAdvancedColorSpace || hasHighBitDepth || hasComplexAlpha
    }
    
    // MARK: - 색상 공간 최적화
    private static func determineOptimalColorSpace(from originalColorSpace: CGColorSpace?) -> CGColorSpace? {
        guard let originalColorSpace = originalColorSpace,
              let originalName = originalColorSpace.name else {
            print("🎨 원본 색상 공간 정보 없음 - sRGB 사용")
            return CGColorSpace(name: CGColorSpace.sRGB)
        }
        
        // HEIF/HEIC는 다양한 색상 공간을 지원하므로 최적의 변환 경로 선택
        switch originalName {
        case CGColorSpace.displayP3:
            print("🎨 DisplayP3 감지 - sRGB로 변환 (JPEG 호환성)")
            return CGColorSpace(name: CGColorSpace.sRGB)
            
//        case CGColorSpace.rec2020:
//            print("🎨 Rec2020 감지 - sRGB로 변환 (JPEG 호환성)")
//            return CGColorSpace(name: CGColorSpace.sRGB)
            
        case CGColorSpace.extendedSRGB:
            print("🎨 Extended sRGB 감지 - 표준 sRGB로 변환")
            return CGColorSpace(name: CGColorSpace.sRGB)
            
        case CGColorSpace.sRGB:
            print("🎨 sRGB 감지 - 변환 없이 유지")
            return originalColorSpace
            
        default:
            print("🎨 알 수 없는 색상 공간 (\(originalName)) - sRGB로 변환")
            return CGColorSpace(name: CGColorSpace.sRGB)
        }
    }
    
    // MARK: - 직접 변환 시도
    private static func tryDirectJPEGConversion(_ image: UIImage, compressionQuality: Double) -> Data? {
        // 다양한 품질로 직접 변환 시도
        let qualityLevels: [Double] = [compressionQuality, 0.8, 0.6, 0.4, 0.2]
        
        for (index, quality) in qualityLevels.enumerated() {
            print("   시도 \(index + 1): 품질 \(quality)")
            
            let result = autoreleasepool { () -> Data? in
                // 이미지 방향과 스케일을 유지하면서 새로운 UIImage 생성
                let orientationCorrectImage = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: image.imageOrientation)
                
                if let jpegData = orientationCorrectImage.jpegData(compressionQuality: quality) {
                    print("   ✅ 직접 변환 성공: \(jpegData.count) bytes (품질: \(quality))")
                    
                    // JPEG 데이터 유효성 검사 (관대한 모드)
                    if validateJPEGData(jpegData, strict: false) {
                        print("   ✅ 직접 변환 데이터 검증 통과")
                        return jpegData
                    } else {
                        print("   ⚠️ 직접 변환 데이터 검증 실패하지만 통과")
                        return jpegData
                    }
                }
                return nil
            }
            
            if let validData = result {
                return validData
            }
        }
        
        print("   ❌ 모든 직접 변환 시도 실패")
        return nil
    }
    
    // MARK: - 서버 호환성 분석
    private static func analyzeConvertedVsNative(convertedData: Data, originalImage: UIImage) {
        print("🔬 변환된 JPEG vs 원본 비교 분석:")
        print("   변환된 크기: \(convertedData.count) bytes")
        
        // 원본 이미지에서 직접 JPEG 생성해서 비교
        if let directJPEGData = originalImage.jpegData(compressionQuality: 0.7) {
            print("   직접 JPEG 크기: \(directJPEGData.count) bytes")
            print("   크기 비율: \(String(format: "%.2f", Double(convertedData.count) / Double(directJPEGData.count)))")
            
            // 첫 100바이트 비교 (헤더 영역)
            let convertedHeader = convertedData.prefix(100)
            let directHeader = directJPEGData.prefix(100)
            
            let headerMatch = convertedHeader.elementsEqual(directHeader)
            print("   헤더 일치: \(headerMatch ? "✅" : "❌")")
            
            if !headerMatch {
                print("   변환된 헤더: \(convertedHeader.map { String(format: "%02X", $0) }.prefix(10).joined(separator: " "))...")
                print("   직접 변환 헤더: \(directHeader.map { String(format: "%02X", $0) }.prefix(10).joined(separator: " "))...")
            }
        } else {
            print("   ⚠️ 직접 JPEG 변환 실패로 비교 불가")
        }
        
        // JPEG 압축 품질 추정
        let estimatedQuality = estimateJPEGQuality(from: convertedData)
        print("   추정 압축 품질: \(estimatedQuality)")
    }
    
    private static func estimateJPEGQuality(from data: Data) -> String {
        let sizePerPixel = Double(data.count)
        
        // 일반적인 JPEG 압축률 기준으로 품질 추정
        switch sizePerPixel {
        case 0..<50000:
            return "매우 낮음 (~0.1-0.3)"
        case 50000..<200000:
            return "낮음 (~0.3-0.5)"
        case 200000..<500000:
            return "보통 (~0.5-0.7)"
        case 500000..<1000000:
            return "높음 (~0.7-0.9)"
        default:
            return "매우 높음 (~0.9-1.0)"
        }
    }
    
    private static func convertHEICOrHEIFToJPEG(_ image: UIImage, compressionQuality: Double) -> Data? {
        return autoreleasepool {
            guard let cgImage = image.cgImage else {
                print("❌ CGImage 없음")
                return nil
            }
            
            // Option A: UIImage.jpegData() 직접 시도 (더 간단하고 빠름)
            print("🔄 Option A: UIImage.jpegData() 직접 변환 시도")
            if let directJPEGData = tryDirectJPEGConversion(image, compressionQuality: compressionQuality) {
                return directJPEGData
            }
            
            print("🔄 Option B: CGContext를 통한 고급 색상 공간 변환")
            
            // 원본 색상 공간 정보 분석
            let originalColorSpace = cgImage.colorSpace
            let originalColorSpaceName = originalColorSpace?.name
            print("🎨 원본 색상 공간: \(String(describing: originalColorSpaceName))")
            
            // 1. 최적의 출력 색상 공간 결정
            let targetColorSpace = determineOptimalColorSpace(from: originalColorSpace)
            guard let outputColorSpace = targetColorSpace else {
                print("❌ 출력 색상 공간 생성 실패")
                return nil
            }
            
            print("🎨 출력 색상 공간: \(outputColorSpace.name ?? CGColorSpace.sRGB)")
            
            let width = cgImage.width
            let height = cgImage.height
            let bitsPerComponent = 8
            let bytesPerRow = width * 4
            
            // 2. 최적화된 컨텍스트에서 새 이미지 생성
            guard let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: bitsPerComponent,
                bytesPerRow: bytesPerRow,
                space: outputColorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else {
                print("❌ CGContext 생성 실패")
                return nil
            }
            
            // 3. 원본 이미지를 최적화된 컨텍스트에 그리기
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            
            // 4. 새 CGImage 생성
            guard let convertedCGImage = context.makeImage() else {
                print("❌ 변환된 CGImage 생성 실패")
                return nil
            }
            
            // 5. UIImage로 변환 후 JPEG 데이터 생성
            let convertedUIImage = UIImage(cgImage: convertedCGImage, scale: image.scale, orientation: image.imageOrientation)
            
            print("🔄 HEIC/HEIF → 목적 색상 공간 변환 완료")
            
            // 6. 여러 품질로 JPEG 데이터 변환 시도 (서버 호환성 향상)
            let fallbackQualities: [Double] = [compressionQuality, 0.8, 0.6, 0.5]
            
            for (index, quality) in fallbackQualities.enumerated() {
                if let jpegData = convertedUIImage.jpegData(compressionQuality: quality) {
                    print("✅ HEIC/HEIF → JPEG 변환 성공 (시도 \(index + 1), 품질: \(quality))")
                    
                    // 변환된 데이터와 원본 비교 분석
                    analyzeConvertedVsNative(convertedData: jpegData, originalImage: image)
                    
                    if validateJPEGData(jpegData, strict: true) {
                        return jpegData
                    } else {
                        print("⚠️ CGContext 변환 결과 검증 실패 - 다음 품질로 재시도")
                        continue
                    }
                }
            }
            
            print("❌ 모든 CGContext 변환 시도 실패")
            
            // 마지막 시도: 원본 이미지로 fallback
            print("🔄 HEIC/HEIF 원본 이미지 fallback 시도")
            return tryFallbackConversion(image)
        }
    }
}
