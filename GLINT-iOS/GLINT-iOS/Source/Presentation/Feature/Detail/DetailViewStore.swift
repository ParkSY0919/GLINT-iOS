//
//  DetailViewStore.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import SwiftUI

import iamport_ios

struct DetailViewState {
    var filterData: FilterEntity?
    var userInfoData: ProfileEntity?
    var photoMetaData: PhotoMetadataEntity?
    var filterPresetsData: FilterValuesEntity?
    
    var address: String?
    var navTitle: String = ""
    
    var isLiked: Bool? = false
    var isLoading: Bool = true
    var errorMessage: String?
    var isPurchased: Bool = false
    var sliderPosition: CGFloat = 0.5
    var showPaymentSheet: Bool = false
    var createOrderCode: String?
    var showPaymentAlert: Bool = false
    var purchaseInfo: (String?, String?)
}

enum DetailViewAction {
    case viewAppeared(id: String)
    case sliderPositionChanged(CGFloat)
    case backButtonTapped
    case sendMessageTapped
    case likeButtonTapped
    case retryButtonTapped
    case purchaseButtonTapped
    case paymentCompleted(IamportResponse?)
    case dismissPaymentSheet
    case paymentAlertDismissed
}

@MainActor
@Observable
final class DetailViewStore {
    private(set) var state = DetailViewState()
    private let useCase: DetailViewUseCase
    private let router: NavigationRouter<MainTabRoute>
    private var filterId: String = ""
    
    init(useCase: DetailViewUseCase, router: NavigationRouter<MainTabRoute>) {
        self.useCase = useCase
        self.router = router
    }
    
    func send(_ action: DetailViewAction) {
        switch action {
        case .viewAppeared(let id):
            handleViewAppeared(id: id)
            
        case .sliderPositionChanged(let position):
            handleSliderPositionChanged(position: position)
            
        case .backButtonTapped:
            router.pop()
            
        case .purchaseButtonTapped:
            handlePurchaseButtonTapped()
            
        case .likeButtonTapped:
            handleLikeTapped()
            
        case .sendMessageTapped:
            handleSendMessageTapped()
            
        case .retryButtonTapped:
            handleRetryButtonTapped()
            
        case .paymentCompleted(let response):
            Task {
                await handlePaymentCompleted(response: response)
            }
            
        case .dismissPaymentSheet:
            handleDismissPaymentSheet()
            
        case .paymentAlertDismissed:
            handlePaymentAlertDismissed()
        }
    }
}

@MainActor
private extension DetailViewStore {
    /// 뷰가 나타났을 때의 처리
    func handleViewAppeared(id: String) {
        filterId = id
        loadFilterDetail()
    }
    
    /// 슬라이더 위치 변경 처리
    func handleSliderPositionChanged(position: CGFloat) {
        state.sliderPosition = max(0.0, min(1.0, position))
    }
    
    /// 구매 버튼 탭 처리
    func handlePurchaseButtonTapped() {
        print("구매 버튼 탭됨")
        state.isLoading = true
        state.errorMessage = nil
        
        Task {
            do {
                state.isLoading = true
                guard let filterID = state.filterData?.id,
                      let filterPrice = state.filterData?.price else {
                    state.isLoading = false
                    state.errorMessage = "필터 정보를 가져오지 못했습니다."
                    return
                }
                state.createOrderCode = try await useCase.createOrder(filterID, filterPrice)
                state.showPaymentSheet = true  // 결제 화면 표시
                state.isLoading = false
            } catch {
                state.isLoading = false
                state.errorMessage = error.localizedDescription
            }
        }
        state.isLoading = false
    }
    
    /// 포트원 결제 성공 이후
    func handlePaymentCompleted(response: IamportResponse?) async {
        if let response, response.success == true {
            await isValidationReceipt(response.imp_uid)
            
            state.isPurchased = true
            state.showPaymentSheet = false
        } else {
            GTLogger.shared.w("결제 실패: \(response?.error_msg ?? "알 수 없는 오류")")
            state.errorMessage = response?.error_msg ?? "결제에 실패했습니다."
            
            state.showPaymentSheet = false
        }
    }
    
    func isValidationReceipt(_ impUid: String?) async {
        GTLogger.shared.i("결제 성공 후 추가 로직 실행 시작!")
        guard let impUid else { return }
        
        Task {
            do {
                //결제 영수증 유효성 검증
                let validateOrderCode = try await useCase.paymentValidation(impUid)
                //결제 영수증 조회
                state.purchaseInfo = try await useCase.paymentInfo(validateOrderCode)
                state.showPaymentAlert = true
            } catch {
                state.isLoading = false
                state.errorMessage = error.localizedDescription
            }
        }
    }
    
    func handleDismissPaymentSheet() {
        state.showPaymentSheet = false
    }
    
    /// 찜 버튼 탭 처리
    func handleLikeTapped() {
        print("찜 버튼 탭됨")
        
        Task {
            do {
                state.isLoading = true
                state.errorMessage = nil
                
                guard let filterID = state.filterData?.id, let isLiked = state.isLiked else {
                    state.isLoading = false
                    state.errorMessage = "필터 정보를 가져오지 못했습니다."
                    return
                }
                let newLikedState = !isLiked
                state.isLiked = try await useCase.likeFilter(filterID, newLikedState)
                state.isLoading = false
            } catch {
                state.isLoading = false
                state.errorMessage = error.localizedDescription
            }
        }
    }
    
    /// 메시지 보내기 버튼 탭 처리
    func handleSendMessageTapped() {
        print("메시지 보내기 버튼 탭됨")
        // TODO: 메시지 화면으로 네비게이션
    }
    
    /// 재시도 버튼 탭 처리
    func handleRetryButtonTapped() {
        state.errorMessage = nil
        state.isLoading = true
        loadFilterDetail()
    }
    
    /// 필터 상세 정보 로드
    func loadFilterDetail() {
        state.isLoading = true
        state.errorMessage = nil
        
        Task {
            do {
                let (filter, profile, metadata, presets) = try await useCase.filterDetail(filterId)
                
                state = await DetailViewState(
                    filterData: filter,
                    userInfoData: profile,
                    photoMetaData: metadata,
                    filterPresetsData: presets,
                    address: metadata?.getKoreanAddress(),
                    navTitle: filter.title ?? "",
                    isLiked: filter.isLiked ?? false,
                    isLoading: false,
                    isPurchased: filter.isDownloaded ?? false
                )
            } catch {
                state.isLoading = false
                state.errorMessage = error.localizedDescription
            }
        }
    }
    
    func handlePaymentAlertDismissed() {
        state.showPaymentAlert = false
    }
}

extension DetailViewStore {
    func createPaymentData() -> IamportPayment {
        guard let orderCode = state.createOrderCode,
              let filterData = state.filterData else {
            fatalError("결제 데이터가 없습니다")
        }
        
        return IamportPayment(
            pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
            merchant_uid: orderCode,
            amount: "\(filterData.price ?? 0)"
        ).then {
            $0.pay_method = PayMethod.card.rawValue
            $0.name = filterData.title
            $0.buyer_name = state.userInfoData?.nick ?? "미공개"
            $0.app_scheme = "sesac"
        }
    }
}
