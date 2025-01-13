//
//  UserViewModel.swift
//  Openavatar
//
//  Created by Liam Willey on 1/13/25.
//

import Foundation
import FirebaseFirestore

class UserViewModel: ObservableObject {
    static let shared = UserViewModel()
    
    @Published var fetchedUser: User?
    @Published var isLoading = false
    
    func fetchUser(with uid: String) {
        isLoading = true
        
        Firestore.firestore().collection("users")
            .document(uid)
            .getDocument { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard let user = try? snapshot.data(as: User.self) else { return }
                
                self.fetchedUser = user
                self.isLoading = false
            }
    }
}
