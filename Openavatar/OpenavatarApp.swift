//
//  OpenavatarApp.swift
//  Openavatar
//
//  Created by Liam Willey on 1/1/25.
//

import SwiftUI
import Firebase

@main
struct OpenavatarApp: App {
    @StateObject var authViewModel = AuthViewModel.shared
    @StateObject var userViewModel = UserViewModel.shared
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .onOpenURL { url in
                    if authViewModel.userSession != nil {
                        let pathComponents = url.pathComponents
                        if let uid = pathComponents.last {
                            userViewModel.fetchUser(with: uid)
                        }
                    }
                }
        }
    }
}
