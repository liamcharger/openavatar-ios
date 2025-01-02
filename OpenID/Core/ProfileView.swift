//
//  ProfileView.swift
//  OpenID
//
//  Created by Liam Willey on 1/1/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var showPronunciation = false
//    @State private var showFullBio = false
    
    let user: User
    let shared: Bool
    
    func placeholderAvatar(width: CGFloat) -> some View {
        @State var pulse = true
        
        return Circle()
            .foregroundStyle(Color.gray.opacity(pulse ? 0.6 : 0.2))
            .frame(width: width)
            .onAppear {
                withAnimation(.smooth.repeatForever()) {
                    pulse.toggle() // There's a better way to do this using only one-line modifiers
                }
            }
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
                        Text("Shared to You")
                            .padding(9)
                            .padding(.horizontal, 3)
                            .font(.system(size: 14).weight(.medium))
                            .foregroundStyle(Color.primary.opacity(0.85))
                            .background(Material.regular)
                            .clipShape(Capsule())
                        if let avatarURL = user.avatarURL, let url = URL(string: avatarURL) {
                            // AsyncImage or should we use Kingfisher?
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
                            Image(.avatar) // Replace with placeholder background
                                .resizable()
                                .aspectRatio(contentMode: .fit) // Preserve aspect ratio
                                .frame(width: geo.size.width / 2.8)
                                .clipShape(Circle())
                        }
                        VStack(spacing: 5) {
                            HStack(spacing: 12) {
                                Text(user.fullname)
                                    .font(.system(size: 28, design: .monospaced).weight(.bold))
                                if let pronunciation = user.pronunciation {
                                    Menu {
                                        // Temporary substitute for popover
                                        Text(pronunciation)
                                        
                                        // self.showPronunciation = true
                                    } label: {
                                        Image(systemName: "person.wave.2.fill")
                                            .font(.system(size: 24))
                                    }
                                    /*
                                    .popover(isPresented: $showPronunciation, attachmentAnchor: .point(.top)) {
                                        Text(pronunciation)
                                    }
                                     */
                                }
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
                                .font(.system(size: 20))
                                .foregroundStyle(.gray)
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
                                Button {
                                    print(phoneNumber) // Call or copy phone number
                                } label: {
                                    ContactRowView(label)
                                }
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
                                Button {
                                    print(email) // Open in client or copy email address
                                } label: {
                                    ContactRowView(label)
                                }
                            }
                        }
                        if !shared {
                            Button {
                                
                            } label: {
                                ContactRowView(FAText(iconName: "share", size: 23))
                            }
                        }
                    }
                    VStack(spacing: 15) {
                        if let bio = user.bio {
                            ZStack(alignment: .bottom) {
                                Text(bio)
                                    .padding(15)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Material.thin)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
//                                    .lineLimit(showFullBio ? nil : 4)
                                // We need a way to conditionally show the button, in case the bio is not long enough to truncate
//                                if !showFullBio {
//                                    Button {
//                                        showFullBio = true
//                                    } label: {
//                                        HStack(spacing: 6) {
//                                            Image(systemName: "chevron.down")
//                                            Text("Show More")
//                                        }
//                                        .font(.body.weight(.bold))
//                                        .padding(6)
//                                        .padding(.horizontal, 3)
//                                        .overlay {
//                                            RoundedRectangle(cornerRadius: 12)
//                                                .stroke(Color.accentColor, lineWidth: 3)
//                                        }
//                                    }
//                                    .offset(y: 43)
//                                }
                            }
//                            .padding(.bottom, showFullBio ? 0 : 52)
                        }
                    }
                }
                .padding()
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
    
    let string: String
    let type: `Type`
    
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
                // Execute appropriate action
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
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    NavigationView {
        ProfileView(User.user, shared: false)
    }
}
