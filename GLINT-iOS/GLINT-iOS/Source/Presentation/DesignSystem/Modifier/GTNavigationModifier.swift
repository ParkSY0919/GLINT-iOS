//
//  GTNavigationModifier.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/1/25.
//

import SwiftUI

struct GTNavigationSetupModifier: ViewModifier {
    let title: String
    let backAction: (() -> Void)?
    let likeAction: (() -> Void)?
    let isLiked: Bool?
    let uploadAction: (() -> Void)?
    let editAction: (() -> Void)?
    let deleteAction: (() -> Void)?
    
    @State private var showActionSheet = false
    @State private var showDeleteAlert = false
    
    private var hasMenuActions: Bool {
        editAction != nil || deleteAction != nil
    }
    
    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                // Leading buttons
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    if let backAction = backAction {
                        toolbarButton(icon: "arrow.left", action: backAction)
                    }
                }
                
                // Trailing buttons
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if let likeAction = likeAction, let isLiked = isLiked {
                        GTLikeButton(likedState: isLiked, action: likeAction)
                    }
                    
                    if let uploadAction = uploadAction {
                        toolbarButton(image: Images.Make.upload, action: uploadAction)
                    }
                    
                    if hasMenuActions {
                        toolbarButton(image: Images.Detail.list) {
                            showActionSheet = true
                        }
                    }
                }
            }
            .actionSheet(isPresented: $showActionSheet) {
                buildActionSheet()
            }
            .conditionalAlert(
                title: Strings.Detail.deleteConfirm,
                isPresented: $showDeleteAlert,
                buttons: {
                    Button(Strings.Detail.cancel, role: .cancel) { }
                    Button(Strings.Detail.confirm, role: .destructive) {
                        deleteAction?()
                    }
                },
                message: {
                    Text(Strings.Detail.deleteMessage)
                }
            )
    }
    
    @ViewBuilder
    private func toolbarButton(
        icon: String? = nil,
        image: Image? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Group {
                if let icon = icon {
                    Image(systemName: icon)
                } else if let image = image {
                    image
                } else {
                    EmptyView()
                }
            }
            .frame(width: 32, height: 32)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.gray75)
        }
    }
    
    private func buildActionSheet() -> ActionSheet {
        var buttons: [ActionSheet.Button] = []
        
        if editAction != nil {
            buttons.append(.default(Text(Strings.Detail.edit)) {
                editAction?()
            })
        }
        
        if deleteAction != nil {
            buttons.append(.destructive(Text(Strings.Detail.delete)) {
                showDeleteAlert = true
            })
        }
        
        buttons.append(.cancel(Text(Strings.Detail.cancel)))
        
        return ActionSheet(
            title: Text(Strings.Detail.actionSelect),
            buttons: buttons
        )
    }
}
extension View {
    func navigationSetup(
        title: String,
        backAction: (() -> Void)? = nil,
        likeAction: (() -> Void)? = nil,
        isLiked: Bool? = nil,
        uploadAction: (() -> Void)? = nil,
        editAction: (() -> Void)? = nil,
        deleteAction: (() -> Void)? = nil
    ) -> some View {
        self.modifier(
            GTNavigationSetupModifier(
                title: title,
                backAction: backAction,
                likeAction: likeAction,
                isLiked: isLiked,
                uploadAction: uploadAction,
                editAction: editAction,
                deleteAction: deleteAction
            )
        )
    }
    
    // 기존 호환성 유지
    func navigationSetup(
        title: String,
        isLiked: Bool? = nil,
        onBackButtonTapped: (() -> Void)? = nil,
        onLikeButtonTapped: (() -> Void)? = nil,
        onRightButtonTapped: (() -> Void)? = nil,
        onListButtonTapped: (() -> Void)? = nil,
        onEditButtonTapped: (() -> Void)? = nil,
        onDeleteButtonTapped: (() -> Void)? = nil
    ) -> some View {
        navigationSetup(
            title: title,
            backAction: onBackButtonTapped,
            likeAction: onLikeButtonTapped,
            isLiked: isLiked,
            uploadAction: onRightButtonTapped,
            editAction: onEditButtonTapped,
            deleteAction: onDeleteButtonTapped
        )
    }
}
