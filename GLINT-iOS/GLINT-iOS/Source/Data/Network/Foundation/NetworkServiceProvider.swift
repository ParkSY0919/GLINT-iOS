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
        interceptor: RequestInterceptor?
    ) -> AnyPublisher<R, T.ErrorType>

    // 응답 바디가 없는 요청 (성공 여부만)
    func request<T: EndPoint>(
        target: T,
        interceptor: RequestInterceptor?
    ) -> AnyPublisher<Void, T.ErrorType>
}
