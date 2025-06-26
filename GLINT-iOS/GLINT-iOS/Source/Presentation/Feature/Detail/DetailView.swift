//
//  DetailView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import SwiftUI
import MapKit

import NukeUI
import iamport_ios

struct DetailView: View {
//    @Environment(\.detailViewUseCase)
//    private var useCase
    //TODO: init형태로 바꾸기
    
    @Environment(\.openURL)
    private var openURL
    
    @State
    private var isLiked = false
    
    @State
    private var store: DetailViewStore
    
    let router: NavigationRouter<MainTabRoute>
    let id: String
        
    init(id: String, router: NavigationRouter<MainTabRoute>) {
        self.id = id
        self.router = router
        self._store = State(wrappedValue: DetailViewStore(useCase: .liveValue))
    }
    
    var body: some View {
        Group {
            if store.state.isLoading && !store.state.hasLoadedOnce {
                StateViewBuilder.loadingView()
            } else if let errorMessage = store.state.errorMessage, !store.state.hasLoadedOnce {
                StateViewBuilder.errorView(errorMessage: errorMessage) {
                    store.send(.retryButtonTapped)
                }
            } else {
                contentView
            }
        }
        .sheet(isPresented: Binding(
                    get: { store.state.showPaymentSheet },
                    set: { _ in store.send(.dismissPaymentSheet) }
        )) {
            IamportPaymentView(
                paymentData: store.createPaymentData(),
                onComplete: { response in
                    store.send(.paymentCompleted(response))
                }
            )
        }
        .navigationSetup(
            title: store.state.navTitle,
            onBackButtonTapped: { router.pop() }
        )
        .onAppear {
            store.send(.viewAppeared(id: id))
        }
        .onOpenURL { openURL in
            Iamport.shared.receivedURL(openURL)
        }
    }
}

// MARK: - Views
private extension DetailView {
    var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                FilterSectionView(
                    sliderPosition: .constant(store.state.sliderPosition),
                    originalImageURL: store.state.filterData?.original,
                    filteredImageURL: store.state.filterData?.filtered,
                    onSliderChanged: { position in
                        store.send(.sliderPositionChanged(position))
                    }
                )
                
                PriceSectionView(
                    price: store.state.filterData?.price ?? 0,
                    buyerCount: store.state.filterData?.buyerCount ?? 0,
                    likeCount: store.state.filterData?.likeCount ?? 0
                )
                
                MetaDataSectionView(
                    camera: store.state.photoMetaData?.camera,
                    
                    photoMetadataString: store.state.photoMetaData?.photoMetadataString ?? "정보 없음",
                    megapixelInfo: store.state.photoMetaData?.megapixelInfoString ?? "정보 없음",
                    address: store.state.address,
                    latitude: store.state.photoMetaData?.latitude,
                    longitude: store.state.photoMetaData?.longitude
                )
                
                FilterPresetsSectionView(
                    isPurchased: store.state.isPurchased,
                    filterPresetsData: store.state.filterPresetsData?.toStringArray()
                )
                
                PayButtonSectionView( 
                    isPurchased: store.state.isPurchased,
                    onPurchaseButtonTapped: {
                        store.send(.purchaseButtonTapped)
                    }
                )
                
                AuthorSectionView(
                    userInfo: store.state.userInfoData,
                    onTapMessageBtn: {
                        store.send(.sendMessageTapped)
                    }
                )
                
            }
        }
        .background(.gray100)
    }
}
