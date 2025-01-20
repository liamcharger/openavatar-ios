//
//  ProfileView.swift
//  Openavatar
//
//  Created by Liam Willey on 1/1/25.
//

import SwiftUI
import Kingfisher

struct ProfileView: View {
    private enum ViewSelection {
        case profile
        case name
        case bio
        case contactInfo
        case socialAccounts
        case pronunciation
        case pronouns
        case job
        case phoneNumber
        case email
    }
    
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var userViewModel = UserViewModel.shared
    
    @State private var showPronunciation = false
    @State private var showAvatarRemoveConfirmation = false
    @State private var showAvatarPicker = false
    @State private var isEditingBio = false
    
    @State private var email = "" // Should this be in the view model?
    
    @State private var currentScreen: ViewSelection = .profile
    
    @FocusState private var isBioFocused: Bool
    
    private let animation = Animation.smooth(duration: 0.9)
    
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
        let label = HStack(spacing: 10) {
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
                    body += "a social account"
                }
                
                return body
            }())
            Spacer()
        }
        
        return Group {
            // We don't want to show any prompts if the profile has been shared
            if userViewModel.isEditing {
                if element != .contactInfo {
                    Button {
                        haptic(style: .medium)
                        switchView(to: element)
                    } label: {
                        label
                    }
                    .buttonStyle(ListButtonStyle())
                    .backgroundBorder()
                } else {
                    Menu {
                        Button {
                            haptic(style: .medium)
                            switchView(to: .phoneNumber)
                        } label: {
                            Label("Add a Phone Number", systemImage: "plus")
                        }
                        Button {
                            haptic(style: .medium)
                            switchView(to: .email)
                        } label: {
                            Label("Add an Email", systemImage: "plus")
                        }
                    } label: {
                        label
                    }
                    .buttonStyle(ListButtonStyle())
                    .backgroundBorder()
                }
            }
        }
    }
    private func getSocialPlatform(from urlString: String) -> (name: String, icon: String, accent: Color) {
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
            return (name: urlString, icon: "globe", accent: Color.primary)
        }
        
        // Find the platform matching the host
        for (domain, platform) in platforms {
            if host.contains(domain) {
                return (name: platform.name, icon: platform.iconName, accent: platform.accent)
            }
        }
        
        return (name: urlString, icon: "globe", accent: Color.primary)
    }
    private func switchView(to view: ViewSelection = .profile) {
        if userViewModel.fetchedUser == nil {
            withAnimation(animation) {
                userViewModel.showScreen = false
            }
        }
        wait(for: userViewModel.fetchedUser == nil ? 0.91 : 0) {
            // Reset necessary state variables
            email = ""
            
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
                AddBioView {
                    switchView()
                } next: {
                    userViewModel.updateBio()
                    switchView()
                }
                .padding()
            case .email:
                AddEmailView(email: $email) {
                    switchView()
                } save: {
                    userViewModel.addEmail(email)
                    switchView()
                }
                .padding()
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
                    HStack(spacing: 8) {
                        if !userViewModel.isShared(user) {
                            Button {
                                withAnimation(.smooth) {
                                    userViewModel.isEditing.toggle()
                                }
                            } label: {
                                HStack(spacing: 9) {
                                    FAText("pen")
                                    Text(userViewModel.isEditing ? "Stop Editing" : "Edit")
                                }
                                .foregroundStyle(Color.accentColor)
                            }
                            .buttonStyle(SecondaryActionButtonStyle())
                        } else {
                            Button {
                                switchView(to: .profile) // This creates the animation
                                wait(for: 0.91) {
                                    userViewModel.fetchedUser = nil
                                }
                            } label: {
                                HStack(spacing: 9) {
                                    FAText("arrow-left")
                                    Text("Back to My Profile")
                                }
                            }
                            .buttonStyle(SecondaryActionButtonStyle())
                        }
                        Button {
                            AuthViewModel.shared.signOut()
                        } label: {
                            HStack(spacing: 9) {
                                FAText("arrow-right-from-bracket")
                                Text("Sign Out")
                            }
                            .foregroundStyle(.red)
                        }
                        .buttonStyle(SecondaryActionButtonStyle())
                    }
                    AvatarView(user: user, geo: geo)
                    VStack(spacing: 7) {
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
                            } else if userViewModel.isEditing {
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
                                .foregroundStyle(.gray)
                                .multilineTextAlignment(.center)
                        }
                    }
                    HStack(spacing: 12) {
                        if let phoneNumbers = user.phoneNumbers, !phoneNumbers.isEmpty {
                            Menu {
                                ForEach(phoneNumbers, id: \.self) { phoneNumber in
                                    ContactActionButton(phoneNumber, type: .phoneNumber)
                                }
                            } label: {
                                ContactRowView {
                                    FAText("phone", size: 23)
                                }
                            }
                        }
                        if let emails = user.emails, !emails.isEmpty {
                            Menu {
                                ForEach(emails, id: \.self) { email in
                                    ContactActionButton(email, type: .email)
                                }
                            } label: {
                                ContactRowView {
                                    FAText("envelope", size: 23)
                                }
                            }
                        }
                        if let url = URL(string: "https://openavatar.web.app/profile/\(user.uid)") {
                            let expanded = (user.emails == nil || (user.emails ?? []).isEmpty) && (user.phoneNumbers == nil || (user.phoneNumbers ?? []).isEmpty) // Show an expanded version if there aren't any sister buttons
                            
                            ShareLink(item: url) {
                                ContactRowView {
                                    HStack {
                                        FAText("share", size: 23)
                                        if expanded {
                                            Text("Share my profile")
                                                .font(.body.weight(.medium))
                                        }
                                    }
                                    .padding(.horizontal, expanded ? 16 : 0)
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
                                                FAText(platform.icon, size: platform.icon == "globe" ? 22 : 25)
                                                    .foregroundStyle(platform.accent)
                                                    .frame(maxHeight: 35)
                                                    .frame(minWidth: 30)
                                                Text(platform.name)
                                                    .lineLimit(1)
                                                Spacer()
                                                if userViewModel.isEditing {
                                                    Button {
                                                        // TODO: add edit link logic
                                                    } label: {
                                                        FAText("pen", size: 16) // The pen icon appears bigger than the trash can, so keep it a little smaller
                                                            .padding(10)
                                                            .background(Color.blue)
                                                            .foregroundStyle(.white)
                                                            .clipShape(Circle())
                                                    }
                                                    Button(role: .destructive) {
                                                        // TODO: add confirmation
                                                        userViewModel.removeSocialLink(link)
                                                    } label: {
                                                        FAText("trash-can", size: 17)
                                                            .padding(10)
                                                            .background(Color.red)
                                                            .foregroundStyle(.white)
                                                            .clipShape(Circle())
                                                    }
                                                } else {
                                                    FAText("square-arrow-up-right", size: 17)
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: 39, alignment: .leading)
                                        }
                                        .buttonStyle(ListButtonStyle())
                                        Divider()
                                    }
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
                            if userViewModel.isEditing {
                                elementPrompt(for: .contactInfo)
                                elementPrompt(for: .socialAccounts)
                            }
                        }
                    }
                }
                .padding()
                .padding(.top, 20)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    var bioRow: some View {
        Group {
            if let bio = user.bio {
                VStack {
                    ZStack(alignment: .topTrailing) {
                        Group {
                            if isEditingBio {
                                TextEditor(text: $userViewModel.bio)
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
                                            .stroke(Color(.lightGray).opacity(0.2), lineWidth: 1)
                                    }
                            }
                        }
                        .multilineTextAlignment(.leading)
                        if !isEditingBio && userViewModel.isEditing {
                            Button {
                                haptic(style: .light)
                                
                                self.isBioFocused = true
                                self.userViewModel.bio = user.bio ?? ""
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
                                userViewModel.updateBio()
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
}

struct ContactActionButton: View {
    enum `Type` {
        case email
        case phoneNumber
    }
    
    @Environment(\.openURL) var openURL
    
    @ObservedObject var userViewModel = UserViewModel.shared
    
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
            // Edit button?
            if userViewModel.isEditing {
                Button(role: .destructive) {
                    haptic(style: .light)
                    
                    // TODO: add confirmation
                    
                    if type == .email {
                        userViewModel.removeEmail(string)
                    } else {
                        userViewModel.removePhoneNumber(string)
                    }
                } label: {
                    Label("Remove", systemImage: "trash")
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
