//
//  ProfileView.swift
//  Openavatar
//
//  Created by Liam Willey on 1/1/25.
//

import SwiftUI

enum ProfileElement: Int {
    case name
}

struct ProfileView: View {
    @State private var showPronunciation = false
    
    let user: User
    
    var subtitle: String? {
        var result: String = ""
        let isNicknameSubtitle = (user.firstname != nil && user.lastname != nil)
        
        if isNicknameSubtitle {
            result += user.nickname
        }
        if let pronouns = user.pronouns {
            result += " • \(pronouns)"
        }
        
        return result.isEmpty ? nil : result
    }
    
    func isShared() -> Bool {
        if let uid = AuthViewModel.shared.userSession?.uid, uid == user.id {
            return false
        }
        return true
    }
    func placeholderAvatar(width: CGFloat, animate: Bool = true) -> some View {
        @State var pulse = false
        
        return Circle()
            .foregroundStyle(Color.gray.opacity(pulse ? 0.8 : 0.2))
            .animation(.smooth(duration: 1).repeatForever(autoreverses: true), value: pulse)
    }
    func addElement(for element: ProfileElement, completion: @escaping() -> Void) -> some View {
        Button {
            completion()
        } label: {
            HStack {
                
            }
        }
        .buttonStyle(ListButtonStyle())
    }
    
    init(_ user: User) {
        self.user = user
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 22) {
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
                        let size = min(200, geo.size.width / 2.8)
                        if let avatarURL = user.avatarURL, let url = URL(string: avatarURL) {
                            // Does AsyncImage work well or should we use Kingfisher?
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit) // Preserve aspect ratio
                                    .frame(width: size)
                                    .clipShape(Circle())
                            } placeholder: {
                                placeholderAvatar(width: size)
                            }
                        } else {
                            Button {
                                // TODO: add image and upload to cloud
                            } label: {
                                placeholderAvatar(width: size, animate: false)
                                    .overlay {
                                        VStack(spacing: 9) {
                                            FAText(iconName: "camera", size: 28)
                                            Text("Add Photo")
                                                .font(.system(size: 19).weight(.medium))
                                        }
                                    }
                            }
                            .frame(width: size, height: size)
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
                                    .font(.system(size: 28, design: .monospaced).weight(.bold))
                                if let pronunciation = user.pronunciation {
                                    Button {
                                         self.showPronunciation = true
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
                                    ForEach(phoneNumbers, id: \.self) { phoneNumber in
                                        ContactActionButton(phoneNumber, type: .phoneNumber)
                                    }
                                } label: {
                                    ContactRowView(label)
                                }
                            } else if let phoneNumber = phoneNumbers.first {
                                ContactActionButton(phoneNumber, type: .phoneNumber)
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
                                    ContactRowView(label)
                                }
                            } else if let email = emails.first {
                                ContactActionButton(email, type: .email)
                            }
                        }
                        if let url = URL(string: "https://openavatar.web.app/profile/\(user.uid)"), !isShared() {
                            ShareLink(item: url) {
                                ContactRowView(FAText(iconName: "share", size: 23))
                            }
                        }
                    }
                    VStack(spacing: 15) {
                        if let bio = user.bio {
                            Text(bio)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.materialGray)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        VStack(spacing: 0) {
                            Button {
                                
                            } label: {
                                HStack(spacing: 10) {
                                    RoundedRectangle(cornerRadius: 15)
                                        .frame(width: 35, height: 35)
                                    Text("GitHub")
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(ListButtonStyle())
                            Divider()
                            Button {
                                
                            } label: {
                                HStack(spacing: 10) {
                                    RoundedRectangle(cornerRadius: 15)
                                        .frame(width: 35, height: 35)
                                    Text("Stack Overflow")
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(ListButtonStyle())
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
                .padding()
                // TODO: test on iPad
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
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
                UIPasteboard.general.string = string
            } label: {
                Label("Copy", systemImage: "doc.on.clipboard")
            }
            Button {
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

struct ContactRowView: View {
    let icon: FAText
    
    init(_ icon: FAText) {
        self.icon = icon
    }
    
    var body: some View {
        icon
            .frame(width: 48, height: 48)
            .background(Color.blue)
            .foregroundStyle(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    NavigationView {
        ProfileView(User.user)
    }
}
