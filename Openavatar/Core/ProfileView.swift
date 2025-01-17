//
//  ProfileView.swift
//  Openavatar
//
//  Created by Liam Willey on 1/1/25.
//

import SwiftUI
import Kingfisher

struct ProfileView: View {
    private enum ViewSelection: LocalizedStringKey, CaseIterable {
        case profile
        case name = "Name"
        case bio = "Bio"
        case contactInfo = "Contact Info"
        case links = "Social Accounts"
        case pronunciation = "Pronunciation"
        case pronouns = "Pronouns"
        case job = "Job"
    }
    
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var userViewModel = UserViewModel.shared
    
    @State private var showPronunciation = false
    @State private var showAvatarRemoveConfirmation = false
    @State private var showAvatarPicker = false
    @State private var isEditingBio = false
    
    @State private var bio = ""
    
    @State private var currentScreen: ViewSelection = .profile
    
    @FocusState private var isBioFocused: Bool
    
    private let animation = Animation.smooth(duration: 0.9)
    private var shouldHideNavigationBar: Bool {
        let isShared = !userViewModel.isShared(user)
        let isNotProfile = currentScreen != .profile
        let isScreenHidden = userViewModel.showScreen
        
        return isShared && isNotProfile && isScreenHidden
    }
    
    let user: User
    
    private var subtitle: String? {
        var result: String = ""
        let bullet = " • "
        let isNicknameSubtitle = (user.firstname != nil && user.lastname != nil)
        
        func descriptor(_ string: String) -> String {
            return (result.isEmpty ? string : (bullet + string))
        }
        
        if isNicknameSubtitle {
            result += user.nickname
        }
        if let pronouns = user.pronouns {
            result += descriptor(pronouns)
        }
        if let job = user.job {
            result += descriptor(job)
        }
        
        return result.isEmpty ? nil : result
    }
    
