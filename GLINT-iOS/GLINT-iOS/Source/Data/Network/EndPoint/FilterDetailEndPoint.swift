//
//  FilterDetailEndPoint.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import Foundation

import Alamofire

enum FilterDetailEndPoint {
    case filterDetail(filterId: String)
    case deleteFilter(filterID: String)
}

extension FilterDetailEndPoint: EndPoint {
    var utilPath: String {
        switch self {
        case .filterDetail, .deleteFilter:
            return "v1/filters/"
        }
    }
    
    var path: String {
        switch self {
        case .filterDetail(let filterId), .deleteFilter(let filterId):
            return utilPath + "\(filterId)"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .filterDetail:
            return .get
        case .deleteFilter:
            return .delete
        }
    }
    
    var requestType: RequestType {
        switch self {
        case .filterDetail, .deleteFilter:
            return .none
        }
    }
    
}
