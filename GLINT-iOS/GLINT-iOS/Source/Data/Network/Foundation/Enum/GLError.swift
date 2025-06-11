//
//  GLError.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/15/25.
//

import Alamofire

enum GLError: Error {
    case e401 //유효 x accessToken
    case e403 //user_id 조회 실패
    case e419 //accessToken 만료
    case e420 //SeSACKey 유효 x
    case e429 //정해진 api 호출 횟수 초과
    case e444 //비정상 api 호출
    case e500 //서버 에러
    case networkFailure(AFError)
    case retryFailed(AFError)
    case unknown(Error)
    case typeError(String)
}
