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
    
    func login(withEmail email: String, password: String, completion: @escaping(Error?) -> Void) {
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
    
    func register(withEmail email: String, password: String, username: String, fullname: String, completion: @escaping(Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error registering user: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            guard let user = result?.user else { return }
            self.tempUserSession = user
            
            let data = [
                "email": email,
                "username": username.lowercased(),
                "fullname": fullname
            ]
            
            Firestore.firestore().collection("users").document(user.uid)
                .setData(data) { _ in
                    self.didAuthenticateUser = true
                    self.userSession = self.tempUserSession
                    self.fetchCurrentUser()
                    
                    completion(nil)
                }
        }
    }
    
    func updateUser(email: String, username: String, fullname: String, completion: @escaping(Error?) -> Void) {
        self.userSession?.sendEmailVerification(beforeUpdatingEmail: email) { error in
            if let error = error {
                completion(error)
                return
            }
            
            guard let user = self.userSession else { return }
            
            let data = ["email": email,
                        "username": username.lowercased(),
                        "fullname": fullname]
            
            Firestore.firestore().collection("users").document(user.uid)
                .updateData(data) { error in
                    self.fetchCurrentUser()
                    
                    completion(error)
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
            .addSnapshotListener { snapshot, error in // We want to use a snapshot listener so we don't constantly have to fetch the user
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

