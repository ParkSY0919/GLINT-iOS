//
//  OrderEndPoint.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/11/25.
//

import Foundation

import Alamofire

enum OrderEndPoint {
    case createOrder(CreateOrderDTO.Request)
    case infoOrder
}

extension OrderEndPoint: EndPoint {
    var utilPath: String {
        return ""
    }
    
    var path: String {
        return "v1/orders"
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .createOrder(let request):
            return .post
        case .infoOrder:
            return .get
        }
    }
    
    var requestType: RequestType {
        switch self {
        case .createOrder(let request):
            return .bodyEncodable(request)
        case .infoOrder:
            return .none
        }
    }
    
    
}
