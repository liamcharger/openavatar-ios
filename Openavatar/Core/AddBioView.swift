//
//  AddBioView.swift
//  Openavatar
//
//  Created by Liam Willey on 1/16/25.
//

import SwiftUI

struct AddBioView: View {
    @ObservedObject var userViewModel = UserViewModel.shared
    
    @State private var bio = ""
    
    @FocusState private var isBioFocused: Bool
    
    private let back: () -> Void
    private let next: () -> Void
    private let onboarding: Bool
    
    private var bioEmpty: Bool {
        bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(onboarding: Bool = true, back: @escaping() -> Void, next: @escaping() -> Void) {
        self.onboarding = onboarding
        self.back = back
        self.next = next
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                FAText("file-lines", size: 32)
                    .padding()
                    .overlay {
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(.primary, lineWidth: 5)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                Text("Add a bio?")
                    .font(.system(size: 28, design: .monospaced).weight(.bold))
            }
            .multilineTextAlignment(.center)
            TextEditor(text: $bio)
                .textFieldStyle(.plain)
                .font(.title3)
                .padding(12)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Material.regular, lineWidth: 4)
                }
                .focused($isBioFocused)
            HStack {
                Button {
                    back()
                } label: {
                    Image(systemName: "arrow.left")
                        .frame(minHeight: 24)
                }
                .buttonStyle(CustomButtonStyle(style: .secondary))
                if !bioEmpty {
                    Button(onboarding ? (bioEmpty ? "I'll add one later" : "I'm done with my bio!") : "Save my bio") {
                        next()
                    }
                    .buttonStyle(CustomButtonStyle())
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .animation(.smooth, value: bio)
            .frame(maxWidth: .infinity)
        }
        .padding()
        .onAppear {
            isBioFocused = true
        }
    }
}
