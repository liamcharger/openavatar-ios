//
//  ContentView.swift
//  OpenID
//
//  Created by Liam Willey on 1/1/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            if authViewModel.isLoading {
                ProgressView()
            } else if authViewModel.userSession == nil {
                OnboardingView()
            } else {
                MyProfileView()
            }
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    ContentView()
}
