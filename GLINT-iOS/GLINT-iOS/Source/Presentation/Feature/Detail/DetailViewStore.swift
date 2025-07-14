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
    var isMyPost: Bool?
    
    var address: String?
    var navTitle: String = ""
    
    var isLiked: Bool? = false
    var isLoading: Bool = false
    var errorMessage: String?
    var isPurchased: Bool = false
    var sliderPosition: CGFloat = 0.5
    var showPaymentSheet: Bool = false
    var createOrderCode: String?
    var showDeleteAlert: Bool = false
    var showPaymentAlert: Bool = false
    var purchaseInfo: (String?, String?)
}

enum DetailViewAction {
    case viewAppeared(id: String)
    case sliderPositionChanged(CGFloat)
    case backButtonTapped
    case sendMessageTapped
    case likeButtonTapped
    case editButtonTapped
    case deleteButtonTapped
    case retryButtonTapped
    case purchaseButtonTapped
    case paymentCompleted(IamportResponse?)
    case dismissPaymentSheet
    case paymentAlertDismissed
    case deleteAlertDismissed
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
            
        case .editButtonTapped:
            handleEditTapped()
            
        case .deleteButtonTapped:
            handleDeleteTapped()
            
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
            
        case .deleteAlertDismissed:
            handleDeleteAlertDismissed()
        }
    }
}

@MainActor
private extension DetailViewStore {
    func isReturningFromChat() -> Bool {
        // 네비게이션 스택에 chat route가 있는지 확인
        return router.path.contains { route in
            if case .chat = route { return true }
            return false
        }
    }
    
    /// 뷰가 나타났을 때의 처리
    func handleViewAppeared(id: String) {
        // 같은 ID이고 ChatView에서 돌아온 경우라면 데이터 새로고침 건너뛰기
        if filterId == id && state.filterData != nil && isReturningFromChat() {
            return
        }
        
        filterId = id
        loadFilterDetail()
    }
    
    /// 슬라이더 위치 변경 처리
    func handleSliderPositionChanged(position: CGFloat) {
        state.sliderPosition = max(0.0, min(1.0, position))
    }
    
    /// 구매 버튼 탭 처리
    func handlePurchaseButtonTapped() {
        print(Strings.Detail.Log.purchaseButtonTapped)
        state.isLoading = true
        state.errorMessage = nil
        
        Task {
            do {
                state.isLoading = true
                guard let filterID = state.filterData?.id,
                      let filterPrice = state.filterData?.price else {
                    state.isLoading = false
                    state.errorMessage = Strings.Detail.Error.filterInfoNotFound
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
            GTLogger.shared.w("\(Strings.Detail.Log.paymentFailed): \(response?.error_msg ?? Strings.Detail.Error.unknownError)")
            state.errorMessage = response?.error_msg ?? Strings.Detail.Error.paymentFailed
            
            state.showPaymentSheet = false
        }
    }
    
    func isValidationReceipt(_ impUid: String?) async {
        GTLogger.shared.i(Strings.Detail.Log.paymentSuccessStart)
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
        print(Strings.Detail.Log.likeButtonTapped)
        
        Task {
            do {
                state.isLoading = true
                state.errorMessage = nil
                
                guard let filterID = state.filterData?.id, let isLiked = state.isLiked else {
                    state.isLoading = false
                    state.errorMessage = Strings.Detail.Error.filterInfoNotFound
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
    
    ///삭제하기 버튼 탭
    func handleDeleteTapped() {
        print(Strings.Detail.Log.deleteButtonTapped)
        
        Task {
            do {
                state.isLoading = true
                state.errorMessage = nil
                
                guard let filterID = state.filterData?.id, let isMyPost = state.isMyPost,
                isMyPost == true else {
                    state.isLoading = false
                    state.errorMessage = Strings.Detail.Error.filterInfoNotFound
                    return
                }
                print(try await useCase.deleteFilter(filterID)) //에러 안 뜨면 성공한 것.
                state.isLoading = false
                router.pop()
            } catch {
                state.isLoading = false
                state.errorMessage = error.localizedDescription
            }
        }
    }
    
    /// 메시지 보내기 버튼 탭 처리
    func handleSendMessageTapped() {
        print(Strings.Detail.Log.messageButtonTapped)
        
        // 작가 정보가 있으면 채팅 화면으로 이동
        guard let userID = state.userInfoData?.userID else {
            state.errorMessage = "작가 정보를 찾을 수 없습니다."
            return
        }
        Task {
            do {
                state.isLoading = true
                state.errorMessage = nil
                
                let roomID = try await useCase.createChatRoom(userID)
                
                state.isLoading = false
                guard let nick = state.userInfoData?.nick,
                      let userID = state.userInfoData?.userID else {
                    print("Chat 전환 실패~")
                    return
                }
                router.push(.chat(roomID: roomID, nick: nick, userID: userID))
            } catch {
                state.isLoading = false
                state.errorMessage = error.localizedDescription
            }
        }
    }
    
    /// 수정하기 버튼 탭 처리
    func handleEditTapped() {
        print(Strings.Detail.Log.editButtonTapped)
        // TODO: 수정 화면으로 네비게이션
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
                let (filter, profile, metadata, presets, isMyPost) = try await useCase.filterDetail(filterId)
                
                state = await DetailViewState(
                    filterData: filter,
                    userInfoData: profile,
                    photoMetaData: metadata,
                    filterPresetsData: presets,
                    isMyPost: isMyPost,
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
    
    func handleDeleteAlertDismissed() {
        state.showDeleteAlert = false
    }
}

extension DetailViewStore {
    func createPaymentData() -> IamportPayment {
        guard let orderCode = state.createOrderCode,
              let filterData = state.filterData else {
            fatalError(Strings.Detail.Error.paymentDataMissing)
        }
        
        return IamportPayment(
            pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
            merchant_uid: orderCode,
            amount: "\(filterData.price ?? 0)"
        ).then {
            $0.pay_method = PayMethod.card.rawValue
            $0.name = filterData.title
            $0.buyer_name = state.userInfoData?.nick ?? Strings.Detail.unknownBuyer
            $0.app_scheme = "sesac"
        }
    }
}
