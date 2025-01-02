//
//  User.swift
//  OpenID
//
//  Created by Liam Willey on 1/1/25.
//

import Foundation

struct User: Identifiable, Codable {
    var id = UUID()
    let fullname: String
    let nickname: String?
    let pronunciation: String?
    let bio: String?
    let job: String?
    let pronouns: String?
    let avatarURL: String?
    let socialAccounts: [String]?
    let emails: [String]?
    let phoneNumbers: [String]?
    
    static var user: User {
        User(fullname: "Liam Willey", nickname: "liamcharger", pronunciation: "Lee-uhm Wil-lee", bio: "User bio goes here. User bio will go here. User bio goes here. User bio goes here. User bio goes here. Should the beautiful bio go here? User bio will go here.\n\nUser bio goes here. User bio definitely goes here. User bio goes here.", job: "Student Developer", pronouns: "he/him", avatarURL: nil /* Empty until we implement web images */, socialAccounts: nil, emails: ["liamwilley10@icloud.com", "chargerelectronics@gmail.com"], phoneNumbers: ["+1 (410)-755-7079", "+1 (310)-691-4068"])
    }
}
