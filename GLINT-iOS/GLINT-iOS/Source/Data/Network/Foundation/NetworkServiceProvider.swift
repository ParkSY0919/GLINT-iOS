//
//  NetworkServiceProvider.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/9/25.
//

import Foundation
import Combine
import Alamofire


// MARK: - Network Service Provider 프로토콜
protocol NetworkServiceProvider {
    // 응답 바디가 있는 요청 (Decodable)
    func request<T: EndPoint, R: Decodable>(
        target: T,
        responseType: R.Type,
        interceptor: RequestInterceptor? // 인터셉터 추가
    ) -> AnyPublisher<R, T.ErrorType> // Result 대신 성공/실패 분리

    // 응답 바디가 없는 요청 (성공 여부만)
    func request<T: EndPoint>(
        target: T,
        interceptor: RequestInterceptor? // 인터셉터 추가
    ) -> AnyPublisher<Void, T.ErrorType> // Result 대신 성공/실패 분리
}
