//
//  DatabaseManager.swift
//  Messenger
//
//  Created by 임정우 on 2021/05/14.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()

}

// MARK: - Account Management

extension DatabaseManager {
    
    public func uesrExists(with email: String,
                           completion: @escaping ((Bool) -> Void)) {
        
        database.child(email).observeSingleEvent(of: .value) { snapshot in
            
            guard snapshot.value as? String != nil else {
                
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    /// Inserts new user to database
    public func insertUser(with user: ChatAppUser) {
        
        database.child(user.emailAddress).setValue([
            "nick_name": user.nickName,
        ])
    }
}
struct ChatAppUser {
    let nickName: String
    let emailAddress: String
//    let profilePictureURL: String
}
