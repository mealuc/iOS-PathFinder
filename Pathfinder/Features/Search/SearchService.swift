import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import SwiftUI
import Foundation /* Necessary for uuidString func */

class BaseFirestoreService {
    let db = Firestore.firestore()
}

class StoreService: BaseFirestoreService, ObservableObject {
    @Published var stores: [Store] = []
    
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

class AddStores: BaseFirestoreService {
    
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

class ProductService: BaseFirestoreService, ObservableObject {
    @Published var products: [Product] = []
    
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

class AddProduct: BaseFirestoreService {
    
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

class AddProductStock: BaseFirestoreService {
    
    var allProducts = ProductService()
    var allStores = StoreService()

    
    func prepareForAddingStock() {
        allProducts.fetchProducts()
        allStores.fetchStores()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: addStock)
    }
    
    func addStock() {
        
        let randomStockQuantity = Int.random(in: 1...100)
        
        guard let randomProductId = allProducts.products.randomElement()?.productId,
              let randomStoreId = allStores.stores.randomElement()?.storeId else {
            print("Couldn't find a random product or store ID")
            return
        }
        
        let newStockData: [String: Any] = [
            "productId": randomProductId,
            "storeId": randomStoreId,
            "stockQuantity": randomStockQuantity,
        ]
        
        db.collection("productStocks").addDocument(data: newStockData) { error in
            if let error = error {
                print("Error adding stock: \(error.localizedDescription)")
            }
            else {
                print("Stock added for \(randomProductId) to \(randomStoreId) successfully")
            }
        }
    }
}

