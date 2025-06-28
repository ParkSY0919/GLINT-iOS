//
//  FilterEndPoint.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/10/25.
//

import Foundation

import Alamofire

enum FilterEndPoint {
    case filterFiles(files: [Data])
    case likeFilter(filterID: String, likeStatus: Bool)
}

extension FilterEndPoint: EndPoint {
    var utilPath: String {
        switch self {
        case .filterFiles, .likeFilter:
            return "v1/filters/"
        }
    }
    
    var path: String {
        switch self {
        case .filterFiles:
            return utilPath + "files"
        case .likeFilter(let id, _):
            return utilPath + "\(id)/like"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .filterFiles, .likeFilter:
            return .post
        }
    }
    
    var requestType: RequestType {
        switch self {
        case .filterFiles(let files):
            return .multipartData(MultipartConfig(files: files))
        case .likeFilter(_, let likeStatus):
            return .bodyEncodable(["like_status": likeStatus])
        }
    }
    
}
