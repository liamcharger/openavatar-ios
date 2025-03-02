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
    @Published var isEditing = false
    @Published var isLoading = false
    @Published var isLoadingAvatar = false
    @Published var showError = false
    @Published var showScreen = false
    @Published var selectedImage: UIImage?
    
    @Published var errorMessage = ""
    @Published var bio = ""
    
    var uid: String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    func isShared(_ user: User) -> Bool {
#if DEBUG
        return false
#else
        if uid == user.id {
            return false
        }
        return true
#endif
    }
    
    func isEmailValid(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        return emailPredicate.evaluate(with: email)
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
                    
                    self.selectedImage = nil
                    self.isLoadingAvatar = false
                    return
                }
            }
        }
    }
    
    func addEmail(_ email: String) {
        Firestore.firestore().collection("users").document(uid)
            .updateData(["emails": FieldValue.arrayUnion([email])]) { error in
                if let error {
                    self.error(error)
                }
            }
    }
    
    func removeEmail(_ email: String) {
        Firestore.firestore().collection("users").document(uid)
            .updateData(["emails": FieldValue.arrayRemove([email])]) { error in
                if let error {
                    self.error(error)
                }
            }
    }
    
    func removePhoneNumber(_ phoneNumber: String) {
        Firestore.firestore().collection("users").document(uid)
            .updateData(["phoneNumbers": FieldValue.arrayRemove([phoneNumber])]) { error in
                if let error {
                    self.error(error)
                }
            }
    }
    
    func removeSocialLink(_ socialAccount: String) {
        Firestore.firestore().collection("users").document(uid)
            .updateData(["socialAccounts": FieldValue.arrayRemove([socialAccount])]) { error in
                if let error {
                    self.error(error)
                }
            }
    }
    
    func updateBio() {
        Firestore.firestore().collection("users").document(uid)
            .updateData(["bio": bio.isEmpty ? FieldValue.delete() : bio]) { error in
                if let error {
                    self.error(error)
                }
            }
    }
}
