//
//  FilterEndPoint.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/10/25.
//

import Foundation

import Alamofire

enum FilterEndPoint {
    case filterFiles(files: FilesEntity.Request)
}

extension FilterEndPoint: EndPoint {
    var utilPath: String {
        switch self {
        case .filterFiles:
            return "v1/filters/"
        }
    }
    
    var path: String {
        switch self {
        case .filterFiles:
            return utilPath + "files"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .filterFiles:
            return .post
        }
    }
    
    var requestType: RequestType {
        switch self {
        case .filterFiles(let files):
            return .multipartData(MultipartConfig(files: files.files))
        }
    }
    
}
