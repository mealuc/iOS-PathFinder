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
import UIKit
import GoogleSignIn

class AuthService {
    @EnvironmentObject var loginModel: LoginModel
    //User authantication area
    func userLoginAuthanticate(email: String , password: String, loginModel: LoginModel, completion: @escaping (Bool) -> Void) {
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
    
    func signInWithGoogle(completion: @escaping (Bool) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Client ID not found")
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let rootVC = UIApplication.shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene})
            .first?
            .windows
            .first?
            .rootViewController else {
            print("rootViewController not found!")
            completion(false)
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            if let error = error {
                print("Google Sign-In hata:", error.localizedDescription)
                completion(false)
                return
            }
            guard
                let user = result?.user,
                let idToken = user.idToken?.tokenString
            else {
                print("❌ Google user or token not exist")
                completion(false)
                return
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase Auth Error: ", error.localizedDescription)
                    completion(false)
                    return
                }
                
                completion(true)
                print("Successfully login with Google!",
                      authResult?.user.email ?? "❌ No email exist")
                
            }
        }
    }
}
