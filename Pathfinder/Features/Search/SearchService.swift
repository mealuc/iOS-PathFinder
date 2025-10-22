import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import SwiftUI
import Foundation /* Necessary for uuidString func */

class StoreService: ObservableObject {
    @Published var stores: [Store] = []
    
    private let db = Firestore.firestore()
    
    func fetchStores() {
        db.collection("stores").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching stores: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else { return }
            self.stores = documents.compactMap { document in
                try? document.data(as: Store.self)
            }
        }
    }
}

class AddStores: ObservableObject {
    let db = Firestore.firestore()
    
    func addStore() {
        
        let randomStoreName = "Store \(Int.random(in: 1...1000))"
        let randomStoreId = UUID().uuidString
        
        let newStoreData: [String: Any] = [
            "storeName": randomStoreName,
            "storeId": randomStoreId,
            "storeOwnerId": "1331",
            "address": "123 Main St",
            "city": "Anytown",
            "state": "CA",
            "zip": "90210",
            "phone": "(555) 555-5555",
            "email": "newstore@example.com",
            "latitude": 34.052234,
            "longitude": -118.243685,
            "rating": 4.5,
            "lastUpdated": FieldValue.serverTimestamp()
        ]
        
        
        db.collection("stores").addDocument(data: newStoreData) { error in
            if let error = error {
                print("Error adding store: \(error.localizedDescription)")
            }
            else {
                print("Store added successfully")
            }
        }
    }
}

class ProductService: ObservableObject {
    @Published var products: [Product] = []
    
    private let db = Firestore.firestore()
    
    func fetchProducts() {
        db.collection("products").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching products: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else { return }
            self.products = documents.compactMap { document in
                do {
                    return try document.data(as: Product.self)
                } catch {
                    print("Decoding error for document \(document.documentID): \(error)")
                    return nil
                }
            }
        }
    }
}

class AddProduct: ObservableObject {
    let db = Firestore.firestore()
    
    func addProduct() {
        let randomProductName = "Product \(Int.random(in: 1...1000))"
        let randomProductId = UUID().uuidString
        
        let newProductData: [String: Any] = [
            "productName": randomProductName,
            "productId": randomProductId,
            "productCategory": "Food",
            "lastUpdated": FieldValue.serverTimestamp()
        ]
        
        db.collection("products").addDocument(data: newProductData) { error in
            if let error = error {
                print("Error adding product: \(error.localizedDescription)")
            }
            else {
                print("Product added successfully")
            }
        }
    }
}

