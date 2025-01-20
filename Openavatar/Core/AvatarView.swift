//
//  AvatarView.swift
//  Openavatar
//
//  Created by Liam Willey on 1/16/25.
//

import SwiftUI
import Kingfisher

struct AvatarView: View {
    @ObservedObject var userViewModel = UserViewModel.shared
    
    @State private var showAvatarPicker = false
    @State private var showAvatarRemoveConfirmation = false
    
    let user: User
    let geo: GeometryProxy
    
    private func placeholderAvatar(width: CGFloat) -> some View {
        return Circle()
            .foregroundStyle(Color.gray.opacity(0.2))
            .overlay {
                Circle()
                    .stroke(.gray.opacity(0.3), lineWidth: 1)
            }
            .frame(width: width, height: width)
    }
    private var isLoading: Bool {
        return userViewModel.selectedImage != nil || showAvatarPicker
    }
    
    var body: some View {
        VStack(spacing: 14) {
            let size = min(200, geo.size.width / 2.6)
            
            if user.avatarURL != nil || userViewModel.selectedImage != nil {
                ZStack(alignment: .bottom) {
                    if let avatar = userViewModel.getAvatar(), !userViewModel.isShared(user) { // FIXME: if we use a cached version, when the avatar is changed on other clients, it won't update here
                        Image(uiImage: avatar)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                    } else if let avatarURL = user.avatarURL, let url = URL(
                        string: avatarURL
                    ) {
                        KFImage(url)
                            .placeholder { _ in
                                placeholderAvatar(width: size)
                                    .overlay {
                                        ProgressView()
                                            .tint(.white)
                                    }
                            }
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size, height: size)
                            .clipped()
                            .clipShape(Circle())
                    }
                    if userViewModel.isEditing {
                        HStack(spacing: 8) {
                            Button {
                                showAvatarPicker = true
                            } label: {
                                HStack(spacing: 7) {
                                    if isLoading {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "arrow.uturn.backward")
                                        Text("Replace")
                                    }
                                }
                                .padding(isLoading ? 6 : 9)
                                .padding(.horizontal, isLoading ? 0 : 3)
                                .font(.system(size: 14.5).weight(.medium))
                                .foregroundStyle(Color(.lightGray))
                                .background(Material.regular)
                                .clipShape(Capsule())
                            }
                            if user.avatarURL != nil {
                                Button {
                                    showAvatarRemoveConfirmation = true
                                } label: {
                                    FAText("trash-can", size: 16)
                                        .padding(9)
                                        .font(.system(size: 15).weight(.medium))
                                        .foregroundStyle(.red)
                                        .background(Material.regular)
                                        .clipShape(Capsule())
                                }
                                .confirmationDialog("Delete Avatar", isPresented: $showAvatarRemoveConfirmation) {
                                    Button("Delete", role: .destructive) {
                                        userViewModel.removeAvatar(user)
                                    }
                                    Button("Cancel", role: .cancel) {}
                                } message: {
                                    Text("Are you sure you want to delete your current avatar?")
                                }
                            }
                        }
                        .offset(y: 12)
                    }
                }
                .transition(.opacity.combined(with: .slide))
                .animation(.smooth, value: isLoading)
            } else if !userViewModel.isShared(user) {
                Button {
                    showAvatarPicker = true
                    // TODO: add import from other platforms
                } label: {
                    placeholderAvatar(width: size)
                        .overlay {
                            VStack(spacing: 7) {
                                FAText("camera", size: 28)
                                Text("Add Photo")
                                    .font(
                                        .system(size: 17)
                                        .weight(.medium)
                                    )
                            }
                            .foregroundStyle(.gray.opacity(0.9))
                        }
                }
                .frame(width: size, height: size)
            }
        }
        .sheet(isPresented: $showAvatarPicker, onDismiss: {
            userViewModel.uploadAvatar(user)
        }) {
            ImagePicker(selectedImage: $userViewModel.selectedImage)
        }
    }
}
