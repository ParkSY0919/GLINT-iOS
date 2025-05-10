//
//  NetworkServiceProvider.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/9/25.
//

import Foundation
import Combine

/// 네트워크 서비스 프로토콜입니다.
protocol NetworkServiceProvider {
    func callRequest<T: TargetTypeProtocol, R: Decodable>(
        router: T,
        responseType: R.Type
    ) -> AnyPublisher<Result<R, T.ErrorType>, Never>
}
