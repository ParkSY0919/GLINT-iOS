//
//  MakeView.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI

struct MakeView: View {
    let store: MakeViewStore
    
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
        .navigationTitle("MAKE")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    store.send(.saveButtonTapped)
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray0)
                }
            }
        }
        .navigationDestination(isPresented: Binding(
            get: { store.state.showingEditView },
            set: { _ in store.send(.editViewDismissed) }
        )) {
            if let image = store.state.selectedImage {
                EditView(
                    originalImage: image,
                    onSave: { filteredImage in
                        store.send(.filteredImageReceived(filteredImage))
                    },
                    onBack: {
                        store.send(.editViewDismissed)
                    }
                )
            }
        }
    }
}

// MARK: - Views
private extension MakeView {
    var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // 1. FilterName Section
                GLTextField(
                    type: .filterName,
                    text: Binding(
                        get: { store.state.filterName },
                        set: { store.send(.filterNameChanged($0)) }
                    )
                )
                .padding(.horizontal, 20)
                
                // 2. Category Section
                CategorySectionView(
                    selectedCategory: Binding(
                        get: { store.state.selectedCategory },
                        set: { if let category = $0 { store.send(.categorySelected(category)) } }
                    ),
                    onCategorySelected: { category in
                        store.send(.categorySelected(category))
                    }
                )
                .padding(.horizontal, 20)
                
                // 3. TitlePicture Section
                TitlePictureSectionView(
                    selectedImage: store.state.selectedImage,
                    imageMetaData: store.state.imageMetaData,
                    address: store.state.address,
                    onImageSelected: { image, metadata  in
                        store.send(.imageSelected(image, metadata))
                    },
                    onImageChangeRequested: {
                        store.send(.imageChangeRequested)
                    },
                    onEditButtonTapped: {
                        store.send(.editButtonTapped)
                    }
                )
                
                // 4. Introduce Section
                GLTextField(
                    type: .introduce,
                    text: Binding(
                        get: { store.state.introduce },
                        set: { store.send(.introduceChanged($0)) }
                    )
                )
                .padding(.horizontal, 20)
                
                // 5. Price Section
                GLTextField(
                    type: .price,
                    text: Binding(
                        get: { store.state.price },
                        set: { store.send(.priceChanged($0)) }
                    )
                )
                .padding(.horizontal, 20)
                
                // 하단 여백
                Spacer()
                    .frame(height: 100)
            }
        }
        .background(.gray100)
        .detectScroll()
        .contentShape(Rectangle())
        .onTapGesture {
            hideKeyboard()
        }
        
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
} 
 
