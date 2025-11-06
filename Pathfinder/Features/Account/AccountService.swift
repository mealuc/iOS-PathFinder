//
//  AccountService.swift
//  Pathfinder
//
//  Created by EmreAluc on 12.02.2025.
//

import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

class AccountService {
    @EnvironmentObject var accountModel: AccountModel
    //User Logout area
    static func logout(accountModel: AccountModel, completion: @escaping (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            print("User signed out succesfully!")
            completion(true)
            
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
            accountModel.errorMessage = "\(signOutError.localizedDescription)"
            completion(false)
        }
    }
    
    static func getUserData(user: User, accountModel: AccountModel) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
       db.collection("users").document(userID).getDocument { document, e in
            if let error = e {
                print("Error getting user data: \(error)")
                accountModel.errorMessage = "\(error.localizedDescription)"
                return
            }
            if let document = document, document.exists {
                let documentData = document.data()
                DispatchQueue.main.async {
                    user.name = documentData?["name"] as? String ?? "Kullanıcı"
                    user.surname = documentData?["surname"] as? String ?? ""
                } // We use DispatchQueue because we want ui processes on main thread (all of ui proccesses must processed on main thread if not app will freeze)
            }
        }
    }
}
