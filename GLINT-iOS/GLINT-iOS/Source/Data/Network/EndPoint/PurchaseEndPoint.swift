//
//  PurchaseEndPoint.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/11/25.
//

import Foundation

import Alamofire
//TODO: 추후 프로퍼티 2개 이하 request 방식 변경
enum PurchaseEndPoint {
    case createOrder(CreateOrderRequest)
    case infoOrder
    case paymentValidation(PaymentValidationRequest)
    case paymentInfo(PaymentInfoRequest)
}

extension PurchaseEndPoint: EndPoint {
    var utilPath: String {
        switch self {
        case .createOrder, .infoOrder:
            return ""
        case .paymentValidation, .paymentInfo:
            return "v1/payments/"
        }
    }
    
    var path: String {
        switch self {
        case .createOrder, .infoOrder:
            return "v1/orders"
        case .paymentValidation:
            return utilPath + "validation"
        case .paymentInfo(let request):
            return utilPath + "\(request.orderCode)"
        }
        
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .createOrder, .paymentValidation:
            return .post
        case .infoOrder, .paymentInfo:
            return .get
        }
    }
    
    var requestType: RequestType {
        switch self {
        case .createOrder(let request):
            return .bodyEncodable(request)
        case .infoOrder, .paymentInfo:
            return .none
        case .paymentValidation(let request):
            return .bodyEncodable(request)
        }
    }
}
