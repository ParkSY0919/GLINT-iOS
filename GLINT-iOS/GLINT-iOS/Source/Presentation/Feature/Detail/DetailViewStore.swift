//
//  DetailViewStore.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import SwiftUI

import iamport_ios

// MARK: - State
struct DetailViewState {
    var filterData: FilterModel?
    var userInfoData: UserInfoModel?
    var photoMetaData: PhotoMetadataModel?
    var filterPresetsData: FilterPresetsModel?
    
    var address: String?
    
    var isLoading: Bool = true
    var errorMessage: String?
    var hasLoadedOnce: Bool = false
    var isPurchased: Bool = false // 필터 구매 여부
    var sliderPosition: CGFloat = 0.5
    var showPaymentSheet: Bool = false
    var createOrderResult: CreateOrderEntity.Response?
}

// MARK: - Action
enum DetailViewAction {
    case viewAppeared(id: String)
    case sliderPositionChanged(CGFloat)
    case sendMessageTapped
    case retryButtonTapped
    case purchaseButtonTapped
    case paymentCompleted(IamportResponse?)
    case dismissPaymentSheet
}

@Observable
final class DetailViewStore {
    var state = DetailViewState()
    
    // 필터 ID
    private var filterId: String = ""
    
    /// 의존성 주입을 통한 초기화
    private let filterDetailUseCase: DetailViewUseCase
    private let orderUseCase: DetailViewUseCase
    private let paymentUseCase: DetailViewUseCase
    
    init(
        filterDetailUseCase: DetailViewUseCase,
        orderUseCase: DetailViewUseCase,
        paymentUseCase: DetailViewUseCase
    ) {
        self.filterDetailUseCase = filterDetailUseCase
        self.orderUseCase = orderUseCase
        self.paymentUseCase = paymentUseCase
    }
    
    /// - Parameter action: 처리할 액션
    @MainActor
    func send(_ action: DetailViewAction) {
        switch action {
        case .viewAppeared(let id):
            handleViewAppeared(id: id)
            
        case .sliderPositionChanged(let position):
            handleSliderPositionChanged(position: position)
            
        case .purchaseButtonTapped:
            handlePurchaseButtonTapped()
            
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
                let requestEntity = CreateOrderEntity.Request(filter_id: state.filterData?.filterID ?? "", total_price: state.filterData?.price ?? 0)
                state.createOrderResult = try await orderUseCase.createOrder(requestEntity)
                
                print("response: \(String(describing: state.createOrderResult))")
                
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
        
        if let imp_uid {
            let request = PaymentValidationEntity.Request(imp_uid: imp_uid)
            let response = try? await paymentUseCase.paymentValidation(request)
        }
        
        GTLogger.shared.i("결제 성공 후 추가 로직 실행 완료!")
    }
    
    func handleDismissPaymentSheet() {
        state.showPaymentSheet = false
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
                async let filterDetail = filterDetailUseCase.filterDetail(filterId)
                let filterData = try await filterDetail
                
                state.filterData = filterData.filter
                state.userInfoData = filterData.author
                state.photoMetaData = filterData.photoMetadata
                state.filterPresetsData = filterData.filterValues
                state.address = await filterData.photoMetadata.getKoreanAddress()
                
                state.isPurchased = filterData.filter.isDownloaded ?? false
                state.isLoading = false
                state.hasLoadedOnce = true
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
