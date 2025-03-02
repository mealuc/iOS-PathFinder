//
//  LoginService.swift
//  Pathfinder
//
//  Created by EmreAluc on 29.01.2025.
//

import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

class AuthService {
    @EnvironmentObject var loginModel: LoginModel
    //User authantication area
    static func userLoginAuthanticate(email: String , password: String, loginModel: LoginModel, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            guard error == nil else {
                print("Error occured while sign in!: \(error!.localizedDescription)")
                loginModel.errorMessage = "\(error!.localizedDescription)"
                completion(false)
                return
            }
            print("User signed in successfully!")
            completion(true)
        }
    }
}
