//
//  OnboardingView.swift
//  OpenID
//
//  Created by Liam Willey on 1/11/25.
//

import SwiftUI

struct OnboardingView: View {
    enum ViewSelection: Int, CaseIterable {
        case welcome
        case nickname
        case name
        case email
        case password
        case bio
        case review
        case loading
    }
    
    @ObservedObject var authViewModel = AuthViewModel.shared
    
    @State private var hasCompletedInitalAnimation = false
    @State private var showPage = false
    @State private var showPrimaryButton = false
    @State private var showSubtitle = false
    @State private var isReviewing = false
    
    @State private var nickname = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var bio = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var error: String?
    @State private var showError = false
    
    @State private var currentView: ViewSelection = .welcome
    
    @FocusState private var isNicknameFocused: Bool
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool
    @FocusState private var isBioFocused: Bool
    
    private let animation = Animation.smooth(duration: 0.9)
    
    private func wait(for interval: Double, completion: @escaping() -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            completion()
        }
    }
    private func nextButton(title: LocalizedStringKey, completion: (() -> Void)? = nil) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            
            if let completion {
                completion()
            } else {
                switchView()
            }
        } label: {
            HStack {
                Text(title)
                if completion == nil { // Don't show the arrow on the review screen
                    Image(systemName: "arrow.right")
                }
            }
        }
        .buttonStyle(CustomButtonStyle())
    }
    private func header(icon: String, title: LocalizedStringKey, subtitle: LocalizedStringKey? = nil, accent: Color = .primary, error: Bool = false) -> some View {
        VStack(spacing: 10) {
            FAText(iconName: icon, size: 32)
                .padding()
                .background(accent == .primary ? .clear : accent.opacity(0.1))
                .background {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(accent, lineWidth: 5)
                }
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .foregroundColor(accent)
                .animation(.smooth(duration: 0.4), value: icon)
            Text(title)
                .font(.system(size: 28, design: .monospaced).weight(.bold))
            if let subtitle {
                Text(subtitle)
                    .foregroundStyle(error ? Color.red : Color(.lightGray))
                    .offset(y: !hasCompletedInitalAnimation ? (showSubtitle ? 0 : 12) : 0)
                    .opacity(showSubtitle ? 1 : 0)
            }
        }
        .multilineTextAlignment(.center)
    }
    private func animateIn(subtitle: Bool = true) {
        showSubtitle = false
        
        wait(for: 0.8) {
            withAnimation(animation) {
                showPage.toggle()
            }
            wait(for: 1) {
                withAnimation(animation) {
                    showSubtitle.toggle()
                    wait(for: 0.6) {
                        withAnimation(animation) {
                            showPrimaryButton.toggle()
                            
                            hasCompletedInitalAnimation = true
                        }
                    }
                }
            }
        }
    }
    private func switchView(to index: Int? = nil) {
        guard currentView.rawValue <= ViewSelection.loading.rawValue else { return }
        
        withAnimation(animation) {
            showPage = false
            showPrimaryButton = false
            
            wait(for: 0.8) {
                if let index {
                    currentView = ViewSelection(rawValue: index) ?? .welcome
                } else if isReviewing {
                    currentView = .review
                } else {
                    currentView = ViewSelection(rawValue: currentView.rawValue + 1) ?? .welcome
                }
            }
            
            animateIn()
        }
    }
    
    var body: some View {
        ZStack {
            switch currentView {
            case .welcome: welcome
            case .nickname: nicknameView
            case .name: nameView
            case .email: emailView
            case .password: passwordView
            case .bio:  bioView
            case .review: review
            case .loading: LoadingView()
            }
        }
        .alert(isPresented: $showError) {
            Alert(title: Text(error!), dismissButton: .cancel())
        }
        .padding()
        .opacity(showPage ? 1 : 0)
        .onAppear {
            animateIn()
        }
    }
    
    var welcome: some View {
        VStack {
            Spacer()
                .frame(maxHeight: 22)
            Spacer()
            header(icon: "hands-clapping", title: "Welcome to OpenID!", subtitle: "The open-source alternative to Gravatar")
            Spacer()
            nextButton(title: "Get Started")
                .padding()
                .offset(y: showPrimaryButton ? 0 : 15)
                .opacity(showPrimaryButton ? 1 : 0)
        }
        .scaleEffect(showPage ? 1 : 1.1)
    }
    
    var nicknameView: some View {
        var canSubmit: Bool {
            return !nickname.trimmingCharacters(in: .whitespaces).isEmpty && nickname.count >= 3
        }
        
        return VStack(spacing: 20) {
            header(icon: canSubmit ? "check" : "user", title: "First, pick a nickname.", accent: canSubmit ? .green : .primary)
            // TODO: do not allow capitals or spaces
            CustomTextField("Nickname", text: $nickname)
                .focused($isNicknameFocused)
            nextButton(title: "My username is ready!")
                .offset(y: canSubmit ? 0 : 15)
                .opacity(canSubmit ? 1 : 0)
                .animation(.smooth, value: nickname)
        }
        .onAppear {
            isNicknameFocused = true
        }
    }
    
    var nameView: some View {
        let firstNameEmpty = firstName.trimmingCharacters(in: .whitespaces).isEmpty
        let lastNameEmpty = lastName.trimmingCharacters(in: .whitespaces).isEmpty
        var canSubmit: Bool {
            if firstNameEmpty && lastNameEmpty {
                return true
            } else {
                return !firstNameEmpty && !lastNameEmpty
            }
        }
        
        return VStack(spacing: 20) {
            header(icon: canSubmit && !firstNameEmpty && !lastNameEmpty ? "check" : "user", title: "Now, enter your first and last name.", subtitle: "Your name is optional, and you can add one later", accent: canSubmit && !firstNameEmpty && !lastNameEmpty ? .green : .primary)
            HStack(spacing: 10) {
                CustomTextField("First", text: $firstName)
                CustomTextField("Last", text: $lastName)
            }
            .autocorrectionDisabled()
            nextButton(title: firstNameEmpty && lastNameEmpty ? "I don't want to enter my name" : "Continue!")
                .offset(y: canSubmit ? 0 : 15)
                .opacity(canSubmit ? 1 : 0)
                .animation(.smooth, value: firstName)
                .animation(.smooth, value: lastName)
        }
    }
    
    var emailView: some View {
        var canSubmit: Bool {
            let email = email.trimmingCharacters(in: .whitespaces)
            let atComponents = email.components(separatedBy: "@")
            let dotComponents = email.components(separatedBy: ".")
            
            return !email.trimmingCharacters(in: .whitespaces).isEmpty && email.contains("@") && email.contains(".") && atComponents.count == 2 && dotComponents.count == 2 && !dotComponents[1].isEmpty
        }
        
        return VStack(spacing: 20) {
            header(icon: canSubmit ? "check" : "envelope", title: "Time to enter your email.", subtitle: "This email won't be publicly displayed.", accent: canSubmit ? .green : .primary)
            CustomTextField("Email", text: $email)
                .focused($isEmailFocused)
            nextButton(title: "My email is correct!")
                .offset(y: canSubmit ? 0 : 15)
                .opacity(canSubmit ? 1 : 0)
                .animation(.smooth, value: email)
        }
        .onAppear {
            isEmailFocused = true
        }
    }
    
    var passwordView: some View {
        var canSubmit: Bool {
            return !password.isEmpty && !confirmPassword.isEmpty && password.count >= 6 && confirmPassword.count >= 6
        }
        var doPasswordsMatch: Bool {
            if canSubmit {
                return password == confirmPassword
            }
            return true
        }
        
        return VStack(spacing: 20) {
            header(icon: canSubmit && doPasswordsMatch ? "check" : "key", title: "Next, create a strong password for your account.", subtitle: doPasswordsMatch ? "This password must be at least 6 digits long" : "The passwords do not match.", accent: {
                if password.isEmpty && confirmPassword.isEmpty {
                    return .primary
                } else if canSubmit && doPasswordsMatch {
                    return .green
                } else if !doPasswordsMatch {
                    return .red
                } else {
                    return .orange
                }
            }(), error: !doPasswordsMatch)
            CustomPasswordField("Password", text: $password)
                .focused($isPasswordFocused)
            CustomPasswordField("Confirm Password", text: $confirmPassword)
            nextButton(title: "I've entered my password!")
                .offset(y: canSubmit && doPasswordsMatch ? 0 : 15)
                .opacity(canSubmit && doPasswordsMatch ? 1 : 0)
                .animation(.smooth, value: password)
                .animation(.smooth, value: confirmPassword)
        }
        .onAppear {
            isPasswordFocused = true
        }
    }
    
    var bioView: some View {
        let bioEmpty = bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        return VStack(spacing: 20) {
            header(icon: "file-lines", title: "Add a bio?")
            TextEditor(text: $bio)
                .textFieldStyle(.plain)
                .font(.title3)
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Material.regular, lineWidth: 4)
                }
                .focused($isBioFocused)
            nextButton(title: bioEmpty ? "I'll add one later" : "I'm done with my bio!")
                .animation(.smooth, value: bio)
        }
        .onAppear {
            isBioFocused = true
        }
    }
    
    var review: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    header(icon: "rotate-reverse", title: "Review your information", subtitle: "Make sure your information is correct")
                    VStack(spacing: 0) {
                        ForEach(ViewSelection.allCases.filter({ $0 != .review && $0 != .password && $0 != .welcome && $0 != .loading }).compactMap({ $0.rawValue }), id: \.self) { index in
                            let firstName = firstName.trimmingCharacters(in: .whitespaces)
                            let lastName = lastName.trimmingCharacters(in: .whitespaces)
                            let bio = bio.trimmingCharacters(in: .whitespaces)
                            
                            let button = Group {
                                Button {
                                    switchView(to: index)
                                } label: {
                                    HStack(alignment: index == 5 ? .top : .center, spacing: 11) {
                                        FAText(iconName: {
                                            switch index {
                                            case 1, 2:
                                                return "user"
                                            case 3:
                                                return "envelope"
                                            default:
                                                return "file-lines"
                                            }
                                        }(), size: 18)
                                        .frame(minWidth: 18)
                                        Text({
                                            switch index {
                                            case 1:
                                                return nickname.trimmingCharacters(in: .whitespaces)
                                            case 2:
                                                return firstName + " " + lastName
                                            case 3:
                                                return email.trimmingCharacters(in: .whitespaces)
                                            default:
                                                return bio
                                            }
                                        }())
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 17))
                                            .foregroundStyle(.gray)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .buttonStyle(ListButtonStyle())
                                if index != 5 {
                                    Divider()
                                }
                            }
                            
                            if index == 2 || index == 5 {
                                if (index == 2 && !firstName.isEmpty && !lastName.isEmpty) {
                                    button
                                } else if (index == 5 && !bio.isEmpty) {
                                    button
                                }
                            } else {
                                button
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .padding()
            }
            Divider()
            nextButton(title: "Create my account!", completion: {
                authViewModel.register(firstname: firstName, lastname: lastName, email: email, nickname: nickname, bio: bio, password: password) { error in
                    if let error {
                        self.error = error.localizedDescription
                        self.showError = true
                        return
                    }
                    self.switchView()
                }
            })
            .padding()
        }
        .padding(-16) // Offset the padding set in the body
        .onAppear {
            isReviewing = true
        }
    }
}

#Preview {
    OnboardingView()
}
