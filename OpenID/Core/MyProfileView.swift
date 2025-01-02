//
//  MyProfileView.swift
//  OpenID
//
//  Created by Liam Willey on 1/2/25.
//

import SwiftUI

struct MyProfileView: View {
    let user = User.user
    
    var body: some View {
        ProfileView(user, shared: false)
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        MyProfileView()
    }
}
