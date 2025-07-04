//
//  MakeView.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI

struct MakeView: View {
    @Environment(MakeViewStore.self)
    private var store
    
    var body: some View {
        content
            .navigationSetup(title: Strings.Make.title, onRightButtonTapped: { store.send(.saveButtonTapped) })
            .conditionalAlert(
                title: Strings.Make.registrationResult,
                isPresented: Binding(
                    get: { store.state.showCreateAlert },
                    set: { _ in store.send(.createAlertDismissed) }
                )
            ) {
                if let filterTitle = store.state.createFilterTitle {
                    Text("'\(filterTitle)' \(Strings.Make.filterCreationSuccess)")
                }
            }
    }
    
    private var content: some View {
        Group {
            if store.state.isLoading {
                StateViewBuilder.loadingView()
            } else if let errorMessage = store.state.errorMessage {
                StateViewBuilder.errorView(errorMessage: errorMessage) {
                    store.send(.retryButtonTapped)
                }
            } else {
                makeContentView
            }
        }
    }
}

private extension MakeView {
    var makeContentView: some View {
        ScrollView(showsIndicators: false) {
            scrollViewContentSection
        }
        .background(.gray100)
        .detectScroll()
        .contentShape(Rectangle())
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    var scrollViewContentSection: some View {
        VStack(spacing: 0) {
            // FilterName Section
            textFieldSection(.filterName)
                .padding(.horizontal, 20)
            
            // Category Section
            categorySection
                .padding(.horizontal, 20)
            
            // FilterPicture Section
            filterPictureSection
            
            // Introduce Section
            textFieldSection(.introduce)
                .padding(.horizontal, 20)
            
            // Price Section
            textFieldSection(.price)
                .padding(.horizontal, 20)
            
            // 하단 여백
            Spacer()
                .frame(height: 100)
        }
    }
    
    func textFieldSection(_ type: GLTextFieldType) -> some View {
        switch type {
        case .filterName:
            GLTextField(
                type: .filterName,
                text: Binding(
                    get: { store.state.filterName },
                    set: { store.send(.filterNameChanged($0)) }
                )
            )
        case .introduce:
            GLTextField(
                type: .introduce,
                text: Binding(
                    get: { store.state.introduce },
                    set: { store.send(.introduceChanged($0)) }
                )
            )
        case .price:
            GLTextField(
                type: .price,
                text: Binding(
                    get: { store.state.price },
                    set: { store.send(.priceChanged($0)) }
                )
            )
        }
    }
    
    var categorySection: some View {
        CategorySectionView(
            selectedCategory: store.state.selectedCategory,
            onCategorySelected: { category in
                store.send(.categorySelected(category))
            }
        )
    }
    
    var filterPictureSection: some View {
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
                if let selectedImage = store.state.selectedImage {
                    store.send(.editButtonTapped(selectedImage))
                }
            }
        )
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
