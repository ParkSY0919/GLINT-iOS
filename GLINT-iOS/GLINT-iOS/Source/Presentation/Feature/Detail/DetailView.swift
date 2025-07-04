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
    @Environment(DetailViewStore.self)
    private var store
    @Environment(\.openURL)
    private var openURL
    
    let id: String
        
    init(id: String) {
        self.id = id
    }
    
    var body: some View {
        Group {
            if store.state.isLoading {
                StateViewBuilder.loadingView()
            } else if let errorMessage = store.state.errorMessage {
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
            isLiked: store.state.isLiked,
            onBackButtonTapped: { store.send(.backButtonTapped) },
            onLikeButtonTapped: { store.send(.likeButtonTapped) }
        )
        .conditionalAlert(
            title: Strings.Detail.purchaseResult,
            isPresented: Binding(
                get: { store.state.showPaymentAlert },
                set: { _ in store.send(.paymentAlertDismissed) }
            )
        ) {
            if let merchantUid = store.state.purchaseInfo.1 {
                let productName = store.state.purchaseInfo.0
                    ?? store.state.filterData?.title
                    ?? "noneTitle"
                
                Text("""
                    '\(productName)' \(Strings.Detail.Purchase.purchaseSuccessMessage)
                    \(Strings.Detail.Purchase.orderNumberPrefix)\(merchantUid)
                    """)
            }
        }
        .onViewDidLoad(perform: {
            store.send(.viewAppeared(id: id))
        })
        .onOpenURL { openURL in
            Iamport.shared.receivedURL(openURL)
        }
    }
}

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
                    
                    photoMetadataString: store.state.photoMetaData?.photoMetadataString ?? Strings.Detail.noInfo,
                    megapixelInfo: store.state.photoMetaData?.megapixelInfoString ?? Strings.Detail.noInfo,
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
