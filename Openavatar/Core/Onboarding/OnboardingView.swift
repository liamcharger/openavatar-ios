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
    
    @State private var currentView: ViewSelection = .password
    
    @FocusState private var isNicknameFocused: Bool
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isBioFocused: Bool
    
    private let animation = Animation.smooth(duration: 0.9)
    
    private func isEmailValid(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        return emailPredicate.evaluate(with: email)
    }
    private func wait(for interval: Double, completion: @escaping() -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            completion()
        }
    }
    private func backButton(backTo index: ViewSelection, ignoreReview: Bool = false) -> some View {
        Button {
            if ignoreReview {
                isReviewing = false
            }
            
            if isReviewing {
                switchView()
            } else {
                switchView(to: index)
            }
        } label: {
            Image(systemName: "arrow.left")
                .frame(minHeight: 24)
        }
        .buttonStyle(CustomButtonStyle(style: .compact))
    }
    private func nextButton(title: LocalizedStringKey, completion: (() -> Void)? = nil) -> some View {
        Button {
            haptic(style: .button)
            
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
        .transition(.move(edge: .trailing).combined(with: .opacity))
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
            case .email: emailView
            case .password: passwordView
            case .bio:  bioView
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
            header(icon: "hands-clapping", title: "Welcome to Openavatar!", subtitle: "The open-source alternative to Gravatar")
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
            return !loginPassword.trimmingCharacters(in: .whitespaces).isEmpty && loginPassword.count >= 6 && isEmailValid(loginEmail)
        }
        
        return VStack(spacing: 20) {
            header(icon: "key", title: "Time to login!", subtitle: "\(error ?? "")", accent: {
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
            header(icon: canSubmit ? "check" : "user", title: "First, pick a nickname.", accent: canSubmit ? .green : .primary)
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
            header(icon: canSubmit && !firstNameEmpty && !lastNameEmpty ? "check" : "user", title: "Now, enter your first and last name.", subtitle: "Your name is optional, and you can add one later", accent: canSubmit && !firstNameEmpty && !lastNameEmpty ? .green : .primary)
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
    
    var emailView: some View {
        return VStack(spacing: 20) {
            header(icon: isEmailValid(email) ? "check" : "envelope", title: "Time to enter your email.", subtitle: "This email won't be publicly displayed.", accent: isEmailValid(email) ? .green : .primary)
            CustomTextField("Email", text: $email)
                .autocapitalization(.none)
                .focused($isEmailFocused)
            HStack {
                backButton(backTo: .name)
                if isEmailValid(email) {
                    nextButton(title: "My email is correct!")
                }
            }
            .animation(.smooth, value: isEmailValid(email))
            .frame(maxWidth: .infinity)
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
            header(icon: canSubmit && doPasswordsMatch ? "check" : "key", title: "Create a strong password.", subtitle: doPasswordsMatch ? "This password must be at least 6 digits long" : "The passwords do not match.", accent: {
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
            HStack {
                backButton(backTo: .password)
                nextButton(title: bioEmpty ? "I'll add one later" : "I'm done with my bio!")
                    .animation(.smooth, value: bio)
            }
            .frame(maxWidth: .infinity)
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
                    CustomList {
                        ForEach(ViewSelection.allCases.filter({ $0 != .review && $0 != .password && $0 != .welcome && $0 != .loading && $0 != .login }), id: \.rawValue) { index in
                            let firstName = firstName.trimmingCharacters(in: .whitespaces).capitalized
                            let lastName = lastName.trimmingCharacters(in: .whitespaces).capitalized
                            let bio = bio.trimmingCharacters(in: .whitespaces)
                            
                            let button = Group {
                                Button {
                                    haptic(style: .list)
                                    switchView(to: index)
                                } label: {
                                    HStack(alignment: index == .bio ? .top : .center, spacing: 11) {
                                        FAText(iconName: {
                                            switch index {
                                            case .nickname, .name:
                                                return "user"
                                            case .email:
                                                return "envelope"
                                            default:
                                                return "file-lines"
                                            }
                                        }(), size: 18)
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
                    authViewModel.register(firstname: firstName.capitalized, lastname: lastName.capitalized, email: email, nickname: nickname, bio: bio, password: password) { error in
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
