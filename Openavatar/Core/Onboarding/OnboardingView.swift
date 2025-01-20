//
//  OnboardingView.swift
//  Openavatar
//
//  Created by Liam Willey on 1/11/25.
//

import SwiftUI

struct OnboardingView: View {
    private enum ViewSelection: Int, CaseIterable {
        case login
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
    @ObservedObject var userViewModel = UserViewModel.shared
    
    @State private var hasCompletedInitalAnimation = false
    @State private var showPage = false
    @State private var showPrimaryButton = false
    @State private var showSubtitle = false
    @State private var isReviewing = false
    
    @State private var nickname = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var loginEmail = ""
    @State private var bio = ""
    @State private var loginPassword = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var error: String?
    @State private var showError = false
    
    @State private var currentView: ViewSelection = .welcome
    
    @FocusState private var isNicknameFocused: Bool
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isBioFocused: Bool
    
    private let animation = Animation.smooth(duration: 0.9)
    
    private func wait(for interval: Double, completion: @escaping() -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            completion()
        }
    }
    private func backButton(backTo index: ViewSelection, ignoreReview: Bool = false) -> some View {
        Button {
            back(backTo: index, ignoreReview: ignoreReview)
        } label: {
            Image(systemName: "arrow.left")
                .frame(minHeight: 24)
        }
        .buttonStyle(CustomButtonStyle(style: .secondary))
    }
    private func nextButton(title: LocalizedStringKey, completion: (() -> Void)? = nil) -> some View {
        Button {
            next(completion: completion)
        } label: {
            HStack {
                Text(title)
                if completion == nil { // Don't show the arrow on the review screen
                    Image(systemName: "arrow.right")
                }
            }
        }
        .buttonStyle(CustomButtonStyle())
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }
    private func animateIn(subtitle: Bool = true) {
        wait(for: 0.8) {
            withAnimation(animation) {
                showPage.toggle()
            }
            wait(for: 1) {
                withAnimation(animation) {
                    showSubtitle = true
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
    private func back(backTo index: ViewSelection, ignoreReview: Bool = false) {
        if ignoreReview {
            isReviewing = false
        }
        
        if isReviewing {
            switchView()
        } else {
            switchView(to: index)
        }
    }
    private func next(completion: (() -> Void)? = nil) {
        haptic(style: .heavy)
        
        if let completion {
            completion()
        } else {
            switchView()
        }
    }
    private func switchView(to index: ViewSelection? = nil) {
        guard currentView.rawValue <= ViewSelection.loading.rawValue else { return }
        
        withAnimation(animation) {
            showPage = false
            showPrimaryButton = false
            showSubtitle = false
            
            wait(for: 0.8) {
                if let index {
                    currentView = index
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
            case .login: loginView
            case .welcome: welcomeView
            case .nickname: nicknameView
            case .name: nameView
            case .email:
                AddEmailView(email: $email, onboarding: true) {
                    back(backTo: .name)
                } save: {
                    next()
                }
            case .password: passwordView
            case .bio:
                AddBioView(onboarding: true) {
                    back(backTo: .password)
                } next: {
                    next()
                }
            case .review: review
            case .loading: LoadingView()
            }
        }
        .frame(maxHeight: .infinity)
        .padding()
        .opacity(showPage ? 1 : 0)
        .onAppear {
            animateIn()
        }
        .onChange(of: currentView) { _ in
            showError = false
            error = nil
        }
    }
    
    var welcomeView: some View {
        VStack {
            Spacer()
                .frame(maxHeight: 22)
            Spacer()
            HeaderView(title: "Welcome to Openavatar!", icon: "hands-clapping", subtitle: "The open-source alternative to Gravatar")
            Spacer()
            VStack(spacing: 10) {
                nextButton(title: "This is my first time here")
                Button("I have an account") {
                    switchView(to: .login)
                }
            }
            .padding()
        }
        .scaleEffect(showPage ? 1 : 1.1)
    }
    
    var loginView: some View {
        var canSubmit: Bool {
            return !loginPassword.trimmingCharacters(in: .whitespaces).isEmpty && loginPassword.count >= 6 && userViewModel.isEmailValid(loginEmail)
        }
        
        return VStack(spacing: 20) {
            HeaderView(title: "Time to login!", icon: "key", subtitle: "\(error ?? "")", accent: {
                if showError {
                    return .red
                }
                return .primary
            }(), error: showError)
            VStack {
                CustomTextField("Email", text: $loginEmail)
                    .focused($isEmailFocused)
                CustomTextField("Password", text: $loginPassword, type: .secure)
            }
            .autocapitalization(.none)
            HStack {
                backButton(backTo: .welcome)
                if canSubmit {
                    nextButton(title: "I've entered my credentials!", completion: {
                        authViewModel.login(email: loginEmail, password: loginPassword) { error in
                            if let error {
                                self.showError = true
                                self.error = error.localizedDescription
                            }
                            switchView(to: .loading)
                        }
                    })
                }
            }
            .frame(maxWidth: .infinity)
            .animation(.smooth, value: canSubmit)
        }
        .onAppear {
            isEmailFocused = true
        }
    }
    
    var nicknameView: some View {
        var canSubmit: Bool {
            return !nickname.trimmingCharacters(in: .whitespaces).isEmpty && nickname.count >= 3
        }
        
        return VStack(spacing: 20) {
            HeaderView(title: "First, pick a nickname.", icon: canSubmit ? "check" : "user", accent: canSubmit ? .green : .primary)
            CustomTextField("Nickname", text: $nickname)
                .focused($isNicknameFocused)
                .autocapitalization(.none)
            HStack {
                backButton(backTo: .welcome)
                if canSubmit {
                    nextButton(title: "My username is ready!")
                }
            }
            .animation(.smooth, value: canSubmit)
            .frame(maxWidth: .infinity)
        }
        .onChange(of: nickname) { nickname in
            self.nickname = nickname
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "@", with: "") // We don't want any @'s in a username
                .lowercased()
        }
        .onAppear {
            self.isNicknameFocused = true
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
            HeaderView(title: "Now, enter your first and last name.", icon: canSubmit && !firstNameEmpty && !lastNameEmpty ? "check" : "user", subtitle: "Your name is optional, and you can add one later", accent: canSubmit && !firstNameEmpty && !lastNameEmpty ? .green : .primary)
            HStack(spacing: 10) {
                CustomTextField("First", text: $firstName)
                CustomTextField("Last", text: $lastName)
            }
            .autocorrectionDisabled()
            HStack {
                backButton(backTo: .nickname)
                if canSubmit {
                    nextButton(title: firstNameEmpty && lastNameEmpty ? "I'll add one later" : "Continue!")
                }
            }
            .animation(.smooth, value: canSubmit)
            .frame(maxWidth: .infinity)
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
            HeaderView(title: "Create a strong password.", icon: canSubmit && doPasswordsMatch ? "check" : "key", subtitle: doPasswordsMatch ? "This password must be at least 6 digits long" : "The passwords do not match.", accent: {
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
            VStack {
                CustomTextField("Password", text: $password, type: .secure)
                CustomTextField("Confirm Password", text: $confirmPassword, type: .secure)
            }
            .autocapitalization(.none)
            HStack {
                backButton(backTo: .email)
                if canSubmit && doPasswordsMatch {
                    nextButton(title: "I've entered my password!")
                }
            }
            .frame(maxWidth: .infinity)
        }
        .animation(.smooth, value: canSubmit)
        .animation(.smooth, value: doPasswordsMatch)
    }
    
    var review: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    HeaderView(title: "Review your information",icon: "rotate-reverse", subtitle: "Make sure your information is correct")
                    CustomList {
                        ForEach(ViewSelection.allCases.filter({ $0 != .review && $0 != .password && $0 != .welcome && $0 != .loading && $0 != .login }), id: \.rawValue) { index in
                            let firstName = firstName.trimmingCharacters(in: .whitespaces).capitalized
                            let lastName = lastName.trimmingCharacters(in: .whitespaces).capitalized
                            let bio = bio.trimmingCharacters(in: .whitespaces)
                            
                            let button = Group {
                                Button {
                                    haptic(style: .light)
                                    switchView(to: index)
                                } label: {
                                    HStack(alignment: index == .bio ? .top : .center, spacing: 11) {
                                        FAText({
                                            switch index {
                                            case .nickname, .name:
                                                return "user"
                                            case .email:
                                                return "envelope"
                                            default:
                                                return "file-lines"
                                            }
                                        }())
                                        .frame(minWidth: 18)
                                        Text({
                                            switch index {
                                            case .nickname:
                                                return nickname.trimmingCharacters(in: .whitespaces)
                                            case .name:
                                                return firstName + " " + lastName
                                            case .email:
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
                                Divider()
                            }
                            
                            if index == .name || index == .bio {
                                if (index == .name && !firstName.isEmpty && !lastName.isEmpty) {
                                    button
                                } else if (index == .bio && !bio.isEmpty) {
                                    button
                                }
                            } else {
                                button
                            }
                        }
                    }
                }
                .padding()
            }
            Divider()
            HStack {
                backButton(backTo: .welcome, ignoreReview: true)
                nextButton(title: "Create my account!", completion: {
                    authViewModel.register(firstname: firstName.capitalized, lastname: lastName.capitalized, email: email, nickname: nickname, password: password) { error in
                        if let error {
                            self.error = error.localizedDescription
                            self.showError = true
                            return
                        }
                        self.switchView()
                    }
                })
            }
            .padding()
        }
        .alert(isPresented: $showError) {
            Alert(title: Text(error!), dismissButton: .cancel())
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
