//
//  RegisterService.swift
//  Pathfinder
//
//  Created by EmreAluc on 29.01.2025.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

let db = Firestore.firestore()

class RegisterService {
    @EnvironmentObject var registerModel: RegisterModel
    // User register area
    static func userRegister(user: User, registerModel: RegisterModel) {
        Auth.auth().createUser(withEmail: user.email, password: user.password) { authResult, error in
            guard error == nil else {
                print("Error occured while registered!: \(error?.localizedDescription)")
                registerModel.errorMessage = "\(error!.localizedDescription)"
                return
            }
            
            guard let userID = authResult?.user.uid else { return }
            
            let userData: [String: Any] = [
                "name": user.name,
                "surname": user.surname,
                "username": user.username,
                "email": user.email,
                "password": user.password,
                "birthdate": user.birthdate,
                "createdAt": Timestamp()
            ]
            
            db.collection("users").document(userID).setData(userData) { error in
                if let e = error {
                    print("Error occured while user's data registered!: \(e.localizedDescription)")
                    registerModel.errorMessage = "\(e.localizedDescription)"
                    return
                } else {
                    print("User registered successfully!")
                }
            }
        }
    }
}
