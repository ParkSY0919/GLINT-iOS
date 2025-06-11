//
//  OrderRepository+.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/11/25.
//

import Foundation

extension OrderRepository {
    static let value: OrderRepository = {
        let provider = NetworkService<OrderEndPoint>()
        
        return OrderRepository(
            createOrder: { request in
                let request = request.toDTO()
                let response: CreateOrderDTO.Response = try await provider.requestAsync(.createOrder(request))
                return response.toEntity()
            },
            
            infoOrder: {
                let response: InfoOrderDTO.Response = try await provider.requestAsync(.infoOrder)
                return response.toEntity()
            }
        )
    }()
}
