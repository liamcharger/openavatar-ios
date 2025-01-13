//
//  AuthViewModel.swift
//  OpenID
//
//  Created by Liam Willey on 1/11/25.
//

import FirebaseAuth
import Firebase
import FirebaseFirestore
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    @Published var didAuthenticateUser = false
    @Published var isLoading = true
    
    private var tempUserSession: FirebaseAuth.User?
    
    static let shared = AuthViewModel()
    
    init() {
        self.userSession = Auth.auth().currentUser
        self.fetchCurrentUser()
    }
    
    func login(email: String, password: String, completion: @escaping(Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error logging in user: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            guard let user = result?.user else { return }
            
            self.userSession = user
            self.fetchCurrentUser()
            
            completion(nil)
        }
    }
    
    func register(firstname: String, lastname: String, email: String, nickname: String, bio: String, password: String, completion: @escaping(Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error registering user: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            guard let user = result?.user else { return }
            self.tempUserSession = user
            
            var data: [String : Any] = [
                "email": email,
                "shareId": user.uid.prefix(7),
                "nickname": nickname
            ]
            
            // We need to append these fields separately because they won't be nil, and we don't want to save a blank string when a property should be nil
            if !firstname.isEmpty && !lastname.isEmpty {
                data["firstName"] = firstname
                data["lastName"] = lastname
            }
            if !bio.isEmpty {
                data["bio"] = bio
            }
            
            Firestore.firestore().collection("users").document(user.uid)
                .setData(data) { _ in
                    self.didAuthenticateUser = true
                    self.userSession = self.tempUserSession
                    self.fetchCurrentUser()
                    
                    completion(nil)
                }
        }
    }
    
    func fetchCurrentUser() {
        guard let uid = userSession?.uid else {
            isLoading = false
            return
        }
        
        Firestore.firestore().collection("users")
            .document(uid)
            .addSnapshotListener { snapshot, error in // Use a snapshot listener so we don't constantly have to fetch the user
                guard let snapshot = snapshot else { return }
                guard let user = try? snapshot.data(as: User.self) else { return }
                
                self.currentUser = user
                self.isLoading = false
            }
    }
    
    func signOut() {
        self.userSession = nil
        try? Auth.auth().signOut()
    }
    
    func resetPassword(email: String, completion: @escaping(Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            completion(error)
        }
    }
}

