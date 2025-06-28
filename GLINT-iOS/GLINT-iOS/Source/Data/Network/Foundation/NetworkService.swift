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
    /// 응답 O Response 핸들
    private func handleResponse<T>(_ response: DataResponse<T, AFError>, endPoint: E) throws -> T {
        GTLogger.shared.i("response: \n\(response)")
        
        switch response.result {
        case .success(let value):
            GTLogger.shared.networkSuccess("networkSuccess")
            return value
        case .failure(let error):
            if let data = response.data {
                let responseString = String(data: data, encoding: .utf8) ?? "응답 데이터를 읽을 수 없음"
                GTLogger.shared.i("서버 응답 메시지: \(responseString)")
            }
            GTLogger.shared.networkFailure("networkFailure", error: error)
            
            // 재시도 실패 시 원본 에러를 다시 던짐
            if case let AFError.requestRetryFailed(retryError: retryError, originalError: _) = error {
                throw retryError
            }
            // 그 외의 경우, EndPoint에 정의된 커스텀 에러로 변환하여 던짐
            throw endPoint.throwError(error)
        }
    }
    
    private func handleNoResponse(_ response: DataResponse<Data, AFError>, endPoint: E) throws {
        GTLogger.shared.i("response: \n\(response)")
        
        switch response.result {
        case .success:
            if let afError = response.error,
               case .responseSerializationFailed(.inputDataNilOrZeroLength) = afError,
               response.response?.statusCode == 200 {
                GTLogger.shared.networkSuccess("networkSuccess (Void Response)")
                return
            }
            return
        case .failure(let error):
            if case let AFError.requestRetryFailed(retryError: retryError, originalError: _) = error {
                throw retryError
            }
            throw endPoint.throwError(error)
        }
    }
    
    //MARK: 응답값 O
    func request<T: ResponseData>(_ endPoint: E) async throws -> T {
        let type: InterceptorType = endPoint.path == "refresh" ? .refresh : .default
        
        GTLogger.shared.networkRequest("🚀 NetworkStart: \(endPoint.method.rawValue) \(endPoint.baseURL)\(endPoint.path)")
        
        let request = defaultSession.request(
            endPoint,
            interceptor: Interceptor(interceptors: [GTInterceptor(type: type)])
        )
        
        print("📝 Step 1: Request created")
        
        do {
            let response = await request
                .validate(statusCode: 200..<300)
                .serializingDecodable(T.self, decoder: endPoint.decoder)
                .response
            
            print("📝 Step 2: Response received")
            print("@@@", response)
            
            return try handleResponse(response, endPoint: endPoint)
        } catch {
            print("❌ Error occurred: \(error)")
            throw error
        }
    }
    
    //MARK: 응답값 X
    func requestVoid(_ endPoint: E) async throws {
        GTLogger.shared.networkRequest("N/Start: noRes, noToken")
        
        let response = await defaultSession.request(endPoint,
                                                    interceptor: Interceptor(interceptors: [GTInterceptor(type: .default)]))
            .validate(statusCode: 200..<300)
            .serializingData()
            .response
        
        try handleNoResponse(response, endPoint: endPoint)
    }
    
    /// 멀티파트폼
    func requestMultipart<T: ResponseData>(_ endPoint: E) async throws -> T {
        guard case .multipartData(let config) = endPoint.requestType else {
            throw GLError.typeError("Multipart 메서드에 잘못된 requestType이 전달됨")
        }
        
        let request = defaultSession.upload(
            multipartFormData: { formData in
                for (index, data) in config.files.enumerated() {
                    let fileName = "file\(index).\(config.fileExtension)"
                    formData.append(
                        data,
                        withName: config.fieldName,
                        fileName: fileName,
                        mimeType: config.mimeType
                    )
                }
            },
            to: endPoint.baseURL + endPoint.path,
            method: endPoint.method,
            interceptor: Interceptor(interceptors: [GTInterceptor(type: .multipart)])
        )
        
        let response = await request
            .validate(statusCode: 200..<300)
            .serializingDecodable(T.self, decoder: endPoint.decoder)
            .response
        
        return try handleResponse(response, endPoint: endPoint)
    }
}
