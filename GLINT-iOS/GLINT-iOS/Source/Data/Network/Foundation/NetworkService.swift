//
//  NetworkService.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/9/25.
//

//
//  NetworkService.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/9/25.
//

import Foundation

import Alamofire

let defaultSession = Session()

struct NetworkService<E: EndPoint>: NetworkServiceInterface {
    /// 응답 O 에러 핸들러
    private func handleError<U: EndPoint>(_ error: Error, endPoint: U) throws -> Never {
        GTLogger.shared.networkFailure("networkFailure", error: error)
        
        if let afError = error as? AFError {
            switch afError {
            case .responseSerializationFailed(let reason):
                if case .decodingFailed(let decodingError) = reason {
                    GTLogger.shared.i("디코딩 에러: \(decodingError)")
                }
            case .responseValidationFailed(let reason):
                switch reason {
                case .unacceptableStatusCode(let code):
                    GTLogger.shared.i("서버 응답 상태 코드: \(code)")
                case .dataFileNil:
                    GTLogger.shared.i("응답 데이터가 없음")
                default:
                    break
                }
            default:
                break
            }
            
            // 재시도 실패 시 원본 에러를 다시 던짐
            if case let AFError.requestRetryFailed(retryError: retryError, originalError: _) = afError {
                throw retryError
            }
        }
        
        // 타임아웃 에러는 그대로 throw
        if let urlError = error as? URLError, urlError.code == .timedOut {
            throw error
        }
        
        // 그 외의 경우 endPoint의 커스텀 에러로 변환
        throw endPoint.throwError(error as? AFError ?? AFError.explicitlyCancelled)
    }
    
    //MARK: 응답값 O
    func request<T: ResponseData>(_ endPoint: E) async throws -> T {
        let type: InterceptorType = endPoint.path == "refresh" ? .refresh : .default
        
        GTLogger.shared.networkRequest("🚀 NetworkStart: \(endPoint.method.rawValue) \(endPoint.baseURL)\(endPoint.path)")
        
        let request = defaultSession.request(
            endPoint,
            interceptor: Interceptor(interceptors: [GTInterceptor(type: type)])
        )
        
        request.cURLDescription { description in
            print("🌐 CURL:", description)
        }
        
        do {
            let value = try await withTimeout(seconds: 10) {
                // 먼저 응답 데이터와 상태코드를 가져옴
                let response = try await request.serializingData().response
                
                // 응답 상태코드 확인
                if let statusCode = response.response?.statusCode {
                    print("📊 Status Code: \(statusCode)")
                    
                    // 에러 상태코드인 경우
                    if !(200..<300).contains(statusCode) {
                        // 에러 응답 내용을 문자열로 출력
                        if let data = response.data,
                           let errorBodyString = String(data: data, encoding: .utf8) {
                            print("❌ Server Error Response:")
                            print("   Status Code: \(statusCode)")
                            print("   Body: \(errorBodyString)")
                            
                            // JSON 파싱 시도해서 더 읽기 쉽게 출력
                            if let json = try? JSONSerialization.jsonObject(with: data, options: []),
                               let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                               let prettyString = String(data: prettyData, encoding: .utf8) {
                                print("   Formatted JSON:")
                                print(prettyString)
                            }
                        }
                        
                        // 상태코드 에러 throw
                        throw AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: statusCode))
                    }
                }
                
                // 성공 상태코드인 경우 디코딩 진행
                guard let data = response.data else {
                    throw AFError.responseSerializationFailed(reason: .inputFileNil)
                }
                
                do {
                    let decodedValue = try endPoint.decoder.decode(T.self, from: data)
                    return decodedValue
                } catch {
                    // 디코딩 실패 시 원본 데이터도 출력
                    print("❌ Decoding Error:")
                    print("   Error: \(error)")
                    if let rawString = String(data: data, encoding: .utf8) {
                        print("   Raw Response: \(rawString)")
                    }
                    throw error
                }
            }
            
