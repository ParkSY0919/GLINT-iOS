//
//  EditView.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI

struct EditView: View {
    @Environment(EditViewStore.self)
    private var store
    
    let image: UIImage
    
    var body: some View {
        content
            .appScreenStyle(ignoresSafeArea: true, safeAreaEdges: .bottom)
            .navigationSetup(
                title: "EDIT",
                onBackButtonTapped: { store.send(.backButtonTapped) },
                onRightButtonTapped: { store.send(.saveButtonTapped) }
            )
            .onViewDidLoad(perform: {
                store.send(.initialize(image: image))
            })
    }
}

private extension EditView {
    var content: some View {
        Group {
            if store.state.isInitialized {
                editContentView
            } else {
                StateViewBuilder.loadingIndicator()
            }
        }
    }
    
    var editContentView: some View {
        VStack(spacing: 0) {
            if let originalImage = store.state.originalImage,
               let filteredImage = store.state.filteredImage {
                photoSection(originalImage, filteredImage)
                sliderSection
                filterPresetsSection
            }
        }
    }
    
    func photoSection(_ originalImage: UIImage, _ filteredImage: UIImage) -> some View {
        PhotoSectionView(
            originalImage: originalImage,
            filteredImage: filteredImage,
            showingOriginal: store.state.showingOriginal,
            canUndo: store.state.editState.canUndo,
            canRedo: store.state.editState.canRedo,
            onToggleImage: {
                store.send(.toggleImageView)
            },
            onUndo: {
                store.send(.undoButtonTapped)
            },
            onRedo: {
                store.send(.redoButtonTapped)
            }
        )
    }
    
    var sliderSection: some View {
        FilterSliderView(
            propertyType: store.state.selectedPropertyType,
            value: store.state.currentValue,
            isActive: store.state.isSliderActive,
            onValueChanged: { value in
                store.send(.valueChanged(value))
            },
            onEditingEnded: { finalValue in
                store.send(.valueChangeEnded(finalValue))
            }
        )
        .background(.gray100)
        .padding(.vertical, 16)
    }
    
    var filterPresetsSection: some View {
        FilterPresetsView(
            selectedProperty: store.state.selectedPropertyType,
            onPropertySelected: { property in
                withAnimation(.easeInOut(duration: 0.3)) {
                    store.send(.propertySelected(property))
                }
            }
        )
        .frame(height: 80)
        .padding(.bottom, 34)
        .clipped()
    }
}
