//
//  NetworkServiceInterface.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/4/25.
//

import Foundation

//TODO: 추후 EndPoint 분리해야 클린아키텍처 완성
// MARK: - NetworkServiceInterface
protocol NetworkServiceInterface {
    associatedtype E: EndPoint
    
    // 토큰 포함 요청
    static func requestAsync<T: ResponseData>(_ endPoint: E) async throws -> T
    static func requestAsync(_ endPoint: E) async throws
    
    // 토큰 없이 요청 (adaptable 파라미터 추가)
    static func requestNonToken<T: ResponseData>(_ endPoint: E) async throws -> T
    static func requestNonToken(_ endPoint: E) async throws
}
