//
//  OpenIDApp.swift
//  OpenID
//
//  Created by Liam Willey on 1/1/25.
//

import SwiftUI
import Firebase

@main
struct OpenIDApp: App {
    @StateObject var authViewModel = AuthViewModel.shared
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
