//
//  User.swift
//  OpenID
//
//  Created by Liam Willey on 1/1/25.
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    let uid: String
    let firstname: String?
    let lastname: String?
    let email: String // This is the email the user uses to log in, not to be publicly displayed
    let shareId: String // This is the ID that we use to fetch users when they're shared, since we don't the whole uid in a URL
    let nickname: String
    let pronunciation: String?
    let bio: String?
    let job: String?
    let pronouns: String?
    let avatarURL: String?
    let socialAccounts: [String]?
    let emails: [String]?
    let phoneNumbers: [String]?
    
    static var user: User {
        User(uid: "fjksldjfieojfjdsalfjksaldf", firstname: "Liam", lastname: "Willey", email: "email@example.com", shareId: "123456789", nickname: "liamcharger", pronunciation: "Lee-uhm Wil-lee", bio: "User bio goes here. User bio will go here. User bio goes here. User bio goes here. User bio goes here. Should the beautiful bio go here? User bio will go here.\n\nUser bio goes here. User bio definitely goes here. User bio goes here.", job: "Student Developer", pronouns: "he/him", avatarURL: nil /* Empty until we implement web images */, socialAccounts: nil, emails: ["email@example.com", "email2@gmail.com"], phoneNumbers: ["+1 (410)-746-7789", "+1 (710)-603-4001"])
    }
}
