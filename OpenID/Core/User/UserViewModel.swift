//
//  UserViewModel.swift
//  OpenID
//
//  Created by Liam Willey on 1/13/25.
//

import Foundation
import FirebaseFirestore

class UserViewModel: ObservableObject {
    static let shared = UserViewModel()
    
    @Published var fetchedUser: User?
    @Published var isLoading = false
    
    func fetchUser(with shareId: String) {
        isLoading = true
        
        Firestore.firestore().collection("users")
            .document(shareId) // FIXME: this method won't work until we find a way to search for IDs starting with the `shareId`
            .getDocument { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard let user = try? snapshot.data(as: User.self) else { return }
                
                self.fetchedUser = user
                self.isLoading = false
            }
    }
}
