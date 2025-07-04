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
    
    enum Detail {
        // MARK: - UI Text
        static let purchaseResult = "구매 결과"
        static let noInfo = "정보 없음"
        static let filterPresets = "Filter Presets"
        static let lutLabel = "LUT"
        static let purchaseCompleted = "구매완료"
        static let payNow = "결제하기"
        static let unknownBuyer = "미공개"
        static let coin = "Coin"
        static let download = "다운로드"
        static let like = "찜하기"
        static let bef = "Before"
        static let aft = "After"
        
        // MARK: - Error Messages
        enum Error {
            static let filterInfoNotFound = "필터 정보를 가져오지 못했습니다."
            static let paymentFailed = "결제에 실패했습니다."
            static let unknownError = "알 수 없는 오류"
            static let paymentDataMissing = "결제 데이터가 없습니다"
        }
        
        // MARK: - Log Messages
        enum Log {
            static let purchaseButtonTapped = "구매 버튼 탭됨"
            static let likeButtonTapped = "찜 버튼 탭됨"
            static let messageButtonTapped = "메시지 보내기 버튼 탭됨"
            static let paymentFailed = "결제 실패"
            static let paymentSuccessStart = "결제 성공 후 추가 로직 실행 시작!"
        }
        
        // MARK: - Purchase Messages
        enum Purchase {
            static let lockedFilterMessage = "결제 후 필요한 유료 필터입니다"
            static let purchaseSuccessMessage = "필터 구매를 성공하였습니다."
            static let orderNumberPrefix = "주문번호: "
            static let slpIdentiCode = "imp14511373"
        }
    }
    
    enum Make {
        // MARK: - UI Text
        static let title = "MAKE"
        static let registrationResult = "등록 결과"
        static let titlePhotoRegistration = "대표 사진 등록"
        static let changePhoto = "사진 변경하기"
        static let editPhoto = "수정하기"
        static let category = "카테고리"
        static let noInfo = "정보 없음"
        
        // MARK: - Success Messages
        static let filterCreationSuccess = "필터 생성을 성공하였습니다."
        
        // MARK: - Error Messages
        enum Error {
            static let filterValuesFailed = "filterValues 가져오기 실패"
            static let filterSaveFailed = "Filter save failed"
        }
        
        // MARK: - Log Messages
        enum Log {
            static let imageChangeRequested = "Image change requested"
            static let filterValuesNotFound = "없지롱"
        }
    }
    
}
