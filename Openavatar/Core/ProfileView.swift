//
//  ProfileView.swift
//  Openavatar
//
//  Created by Liam Willey on 1/1/25.
//

import SwiftUI
import Kingfisher

struct ProfileView: View {
    private enum ViewSelection: Int, CaseIterable {
        case profile
        case name
        case bio
        case contactInfo
        case links
        case pronunciation
        case pronouns
        case job
    }
    
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var userViewModel = UserViewModel.shared
    
    @State private var showPronunciation = false
    @State private var profileImage: UIImage?
    @State private var showProfileImagePicker = false
    @State private var hasCompletedInitalAnimation = false
    @State private var showScreen = false
    
    @State private var currentScreen: ViewSelection = .profile
    
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
    
    private func isShared() -> Bool {
        #if DEBUG
        return false
        #else
        if let uid = AuthViewModel.shared.userSession?.uid, uid == user.id {
            return false
        }
        return true
        #endif
    }
    private func placeholderAvatar(width: CGFloat) -> some View {
        return Group {
            if let profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .opacity(0.6) // This view will only be shown while the image is uploading, so we add some opacity so the ProgressView is visible
            } else {
                Circle()
                    .foregroundStyle(Color.gray.opacity(0.2))
                    .background {
                        Circle()
                            .stroke(.gray.opacity(0.7), lineWidth: 1)
                    }
            }
        }
        .frame(width: width, height: width)
    }
    private func addButton(for element: ViewSelection) -> some View {
        Button {
            switch element {
            case .name:
                // TODO: add fullname
                break
            case .pronouns:
                // TODO: add pronouns
                break
            case .job:
                // TODO: add job
                break
            default:
                // TODO: add pronunciation
                break
            }
        } label: {
            HStack(spacing: 6) {
                FAText(iconName: "plus", size: 19)
                Text({
                    switch element {
                    case .name:
                        return "Add Name"
                    case .pronouns:
                        return "Add Pronouns"
                    case .job:
                        return "Add Job"
                    default:
                        return "Add Pronunciation"
                    }
                }())
            }
            .padding(8)
            .padding(.horizontal, 2)
            .foregroundStyle(.white)
            .background(Color.blue.gradient) // Should we use plain .blue or its gradient form
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    private func elementPrompt(for element: ViewSelection) -> some View {
        Group {
            // We don't want to show any prompts if the profile has been shared
            if !isShared() {
                Button {
                    haptic(style: .list)
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
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(.lightGray).opacity(0.35), lineWidth: 1)
                }
            }
        }
    }
    private func getSocialPlatform(from urlString: String) -> (name: String, icon: String?) {
        let iconVariant = (colorScheme == .dark ? "_light" : "_dark")
        
        let platforms: [String: (name: String, iconName: String)] = [
            "github.com": ("GitHub", "GitHub\(iconVariant)"),
            "stackoverflow.com": ("Stack Overflow", "stackoverflowIcon"),
            "twitter.com": ("Twitter", "twitterIcon"),
            "facebook.com": ("Facebook", "facebookIcon"),
            "linkedin.com": ("LinkedIn", "linkedinIcon"),
            "instagram.com": ("Instagram", "instagramIcon"),
            "youtube.com": ("YouTube", "youtubeIcon"),
            "reddit.com": ("Reddit", "redditIcon")
        ]
        
        // TODO: add a check when urls are added to remove https
        let urlString = "https://" + urlString
        guard let url = URL(string: urlString),
              let host = url.host?.lowercased() else {
            return (name: urlString, icon: nil)
        }
        
        // Find the platform matching the host
        for (domain, platform) in platforms {
            if host.contains(domain) {
                return (name: platform.name, icon: platform.iconName)
            }
        }
        
        return (name: urlString, icon: nil)
    }
    private func switchView(to view: ViewSelection = .profile) {
        withAnimation(animation) {
            showScreen = false
        }
        wait(for: 0.9) {
            currentScreen = view
            withAnimation(animation) {
                showScreen = true
                hasCompletedInitalAnimation = true
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
                    .scaleEffect(showScreen ? 1 : 1.1)
            case .bio:
                addBio
            default:
                EmptyView()
            }
        }
        .disabled(!showScreen)
        .opacity(showScreen ? 1 : 0)
        .onAppear {
            switchView()
        }
    }
    
    var profile: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 30) {
                    if isShared() {
                        Text("Shared to You")
                            .padding(9)
                            .padding(.horizontal, 3)
                            .font(.system(size: 14).weight(.medium))
                            .background {
                                Capsule()
                                    .stroke(Color.primary, lineWidth: 2)
                            }
                    }
                    VStack(spacing: 14) {
                        let size = min(200, geo.size.width / 2.8)
                        
                        if let avatarURL = user.avatarURL, let url = URL(
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
                                .frame(width: size)
                                .clipShape(Circle())
                        } else {
                            Button {
                                showProfileImagePicker = true
                            } label: {
                                placeholderAvatar(width: size)
                                    .overlay {
                                        if profileImage != nil {
                                            ProgressView()
                                                .tint(.white)
                                        } else if !isShared() {
                                            VStack(spacing: 7) {
                                                FAText(iconName: "camera", size: 28)
                                                Text("Add Photo")
                                                    .font(
                                                        .system(size: 17)
                                                        .weight(.medium)
                                                    )
                                            }
                                            .foregroundStyle(.gray.opacity(0.9))
                                        }
                                    }
                            }
                            .disabled(isShared())
                            .frame(width: size, height: size)
                            .sheet(isPresented: $showProfileImagePicker, onDismiss: {
                                if let profileImage {
                                    userViewModel.uploadProfileImage(image: profileImage)
                                }
                            }) {
                                ImagePicker(selectedImage: $profileImage)
                            }
                        }
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
                                } else if !isShared() {
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
                                                .padding(3)
                                                .foregroundStyle(.white)
                                                .background(Color.blue)
                                                .clipShape(Circle())
                                                .overlay {
                                                    Circle()
                                                        .stroke(Color(.systemBackground), lineWidth: 5)
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
                    }
                    HStack(spacing: 12) {
                        if let phoneNumbers = user.phoneNumbers, !phoneNumbers.isEmpty {
                            let label = FAText(iconName: "phone", size: 23)
                            
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
                                        label
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
                            let label = FAText(iconName: "envelope", size: 23)
                            
                            if emails.count > 1 {
                                Menu {
                                    ForEach(emails, id: \.self) { email in
                                        ContactActionButton(email, type: .email)
                                    }
                                } label: {
                                    ContactRowView {
                                        label
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
                                        FAText(iconName: "share", size: 23)
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
                        if let bio = user.bio {
                            Button {
                                
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    Text(bio)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                        .padding(13)
                                        .foregroundStyle(Color.primary)
                                        .background(Color.materialGray)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .background {
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color(.lightGray).opacity(0.35), lineWidth: 1)
                                        }
                                    Button {
                                        haptic(style: .light)
                                        switchView(to: .bio)
                                    } label: {
                                        FAText(iconName: "pen", size: 16)
                                            .padding(9)
                                            .foregroundStyle(Color.white)
                                            .background(Color.blue)
                                            .clipShape(Circle())
                                            .offset(x: 9, y: -9)
                                    }
                                }
                            }
                        }
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
                                            guard let url = URL(string: link) else { return }
                                            
                                            haptic(style: .list)
                                            UIApplication.shared.open(url)
                                        } label: {
                                            HStack(spacing: 10) {
                                                Group {
                                                    if let icon = platform.icon {
                                                        Image(icon)
                                                            .resizable()
                                                            .scaledToFit()
                                                    } else {
                                                        FAText(iconName: "link", size: 18)
                                                            .foregroundStyle(Color.primary)
                                                    }
                                                }
                                                .frame(width: 35, height: 35)
                                                .background(platform.icon == nil ? Color.gray.opacity(0.4) : .clear)
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                Text(platform.name)
                                                    .lineLimit(1)
                                                Spacer()
                                                FAText(iconName: "square-arrow-up-right", size: 17)
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
                            if user.firstname == nil && user.lastname == nil {
                                elementPrompt(for: .name)
                            }
                            if user.pronouns == nil {
                                elementPrompt(for: .pronouns)
                            }
                            if user.job == nil {
                                elementPrompt(for: .job)
                            }
                            if user.bio == nil {
                                elementPrompt(for: .bio)
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
                // TODO: test on iPad
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    var addBio: some View {
        VStack {
            Button("Back") {
                switchView()
            }
            Button("Update Bio") {
                userViewModel.updateBio("""
                                        Developer, a.k.a nerd
                                        PineTime enthusiast
                                        """)
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
                haptic(style: .list)
                UIPasteboard.general.string = string
            } label: {
                Label("Copy", systemImage: "doc.on.clipboard")
            }
            Button {
                haptic(style: .list)
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
