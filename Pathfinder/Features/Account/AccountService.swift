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

@MainActor
class FavoriteService: ObservableObject {
    @Published var favorites: [Favorite] = []
    
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    func favoriteKey (userId: String, storeId: String, productId: String) -> String {
        return "\(userId)#\(storeId)#\(productId)"
    }
    
    func addFavorite (storeId: String, productId: String) async throws -> String {
        do {
            guard let userId = currentUserId else { return "" }
            
            let documentId = favoriteKey(userId: userId, storeId: storeId, productId: productId)
            
            let favoriteData = Favorite(id: documentId, userId: userId, storeId: storeId, productId: productId)
            
            try db.collection("favorites").document(documentId).setData(from: favoriteData)
            
            return documentId
            
        } catch {
            print("Error adding favorite: \(error)")
            throw error
        }
    }
    
    func fetchUserFavorites() async throws {
        do {
            guard let userId = currentUserId else {
                favorites = []
                return
            }
            
            let query = try await db.collection("favorites").whereField("userId", isEqualTo: userId).getDocuments()
            
            favorites = query.documents.compactMap { doc in
                try? doc.data(as: Favorite.self)
            }
        } catch {
            print("Error when fetching favorites: \(error)")
            throw error
        }
        
    }
    
    func removeFavorite(storeId: String, productId: String) async throws -> String {
        do {
            guard let userId = currentUserId else { return "" }
            
            let documentId = favoriteKey(userId: userId, storeId: storeId, productId: productId)
            
            try await db.collection("favorites").document(documentId).delete()
            
            return documentId
            
        } catch {
            print("Error when deleting favorite: \(error)")
            throw error
        }
        
    }
}
