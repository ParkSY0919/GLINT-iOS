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
    var photoMetaData: PhotoMetadata?
    var filterPresetsData: FilterPresetsEntity?
    
    var address: String?
    var navTitle: String = ""
    
    var isLiked: Bool? = false
    var isLoading: Bool = true
    var errorMessage: String?
    var hasLoadedOnce: Bool = false
    var isPurchased: Bool = false // 필터 구매 여부
    var sliderPosition: CGFloat = 0.5
    var showPaymentSheet: Bool = false
    var createOrderResult: CreateOrderResponse?
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
}

@MainActor
@Observable
final class DetailViewStore {
    private(set) var state = DetailViewState()
    
    private let useCase: DetailViewUseCase
    private let router: NavigationRouter<MainTabRoute>
    
    // 필터 ID
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
        }
    }
}

// MARK: - Private Action Handlers
@MainActor
private extension DetailViewStore {
    /// 뷰가 나타났을 때의 처리
    func handleViewAppeared(id: String) {
        filterId = id
        if !state.hasLoadedOnce {
            loadFilterDetail()
        }
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
                state.createOrderResult = try await useCase.createOrder(filterID, filterPrice)
                state.showPaymentSheet = true  // 결제 화면 표시
                state.isLoading = false
            } catch {
                state.isLoading = false
                state.errorMessage = error.localizedDescription
            }
        }
        state.isLoading = false
    }
    
    func handlePaymentCompleted(response: IamportResponse?) async {
        if let response, response.success == true {
            GTLogger.shared.i("결제 성공: \(response.imp_uid ?? "")")
            
            await executeAfterSuccessfulPayment(imp_uid: response.imp_uid)
            
            // 모든 로직 완료 후 화면 닫기
            state.isPurchased = true
            state.showPaymentSheet = false
            
        } else {
            GTLogger.shared.w("결제 실패: \(response?.error_msg ?? "알 수 없는 오류")")
            state.errorMessage = response?.error_msg ?? "결제에 실패했습니다."
            
            // 실패 시 즉시 화면 닫기
            state.showPaymentSheet = false
        }
    }
    
    private func executeAfterSuccessfulPayment(imp_uid: String?) async {
        GTLogger.shared.i("결제 성공 후 추가 로직 실행 시작!")
        guard let imp_uid else {
            return
        }
        
        Task {
            do {
                let response = try await useCase.paymentValidation(imp_uid)
                
                print(try await useCase.paymentInfo(response.orderItem.orderCode))
            } catch {
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                // 에러가 발생해도 hasLoadedOnce는 true로 유지 (이전 데이터 보존)
                if !state.hasLoadedOnce {
                    state.hasLoadedOnce = true
                }
            }
        }
        
        GTLogger.shared.i("결제 성공 후 추가 로직 실행 완료!")
    }
    
    func handleDismissPaymentSheet() {
        state.showPaymentSheet = false
    }
    
    /// 찜 버튼 탭 처리
    func handleLikeTapped() {
        print("찜 버튼 탭됨")
        state.isLoading = true
        state.errorMessage = nil
        
        Task {
            do {
                state.isLoading = true
                guard let filterID = state.filterData?.id, let isLiked = state.isLiked else {
                    state.isLoading = false
                    state.errorMessage = "필터 정보를 가져오지 못했습니다."
                    return
                }
                let newLikedState = !isLiked
                state.isLiked = try await useCase.likeFilter(filterID, newLikedState).likeStatus
                state.isLoading = false
            } catch {
                state.isLoading = false
                state.errorMessage = error.localizedDescription
            }
        }
        state.isLoading = false
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
                    hasLoadedOnce: true,
                    isPurchased: filter.isDownloaded ?? false
                )
            } catch {
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                if !state.hasLoadedOnce {
                    state.hasLoadedOnce = true
                }
            }
        }
    }
}

@MainActor
extension DetailViewStore {
    func createPaymentData() -> IamportPayment {
        guard let orderData = state.createOrderResult,
              let filterData = state.filterData else {
            fatalError("결제 데이터가 없습니다")
        }
        
        return IamportPayment(
            pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
            merchant_uid: orderData.orderCode,
            amount: "\(filterData.price ?? 0)"
        ).then {
            $0.pay_method = PayMethod.card.rawValue
            $0.name = filterData.title
            $0.buyer_name = "박신영" //추후 사용자 nick
            $0.app_scheme = "sesac"
        }
    }
}
