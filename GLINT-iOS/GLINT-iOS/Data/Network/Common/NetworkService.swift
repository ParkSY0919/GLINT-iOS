//
//  NetworkService.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/9/25.
//

import Combine
import Alamofire

final class NetworkService: NetworkServiceProvider {
    static let shared = NetworkService()
    
    private init() { }
    
    func callRequest<T: TargetTypeProtocol, R: Decodable>(
        router: T,
        responseType: R.Type
    ) -> AnyPublisher<Result<R, T.ErrorType>, Never> {
        return Future<Result<R, T.ErrorType>, Never> { promise in
            AF.request(router)
                .validate(statusCode: 200...299)
                .responseDecodable(of: R.self) { response in
                    switch response.result {
                    case .success(let value):
                        promise(.success(.success(value)))
                    case .failure(let error):
                        let error = router.throwError(error)
                        promise(.success(.failure(error)))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
}
