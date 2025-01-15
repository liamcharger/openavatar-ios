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
    @Published var isLoadingAvatar = false
    @Published var showError = false
    @Published var showScreen = false
    @Published var selectedImage: UIImage?
    
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
    
    func saveAvatar() {
        guard let image = selectedImage else { return }
        
        if let rep = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(rep, forKey: "profileImage")
        }
    }
    
    func getAvatar() -> UIImage? {
        if let imageData = UserDefaults.standard.object(forKey: "profileImage") as? Data,
            let image = UIImage(data: imageData) {
            return image
        }
        return nil
    }
    
    private func removeAvatarFromStorage(_ user: User) {
        if let avatarURL = user.avatarURL {
            Storage.storage().reference(forURL: avatarURL).delete { error in
                if let error {
                    print(error.localizedDescription)
                    return
                }
            }
        }
    }
    
    private func removeAvatarFromFirestore(_ user: User) {
        Firestore.firestore().collection("users").document(user.uid)
            .updateData(["avatarURL": FieldValue.delete()]) { error in
                if let error {
                    print(error.localizedDescription)
                    return
                }
            }
    }
    
    func removeAvatar(_ user: User) {
        removeAvatarFromStorage(user)
        removeAvatarFromFirestore(user)
    }
    
    func uploadAvatar(_ user: User) {
        isLoadingAvatar = true
        
        guard let image = selectedImage else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let imageId = UUID().uuidString
        let ref = Storage.storage().reference().child("images/\(imageId)")
        
        removeAvatarFromStorage(user)
        
        ref.putData(imageData, metadata: nil) { metadata, error in
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
                    print(error.localizedDescription)
                    return
                }
                
                Firestore.firestore().collection("users").document(self.uid).updateData(["avatarURL": url]) { error in
                    if let error {
                        print(error.localizedDescription)
                    }
                    
                    self.saveAvatar()
                    self.selectedImage = nil
                    self.isLoadingAvatar = false
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
