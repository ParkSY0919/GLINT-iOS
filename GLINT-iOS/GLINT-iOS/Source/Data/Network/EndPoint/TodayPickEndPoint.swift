//
//  TodayPickEndPoint.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/29/25.
//

import Foundation

import Alamofire

enum TodayPickEndPoint {
    case todayAuthor
    case todayFilter
}

extension TodayPickEndPoint: EndPoint {
    var utilPath: String {
        switch self {
        case .todayAuthor:
            "v1/users/"
        case .todayFilter:
            "v1/filters/"
        }
    }
    
    var path: String {
        switch self {
        case .todayAuthor:
            return utilPath + "today-author"
        case .todayFilter:
            return utilPath + "today-filter"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .todayAuthor, .todayFilter:
            return .get
        }
    }
    
    var requestType: RequestType {
        switch self {
        case .todayAuthor, .todayFilter:
            return .none
        }
    }
}
