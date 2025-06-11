//
//  PaymentEndPoint.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/11/25.
//

import Foundation

import Alamofire

enum PaymentEndPoint {
    case paymentValidation(PaymentValidationDTO.Request)
}

extension PaymentEndPoint: EndPoint {
    var utilPath: String {
        return "v1/payments/"
    }
    
    var path: String {
        switch self {
        case .paymentValidation:
            return utilPath + "validation"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .paymentValidation:
            return .post
        }
    }
    
    var requestType: RequestType {
        switch self {
        case .paymentValidation(let request):
            return .bodyEncodable(request)
        }
    }
}