    private func elementPrompt(for element: ViewSelection) -> some View {
        Group {
            // We don't want to show any prompts if the profile has been shared
            if !userViewModel.isShared(user) {
                Button {
                    haptic(style: .medium)
                    switchView(to: element)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "plus")
                            .font(.body.weight(.medium))
                            .padding(10)
                            .foregroundStyle(.white)
                            .background(Color.lightBlue)
                            .clipShape(Circle())
                        Text({
                            var body = "Add "
                            
                            switch element {
                            case .name:
                                body += "a name"
                            case .pronouns:
                                body += "your pronouns"
                            case .job:
                                body += "a job"
                            case .bio:
                                body += "a bio"
                            case .contactInfo:
                                body += "an email or phone number"
                            default:
                                body += "social links"
                            }
                            
                            return body
                        }())
                        Spacer()
                    }
                }
                .buttonStyle(ListButtonStyle())
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(.lightGray).opacity(0.25), lineWidth: 1)
                }
            }
        }
    }
    private func getSocialPlatform(from urlString: String) -> (name: String, icon: String?, accent: Color?) {
        let platforms: [String: (name: String, iconName: String, accent: Color)] = [
            "github.com": ("GitHub", "github", Color.primary),
            "stackoverflow.com": ("Stack Overflow", "stack-overflow", Color.orange),
            "stackexchange.com": ("Stack Exchange", "stack-exchange", Color.lightBlue),
            "twitter.com": ("X", "x-twitter", Color.primary),
            "x.com": ("X", "x-twitter", Color.primary),
            "facebook.com": ("Facebook", "facebook", Color.blue),
            "linkedin.com": ("LinkedIn", "linkedin", Color.lightBlue),
            "instagram.com": ("Instagram", "instagram", Color.red),
            "youtube.com": ("YouTube", "youtube", Color.red),
            "reddit.com": ("Reddit", "reddit", Color.red)
        ]
        
        // TODO: add a check when urls are added to remove https
        guard let url = URL(string: "https://" + urlString),
              let host = url.host?.lowercased() else {
            return (name: urlString, icon: nil, accent: nil)
        }
        
        // Find the platform matching the host
        for (domain, platform) in platforms {
            if host.contains(domain) {
                return (name: platform.name, icon: platform.iconName, accent: platform.accent)
            }
        }
        
        return (name: urlString, icon: nil, accent: nil)
    }
    private func switchView(to view: ViewSelection = .profile) {
        withAnimation(animation) {
            userViewModel.showScreen = false
        }
        wait(for: 0.9) {
            currentScreen = view
            withAnimation(animation) {
                userViewModel.showScreen = true
            }
        }
    }
    private func wait(for interval: Double, completion: @escaping() -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            completion()
        }
    }
    
    init(_ user: User) {
        self.user = user
    }
    
    var body: some View {
        ZStack {
            switch currentScreen {
            case .profile:
                profile
            case .bio:
                AddBioView(onboarding: false) {
                    switchView()
                } next: {
                    userViewModel.updateBio(bio)
                    switchView()
                }
            default:
                Button("Back") {
                    switchView()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .disabled(!userViewModel.showScreen)
        .opacity(userViewModel.showScreen ? 1 : 0)
        .scaleEffect(userViewModel.showScreen ? 1 : 1.1)
        .onAppear {
            switchView()
        }
    }
    
    var profile: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 30) {
                    if userViewModel.isShared(user) {
                        Text("Shared to You")
                            .padding(9)
                            .padding(.horizontal, 3)
                            .font(.system(size: 14).weight(.medium))
                            .overlay {
                                Capsule()
                                    .stroke(Color.primary, lineWidth: 2)
                            }
                    }
                    AvatarView(user: user, geo: geo)
                    VStack(spacing: 5) {
                            HStack(spacing: 12) {
                                Text({
                                    if let firstname = user.firstname, let lastname = user.lastname {
                                        return "\(firstname) \(lastname)"
                                    } else {
                                        return user.nickname
                                    }
                                }())
                                .font(
                                    .system(size: 28, design: .monospaced)
                                    .weight(.bold)
                                )
                                if let pronunciation = user.pronunciation {
                                    Button {
                                        showPronunciation = true
                                    } label: {
                                        Image(systemName: "person.wave.2.fill")
                                            .font(.system(size: 24))
                                    }
                                    .popover(isPresented: $showPronunciation) {
                                        VStack {
                                            Text(pronunciation)
                                                .padding(.horizontal)
                                        }
                                        .presentationCompactAdaptation(.popover)
                                    }
                                } else if !userViewModel.isShared(user) {
                                    Button {
                                        haptic(style: .light)
                                        switchView(to: .pronunciation)
                                        showPronunciation = true
                                    } label: {
                                        ZStack(alignment: .bottomTrailing) {
                                            Image(systemName: "person.wave.2.fill")
                                                .font(.system(size: 24))
                                            Image(systemName: "plus")
                                                .font(.system(size: 16).weight(.medium))
                                                .padding(4)
                                                .foregroundStyle(.white)
                                                .background(Color.blue)
                                                .clipShape(Circle())
                                                .overlay {
                                                    Circle()
                                                        .stroke(Color(.systemBackground), lineWidth: 2)
                                                }
                                                .offset(x: 9, y: 12)
                                        }
                                    }
                                }
                            }
                            if let subtitle {
                                Text(subtitle)
                                    .font(.system(size: 20.5))
                                    .foregroundStyle(.gray)
                            }
                        }
                    HStack(spacing: 12) {
                        if let phoneNumbers = user.phoneNumbers, !phoneNumbers.isEmpty {
                            if phoneNumbers.count > 1 {
                                Menu {
                                    ForEach(
                                        phoneNumbers,
                                        id: \.self
                                    ) { phoneNumber in
                                        ContactActionButton(
                                            phoneNumber,
                                            type: .phoneNumber
                                        )
                                    }
                                } label: {
                                    ContactRowView {
                                        FAText("phone", size: 23)
                                    }
                                }
                            } else if let phoneNumber = phoneNumbers.first {
                                ContactActionButton(
                                    phoneNumber,
                                    type: .phoneNumber
                                )
                            }
                        }
                        if let emails = user.emails, !emails.isEmpty {
                            if emails.count > 1 {
                                Menu {
                                    ForEach(emails, id: \.self) { email in
                                        ContactActionButton(email, type: .email)
                                    }
                                } label: {
                                    ContactRowView {
                                        FAText("envelope", size: 23)
                                    }
                                }
                            } else if let email = emails.first {
                                ContactActionButton(email, type: .email)
                            }
                        }
                        if let url = URL(string: "https://openavatar.web.app/profile/\(user.uid)") {
                            ShareLink(item: url) {
                                ContactRowView {
                                    HStack {
                                        FAText("share", size: 23)
                                        if user.emails == nil && user.phoneNumbers == nil { // Show an expanded version if there aren't any sister buttons
                                            Text("Share my profile")
                                                .font(.body.weight(.medium))
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    VStack(spacing: 28) {
                        bioRow
                        if let links = user.socialAccounts {
                            VStack(alignment: .leading, spacing: 7) {
                                Text("Social Accounts".uppercased())
                                    .foregroundStyle(Color.gray.opacity(0.9))
                                    .font(.system(size: 13.5).weight(.medium))
                                CustomList {
                                    ForEach(links.indices, id: \.self) { index in
                                        let link = links[index]
                                        let platform = getSocialPlatform(from: link)

                                        Button {
                                            guard let url = URL(string: "https://" + link) else { return }
                                            
                                            haptic(style: .light)
                                            openURL(url)
                                        } label: {
                                            HStack(spacing: 10) {
                                                FAText(platform.icon ?? "link", size: 25)
                                                    .foregroundStyle(platform.accent ?? Color.primary)
                                                    .frame(maxHeight: 35)
                                                    .background(platform.icon == nil ? Color.gray.opacity(0.4) : .clear)
                                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                                Text(platform.name)
                                                    .lineLimit(1)
                                                Spacer()
                                                FAText("square-arrow-up-right", size: 17)
                                                    .foregroundStyle(.secondary)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .buttonStyle(ListButtonStyle())
                                    }
                                    // TODO: always show an option to add more links
                                }
                            }
                        }
                        VStack(spacing: 10) {
                            if user.bio == nil {
                                elementPrompt(for: .bio)
                            }
                            if user.firstname == nil && user.lastname == nil {
                                elementPrompt(for: .name)
                            }
                            if user.pronouns == nil {
                                elementPrompt(for: .pronouns)
                            }
                            if user.job == nil {
                                elementPrompt(for: .job)
                            }
                            if user.emails == nil && user.phoneNumbers == nil {
                                elementPrompt(for: .contactInfo)
                            }
                            if user.socialAccounts == nil {
                                elementPrompt(for: .links)
                            }
                        }
                    }
                }
                .padding()
                .padding(.top, 40)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    var bioRow: some View {
        VStack {
            if let bio = user.bio {
                ZStack(alignment: .topTrailing) {
                    Group {
                        if isEditingBio {
                            TextEditor(text: $bio)
                                .focused($isBioFocused)
                                .frame(minHeight: 120)
                                .padding(7)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.materialGray, lineWidth: 3)
                                }
                        } else {
                            Text(bio)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(13)
                                .background(Color.materialGray)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color(.lightGray).opacity(0.25), lineWidth: 1)
                                }
                        }
                    }
                    .multilineTextAlignment(.leading)
                    if !isEditingBio {
                        Button {
                            haptic(style: .light)
                            
                            self.bio = bio
                            self.isBioFocused = true
                            self.isEditingBio = true
                        } label: {
                            FAText("pen", size: 16)
                                .padding(9)
                                .foregroundStyle(Color.white)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .offset(x: 9, y: -9)
                        }
                    }
                }
                if isEditingBio {
                    HStack {
                        Button("Save") {
                            userViewModel.updateBio(self.bio)
                            isBioFocused = false
                            isEditingBio = false
                        }
                        .buttonStyle(CustomButtonStyle(style: .minimal))
                        .frame(minWidth: 0)
                        Button("Cancel") {
                            isEditingBio = false
                        }
                        .buttonStyle(CustomButtonStyle(style: .minimalSecondary))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

struct ContactActionButton: View {
    enum `Type` {
        case email
        case phoneNumber
    }
    
    @Environment(\.openURL) var openURL
    
    let string: String
    let type: `Type`
    
    func executeSocial() {
        if let url = URL(string: "\(type == .email ? "mailto" : "tel")://\(type == .email ? string : string.replacingOccurrences(of: " ", with: ""))") {
            openURL(url)
        }
    }
    
    init(_ string: String, type: `Type`) {
        self.string = string
        self.type = type
    }
    
    var body: some View {
        Menu(string) {
            Button {
                haptic(style: .light)
                UIPasteboard.general.string = string
            } label: {
                Label("Copy", systemImage: "doc.on.clipboard")
            }
            Button {
                haptic(style: .light)
                executeSocial()
            } label: {
                if type == .email {
                    Label("Send Email", systemImage: "envelope")
                } else {
                    Label("Call", systemImage: "phone")
                }
            }
        }
    }
}

struct ContactRowView<V: View>: View {
    let content: V
    
    init(@ViewBuilder content: () -> V) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(minWidth: 48)
            .frame(height: 48)
            .background(Color.blue.gradient)
            .foregroundStyle(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    NavigationView {
        ProfileView(User.user)
    }
}
