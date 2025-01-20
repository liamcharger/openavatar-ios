//
//  AddEmailView.swift
//  Openavatar
//
//  Created by Liam Willey on 1/19/25.
//

import SwiftUI

struct AddEmailView: View {
    private let userViewModel = UserViewModel.shared
    
    let back: () -> Void
    let save: () -> Void
    let onboarding: Bool
    
    @Binding var email: String
    
    @FocusState var isEmailFocused: Bool
    
    init(email: Binding<String>, onboarding: Bool = false, back: @escaping () -> Void, save: @escaping () -> Void) {
        self.back = back
        self.save = save
        self.onboarding = onboarding
        
        self._email = email
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: onboarding ? "Time to enter your email." : "Enter your email.", icon: userViewModel.isEmailValid(email) ? "check" : "envelope", subtitle: onboarding ? "This email won't be publicly displayed." : nil, accent: userViewModel.isEmailValid(email) ? .green : .primary)
            CustomTextField("Email", text: $email)
                .autocapitalization(.none)
                .focused($isEmailFocused)
            HStack {
                BackButton(back: back)
                if userViewModel.isEmailValid(email) {
                    Button("My email is correct!") {
                        save()
                    }
                    .buttonStyle(CustomButtonStyle())
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .animation(.smooth, value: userViewModel.isEmailValid(email))
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            isEmailFocused = true
        }
    }
}
