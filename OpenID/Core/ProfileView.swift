//
//  ProfileView.swift
//  OpenID
//
//  Created by Liam Willey on 1/1/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var showPronunciation = false
    
    let user: User
    let shared: Bool
    
    func placeholderAvatar(width: CGFloat) -> some View {
        @State var pulse = true
        
        return Circle()
            .foregroundStyle(Color.gray.opacity(pulse ? 0.6 : 0.2))
            .frame(width: width)
            .onAppear {
                pulse.toggle()
            }
            .animation(.smooth.repeatForever(), value: pulse)
    }
    
    init(_ user: User, shared: Bool) {
        self.user = user
        self.shared = shared
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 22) {
                        if shared {
                            Text("Shared to You")
                                .padding(9)
                                .padding(.horizontal, 3)
                                .font(.system(size: 14).weight(.medium))
                                .foregroundStyle(Color.primary.opacity(0.85))
                                .background(Color.backgroundGray)
                                .clipShape(Capsule())
                        }
                        if let avatarURL = user.avatarURL, let url = URL(string: avatarURL) {
                            // Does AsyncImage work well or should we use Kingfisher?
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit) // Preserve aspect ratio
                                    .frame(width: geo.size.width / 2.8)
                                    .clipShape(Circle())
                            } placeholder: {
                                placeholderAvatar(width: geo.size.width / 2.8)
                            }
                        } else {
                            // Right now, this avatar image is a placeholder for testing
                            Image(.avatar)
                                .resizable()
                                .aspectRatio(contentMode: .fit) // Preserve aspect ratio
                                .frame(width: geo.size.width / 2.8)
                                .clipShape(Circle())
                        }
                        VStack(spacing: 5) {
                            HStack(spacing: 12) {
                                Text(user.firstname + " " + user.lastname)
                                    .font(.system(size: {
                                        #if os(watchOS)
                                        return 24
                                        #else
                                        return 27
                                        #endif
                                    }(), design: .monospaced).weight(.heavy))
                                #if os(iOS)
                                if let pronunciation = user.pronunciation {
                                    Button {
                                         self.showPronunciation = true
                                    } label: {
                                        Image(systemName: "person.wave.2.fill")
                                            .font(.system(size: 24))
                                    }
                                    .popover(isPresented: $showPronunciation, attachmentAnchor: .point(.bottom)) {
                                        VStack {
                                            Text(pronunciation)
                                        }
                                        .presentationCompactAdaptation(.popover)
                                    }
                                }
                                #endif
                            }
                            Text({
                                var result = ""
                                
                                if let nickname = user.nickname {
                                    result += nickname
                                }
                                if let pronouns = user.pronouns {
                                    result += " • \(pronouns)"
                                }
                                
                                return result
                            }())
                            .font(.system(size: 20.5))
                                .foregroundStyle(.gray)
                        }
                    }
                    #if os(iOS)
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
                        if !shared {
                            Button {
                                // TODO: add share backend
                            } label: {
                                ContactRowView(FAText(iconName: "share", size: 23))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    #endif
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
                        .background(Color.backgroundGray)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct ListButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .buttonStyle(.plain)
            .padding()
            .foregroundStyle(Color.primary)
            .background(configuration.isPressed ? Color.backgroundLightGray : Color.backgroundGray)
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
        let executeButton = Button {
            executeSocial()
        } label: {
            if type == .email {
                Label("Send Email", systemImage: "envelope")
            } else {
                Label("Call", systemImage: "phone")
            }
        }.buttonStyle(.plain)
        
        #if os(iOS)
        Menu(string) {
            Button {
                UIPasteboard.general.string = string
            } label: {
                Label("Copy", systemImage: "doc.on.clipboard")
            }
            executeButton
        }
        #elseif os(watchOS)
        executeButton
        #endif
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
        ProfileView(User.user, shared: false)
    }
}
