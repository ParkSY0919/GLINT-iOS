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
    func requestAsync<T: EndPoint, R: Decodable>(target: T, responseType: R.Type, interceptor: RequestInterceptor?) async throws -> R
    func requestAsync<T: EndPoint>(target: T, interceptor: RequestInterceptor?) async throws
    
    // 인증 없이 요청 (로그인 등)
    func requestWithoutAuth<T: EndPoint, R: Decodable>(target: T, responseType: R.Type) async throws -> R
    func requestWithoutAuth<T: EndPoint>(target: T) async throws
}
