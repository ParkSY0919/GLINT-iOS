//
//  StringLiterals.swift
//  GLINT-iOS
//
//  Created by 박신영 on 5/10/25.
//

import Foundation

typealias Strings = StringLiterals

enum StringLiterals {}

extension Strings {
    
    enum Login {
        // MARK: - UI Text
        static let title = "Login"
        static let signIn = "Sign in"
        static let signUp = "회원가입"
        static let emailLabel = "Email"
        static let passwordLabel = "Password"
        static let emailPlaceholder = "Enter your email"
        static let passwordPlaceholder = "Enter your password"
        
        // MARK: - Error Messages
        enum Error {
            static let emailValidation = "유효한 이메일을 입력해주세요"
            static let passwordValidation = "8자 이상, 특수문자를 포함해주세요"
            static let inputValidation = "입력 정보를 확인해주세요."
            static let emptyFields = "이메일과 비밀번호를 모두 입력해주세요."
            static let emptyLoginFields = "이메일과 비밀번호를 입력해주세요."
            static let signUpFailure = "회원가입 실패"
            static let loginFailure = "로그인 실패"
            static let appleLoginFailure = "Apple 로그인 실패"
            static let emailCheckFailure = "이메일 검사 실패"
        }
        
        // MARK: - Log Messages
        enum Log {
            static let emailCheckSuccess = "서버 이메일 유효성 검사 성공"
            static let emailCheckFailure = "서버 이메일 유효성 검사 실패"
            static let kakaoLoginTapped = "Kakao 로그인 버튼 탭됨"
        }
    }
    
    enum Main {
        // MARK: - UI Text
        static let todayFilterIntro = "오늘의 필터 소개"
        static let tryFilter = "사용해보기"
        static let hotTrend = "핫 트렌드"
        static let todayArtistIntro = "오늘의 작가 소개"
        
        // MARK: - Error Messages
        enum Error {
            static let todayFilterLoadFailed = "오늘의 필터를 불러올 수 없습니다"
            static let hotTrendLoadFailed = "핫 트렌드를 불러올 수 없습니다."
            static let artistInfoLoadFailed = "작가 정보를 불러올 수 없습니다"
            static let artistWorksLoadFailed = "대표 작품을 불러올 수 없습니다"
        }
        
        // MARK: - Log Messages
        enum Log {
            static let categorySelected = "selectedCategory"
            static let bannerTapped = "배너"
            static let bannerTappedSuffix = "탭됨"
        }
        
        // MARK: - Categories
        static let categories: [FilterCategoryItem] = [
            FilterCategoryItem(icon: Images.Main.food, name: "푸드"),
            FilterCategoryItem(icon: Images.Main.person, name: "인물"),
            FilterCategoryItem(icon: Images.Main.landscape, name: "풍경"),
            FilterCategoryItem(icon: Images.Main.nightscape, name: "야경"),
            FilterCategoryItem(icon: Images.Main.star, name: "별")
        ]
    }
    
}
