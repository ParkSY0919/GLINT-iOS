//
//  EditView.swift
//  GLINT-iOS
//
//  Created by AI Assistant on 1/19/25.
//

import SwiftUI

struct EditView: View {
    @State private var store: EditViewStore
    let onSave: (UIImage) -> Void
    let onBack: () -> Void
    
    init(originalImage: UIImage, onSave: @escaping (UIImage) -> Void, onBack: @escaping () -> Void) {
        self._store = State(initialValue: EditViewStore(originalImage: originalImage))
        self.onSave = onSave
        self.onBack = onBack
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Photo Section
            PhotoSectionView(
                originalImage: store.state.originalImage,
                filteredImage: store.state.filteredImage,
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
            
            // Slider Section
            FilterSliderView(
                propertyType: store.state.selectedPropertyType,
                value: Binding(
                    get: { store.state.currentValue },
                    set: { newValue in
                        store.send(.valueChanged(newValue))
                    }
                ),
                isActive: store.state.isSliderActive,
                onValueChanged: { value in
                    store.send(.valueChanged(value))
                },
                onEditingChanged: { isEditing in
                    if !isEditing {
                        store.send(.valueChangeEnded(store.state.currentValue))
                    }
                }
            )
            .background(.gray100)
            .padding(.vertical, 16)
            
            
            // Filter Presets Section
            FilterPresetsView(
                selectedProperty: store.state.selectedPropertyType,
                onPropertySelected: { property in
                    store.send(.propertySelected(property))
                }
            )
            .frame(height: 80)
            .padding(.bottom, 34)
            .clipped()
        }
        .navigationTitle("EDIT")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.all, edges: .bottom)
        .background(.gray100)
        .toolbar {
            // 뒤로가기 버튼
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    onBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray0)
                }
            }
            
            // 저장 버튼
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    store.send(.saveButtonTapped)
                    onSave(store.state.filteredImage)
                    onBack()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray0)
                }
            }
        }
        .onAppear {
            setupNavigationAppearance()
        }
    }
    
    private func setupNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.brandBlack)
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
