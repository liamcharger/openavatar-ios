//
//  AddBioView.swift
//  Openavatar
//
//  Created by Liam Willey on 1/16/25.
//

import SwiftUI

struct AddBioView: View {
    @ObservedObject var userViewModel = UserViewModel.shared
    
    @FocusState private var isBioFocused: Bool
    
    private let back: () -> Void
    private let next: () -> Void
    private let onboarding: Bool
    
    private var bioEmpty: Bool {
        userViewModel.bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(onboarding: Bool = false, back: @escaping() -> Void, next: @escaping() -> Void) {
        self.onboarding = onboarding
        self.back = back
        self.next = next
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Add a bio?", icon: "file-lines")
            TextEditor(text: $userViewModel.bio)
                .textFieldStyle(.plain)
                .padding(12)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Material.regular, lineWidth: 4)
                }
                .focused($isBioFocused)
            HStack {
                BackButton(back: back)
                let saveButton = Button(onboarding ? (bioEmpty ? "I'll add one later" : "I'm done with my bio!") : "Save my bio!") {
                    next()
                }
                .buttonStyle(CustomButtonStyle())
                .transition(.move(edge: .trailing).combined(with: .opacity))
                
                if onboarding {
                    saveButton
                } else if !bioEmpty {
                    saveButton
                }
            }
            .animation(.smooth, value: userViewModel.bio)
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            isBioFocused = true
        }
    }
}
