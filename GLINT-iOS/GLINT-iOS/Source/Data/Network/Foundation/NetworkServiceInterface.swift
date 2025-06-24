//
//  NetworkServiceInterface.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/24/25.
//

import Foundation

protocol NetworkServiceInterface {
    associatedtype E: EndPoint
    
    func request<T: ResponseData>(_ endPoint: E) async throws -> T
    func requestVoid(_ endPoint: E) async throws
    func requestMultipart<T: ResponseData>(_ endPoint: E) async throws -> T
}
