//
//  MyProfileView.swift
//  OpenID
//
//  Created by Liam Willey on 1/2/25.
//

import SwiftUI

struct MyProfileView: View {
    @ObservedObject var authViewModel = AuthViewModel.shared
    
    var body: some View {
        if let user = authViewModel.currentUser {
            ProfileView(user)
                .navigationTitle("My Profile")
                .navigationBarTitleDisplayMode(.inline)
        } else {
            ErrorView(message: "There was an error processing your request.")
        }
    }
}

#Preview {
    NavigationView {
        MyProfileView()
    }
}
