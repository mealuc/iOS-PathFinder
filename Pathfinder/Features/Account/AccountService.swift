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
    static func logout(accountModel: AccountModel, historyService: HistoryService, completion: @escaping (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            historyService.clearHistory()
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
    @Published var userFavorites: [Favorite] = []
    
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    private var favoriteListener: ListenerRegistration? = nil
    private var authStateListener: AuthStateDidChangeListenerHandle? = nil
    
    func favoriteKey (userId: String, storeId: String, productId: String) -> String {
        return "\(userId)#\(storeId)#\(productId)"
    }
    
    init() {
        authStateListener = Auth.auth().addStateDidChangeListener{ [weak self] _, user in
            guard let self = self else { return }
            
            if user != nil {
                self.startListeningFavorites()
            } else {
                self.userFavorites = []
            }
        }
    }
    
    func startListeningFavorites() {
        guard let userId = currentUserId else { return }
        
        favoriteListener?.remove()
        
        favoriteListener = db.collection("favorites").whereField("userId", isEqualTo: userId).addSnapshotListener { [weak self] querySnapshot, error in
            guard let self = self else { return }
            if let snapshot = querySnapshot {
                self.userFavorites = snapshot.documents.compactMap{
                    try? $0.data(as: Favorite.self)
                }
            }
        }
    }
    
    func addFavorite (storeId: String, productId: String, stockQuantity: Int, productPrice: Double, storeRating: Double, storeName: String, productName: String) async throws -> String {
        do {
            guard let userId = currentUserId else { return "" }
            
            let documentId = favoriteKey(userId: userId, storeId: storeId, productId: productId)
            
            let favoriteData = Favorite(
                id: documentId,
                userId: userId,
                storeId: storeId,
                productId: productId,
                stockQuantity: stockQuantity,
                productPrice: productPrice,
                storeRating: storeRating,
                storeName: storeName,
                productName: productName
            )
            
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
                userFavorites = []
                return
            }
            
            let query = try await db.collection("favorites").whereField("userId", isEqualTo: userId).getDocuments()
            
            userFavorites = query.documents.compactMap { doc in
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

class HistoryService: ObservableObject {
    @Published var history: [ViewedItem] = []
    
    private let key = "viewed_history"
    
    func historyKey (for uid: String) -> String {
        return "viewed_history_\(uid)"
    }
    
    func getHistory(for uid: String) {
        let key = historyKey(for: uid)
        
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([ViewedItem].self, from: data) {
            self.history = decoded
        } else {
            self.history = []
        }
    }
    
    func addToHistory(uid: String, productId: String, storeId: String, productName: String, storeName: String, stockPrice: Double) {
        
        let historyItem = ViewedItem(
            id: UUID().uuidString,
            productId: productId,
            storeId: storeId,
            productName: productName,
            storeName: storeName,
            stockPrice: stockPrice,
            viewedAt: Date()
        )
        
        getHistory(for: uid)

        history.insert(historyItem, at: 0)
        
        if history.count > 20 {
            history.removeLast()
        }
        
        saveHistory(for: uid)
    }
    
    func saveHistory(for uid: String) {
        let key = historyKey(for: uid)
        
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func clearHistory(){
        history = []
    }
}
