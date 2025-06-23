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
    @Environment(\.openURL)
    private var openURL
    
    let id: String
    let router: NavigationRouter<MainTabRoute>
    
    @State
    private var store = DetailViewStore(
        filterDetailUseCase: .liveValue,
        orderUseCase: .liveValue,
        paymentUseCase: .liveValue
    )
    
    @State
    private var isLiked = false
    
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
        .sheet(isPresented: $store.state.showPaymentSheet) {
            if let orderData = store.state.createOrderResult,
               let filterData = store.state.filterData {
                IamportPaymentView(
                    orderData: orderData,
                    filterData: filterData,
                    onComplete: { response in
                        store.send(.paymentCompleted(response))
                    }
                )
            }
        }
        .navigationTitle(store.state.filterData?.title ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    router.pop()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray75)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                LikeButton(isLiked: $isLiked) {
                    //                    store.send(.likeButtonTapped)
                }
            }
        }
        .onAppear {
            store.send(.viewAppeared(id: id))
            setupNavigationAppearance()
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
                    onSendMessageTapped: {
                        store.send(.sendMessageTapped)
                    }
                )
            }
        }
        .background(.gray100)
    }
    
    func setupNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.gray100)
        if let pointFont = UIFont(name: "TTHakgyoansimMulgyeolB", size: 16) {
            appearance.titleTextAttributes = [
                .font: pointFont,
                .foregroundColor: UIColor(Color.gray0)
            ]
        }
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
