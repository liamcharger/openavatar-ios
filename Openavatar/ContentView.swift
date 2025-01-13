//
//  ContentView.swift
//  Openavatar
//
//  Created by Liam Willey on 1/1/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var userViewModel = UserViewModel.shared
    
    var body: some View {
        NavigationView {
            Group {
                if authViewModel.isLoading || userViewModel.isLoading {
                    LoadingView()
                } else if authViewModel.userSession == nil {
                    OnboardingView()
                } else if let user = userViewModel.fetchedUser {
                    ProfileView(user)
                } else {
                    MyProfileView()
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
