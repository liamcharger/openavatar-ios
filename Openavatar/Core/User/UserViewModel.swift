//
//  UserViewModel.swift
//  Openavatar
//
//  Created by Liam Willey on 1/13/25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class UserViewModel: ObservableObject {
    static let shared = UserViewModel()
    
    @Published var fetchedUser: User?
    @Published var isLoading = false
    @Published var showError = false
    @Published var isLoadingProfilePicture = false
    
    @Published var errorMessage = ""
    
    var uid: String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    private func error(_ error: Error) {
        showError = true
        errorMessage = error.localizedDescription
    }
    
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
    
    func uploadProfileImage(image: UIImage) {
        isLoadingProfilePicture = true
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let imageId = UUID().uuidString
        let ref = Storage.storage().reference().child("images/\(imageId)")
        
        ref
            .putData(imageData, metadata: nil) { metadata, error in
                if let error {
                    // TODO: add user-facing error handling
                    print(error.localizedDescription)
                    return
                }
                
                ref.downloadURL { url, error in
                    guard let url = url?.absoluteString else {
                        print("Couldn't get the absolute string for the image URL.")
                        return
                    }
                    
                    if let error {
                        // TODO: add user-facing error handling
                        print(error.localizedDescription)
                        return
                    }
                    
                    Firestore.firestore().collection("users").document(self.uid).updateData(["avatarURL": url]) { error in
                        if let error {
                            // TODO: add user-facing error handling
                            print(error.localizedDescription)
                        }
                        
                        self.isLoadingProfilePicture = false
                        return
                    }
                }
            }
    }
    
    func updateBio(_ bio: String) {
        Firestore.firestore().collection("users").document(uid)
            .updateData(["bio": bio]) { error in
                if let error {
                    self.error(error)
                    return
                }
            }
    }
}
