//
//  DetailViewUseCase+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import SwiftUI

//TODO: LoginView와 같도록 수정
extension DetailViewUseCase {
    static let liveValue: DetailViewUseCase = {
        let repo: FilterDetailRepository = .liveValue
        let orderRepo: OrderRepository = .value
        
        return DetailViewUseCase (
            filterDetail: { filterID in
                return try await repo.filterDetail(filterID)
            },
            
            createOrder: { request in
                return try await orderRepo.createOrder(request)
            },
            
            infoOrder: {
                return try await orderRepo.infoOrder()
            }
        )
    }()
    
}

struct DetailViewUseCaseKey: EnvironmentKey {
    static let defaultValue: DetailViewUseCase = .liveValue
}

extension EnvironmentValues {
    var DetailViewUseCase: DetailViewUseCase {
        get { self[DetailViewUseCaseKey.self] }
        set { self[DetailViewUseCaseKey.self] = newValue }
    }
}
