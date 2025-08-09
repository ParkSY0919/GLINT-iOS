//
//  RecommendationEndPoint.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/29/25.
//

import Foundation

import Alamofire

enum RecommendationEndPoint {
    case todayAuthor
    case todayFilter
    case hotTrend
    case banner
}

extension RecommendationEndPoint: EndPoint {
    var utilPath: String {
        switch self {
        case .todayAuthor:
            "v1/users/"
        case .todayFilter:
            "v1/filters/"
        case .hotTrend:
            "v1/filters/"
        case .banner:
            "v1/banners/"
        }
    }
    
    var path: String {
        switch self {
        case .todayAuthor:
            return utilPath + "today-author"
        case .todayFilter:
            return utilPath + "today-filter"
        case .hotTrend:
            return utilPath + "hot-trend"
        case .banner:
            return utilPath + "main"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .todayAuthor, .todayFilter, .hotTrend, .banner:
            return .get
        }
    }
    
    var requestType: RequestType {
        switch self {
        case .todayAuthor, .todayFilter, .hotTrend, .banner:
            return .none
        }
    }
}