            GTLogger.shared.networkSuccess("networkSuccess")
            print("✅ Success Response: \(value)")
            return value
            
        } catch {
            // handleError를 호출하여 에러 처리
            try handleError(error, endPoint: endPoint)
        }
    }

    // 타임아웃 헬퍼 함수
    func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw URLError(.timedOut)
            }
            
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
    
    //MARK: 응답값 X
    func requestVoid(_ endPoint: E) async throws {
        let type: InterceptorType = endPoint.path == "refresh" ? .refresh : .default
        
        GTLogger.shared.networkRequest("🚀 NetworkStart (Void): \(endPoint.method.rawValue) \(endPoint.baseURL)\(endPoint.path)")
        
        let request = defaultSession.request(
            endPoint,
            interceptor: Interceptor(interceptors: [GTInterceptor(type: type)])
        )
        
        do {
            // response headers만 확인, body는 기다리지 않음
            try await withCheckedThrowingContinuation { continuation in
                request.response { response in
                    if let statusCode = response.response?.statusCode, 200..<300 ~= statusCode {
                        GTLogger.shared.networkSuccess("networkSuccess (Void Response) - Status: \(statusCode)")
                        continuation.resume()
                    } else {
                        let statusCode = response.response?.statusCode ?? -1
                        let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: statusCode))
                        continuation.resume(throwing: error)
                    }
                }
            }
            
        } catch {
            try handleError(error, endPoint: endPoint)
        }
    }
    
    /// 멀티파트폼
    func requestMultipart<T: ResponseData>(_ endPoint: E) async throws -> T {
        guard case .multipartData(let config) = endPoint.requestType else {
            throw GLError.typeError("Multipart 메서드에 잘못된 requestType이 전달됨")
        }
        
        GTLogger.shared.networkRequest("🚀 NetworkStart (Multipart): \(endPoint.method.rawValue) \(endPoint.baseURL)\(endPoint.path)")
        
        // 파일 데이터 검증 및 로깅
        print("📋 Multipart 파일 검증:")
        var totalSize = 0
        
        for (index, data) in config.files.enumerated() {
            let fileSize = data.count
            let fileSizeMB = Double(fileSize) / (1024 * 1024)
            totalSize += fileSize
            
            print("   파일 \(index): \(fileSize) bytes (\(String(format: "%.2f", fileSizeMB)) MB)")
            
            // 파일 크기 경고
            if fileSizeMB > 5.0 {
                print("   ⚠️ 파일 \(index): 크기가 5MB를 초과함 (서버 제한 가능성)")
            }
            
            // 파일이 비어있는지 확인
            if data.isEmpty {
                print("   ❌ 파일 \(index)가 비어있음!")
            }
            
            // JPEG 헤더 확인
            if data.count >= 2 {
                let header = data.prefix(2)
                let headerBytes = [UInt8](header)
                if headerBytes[0] == 0xFF && headerBytes[1] == 0xD8 {
                    print("   ✅ 파일 \(index): 유효한 JPEG 헤더")
                } else {
                    print("   ⚠️ 파일 \(index): JPEG 헤더 아님 (\(String(format: "%02X %02X", headerBytes[0], headerBytes[1])))")
                }
            }
        }
        
        let totalSizeMB = Double(totalSize) / (1024 * 1024)
        print("📊 총 파일 크기: \(totalSize) bytes (\(String(format: "%.2f", totalSizeMB)) MB)")
        
        if totalSizeMB > 10.0 {
            print("⚠️ 총 파일 크기가 10MB를 초과함 - 서버에서 거부될 수 있음")
        }
        
        let request = defaultSession.upload(
            multipartFormData: { formData in
                for (index, data) in config.files.enumerated() {
                    let fileName = "file\(index).\(config.fileExtension)"
                    print("📤 Multipart 파일 추가: \(fileName) (\(data.count) bytes) -> 필드명: \(config.fieldName)")
                    
                    formData.append(
                        data,
                        withName: config.fieldName,
                        fileName: fileName,
                        mimeType: config.mimeType
                    )
                }
                
                print("✅ Multipart FormData 구성 완료 - 총 \(config.files.count)개 파일")
            },
            to: endPoint.baseURL + endPoint.path,
            method: endPoint.method,
            interceptor: Interceptor(interceptors: [GTInterceptor(type: .multipart)])
        )
        
        do {
            let value = try await withTimeout(seconds: 10) {
                try await request
                    .validate(statusCode: 200..<300)
                    .serializingDecodable(T.self, decoder: endPoint.decoder)
                    .value
            }
            
            GTLogger.shared.networkSuccess("networkSuccess (Multipart)")
            return value
            
        } catch {
            // Multipart 요청 실패 시 상세 에러 정보 출력
            print("❌ Multipart 요청 실패:")
            print("   URL: \(endPoint.baseURL + endPoint.path)")
            print("   Method: \(endPoint.method.rawValue)")
            print("   파일 수: \(config.files.count)")
            
            if let afError = error as? AFError {
                switch afError {
                case .responseValidationFailed(let reason):
                    if case .unacceptableStatusCode(let code) = reason {
                        print("   상태 코드: \(code)")
                        
                        // 400 에러인 경우 응답 내용도 출력
                        if code == 400 {
                            // 여러 방법으로 응답 데이터 확인 시도
                            var responseString: String?
                            
                            if let responseData = afError.downloadResumeData {
                                responseString = String(data: responseData, encoding: .utf8)
                                print("   서버 응답 (responseData): \(responseString ?? "디코딩 실패")")
                            } else if let underlyingError = afError.underlyingError as? URLError,
                                      let failureReason = afError.failureReason {
                                print("   URLError: \(underlyingError.localizedDescription)")
                                print("   실패 이유: \(failureReason)")
                            } else {
                                print("   응답 데이터를 가져올 수 없음")
                            }
                        }
                    }
                case .responseSerializationFailed(let reason):
                    print("   직렬화 실패: \(reason)")
                default:
                    print("   기타 AFError: \(afError.localizedDescription)")
                }
            } else {
                print("   일반 에러: \(error.localizedDescription)")
            }
            
            // handleError를 호출하여 에러 처리
            try handleError(error, endPoint: endPoint)
        }
    }
}
