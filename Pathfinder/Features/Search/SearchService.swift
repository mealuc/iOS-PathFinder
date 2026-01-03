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
            "storeAddress": "123 Main St",
            "storeCity": "Karabuk",
            "storeState": "CA",
            "storeZip": "90210",
            "storePhone": "(555) 555-5555",
            "storeEmail": "newstore@example.com",
            "storeLatitude": 34.052234,
            "storeLongitude": -118.243685,
            "storeRating": 4.5,
            "storeLastUpdated": FieldValue.serverTimestamp()
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
    @Published var hasMoreProducts: Bool = true
    private var lastDocument: DocumentSnapshot?
    private var pageLimit = 3
    
    func fetchProducts() {
        db.collection("products").order(by: "productName").limit(to: pageLimit).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching products: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else { return }
            self.lastDocument = documents.last
            
            self.products = documents.compactMap { document in
                do {
                    return try document.data(as: Product.self)
                } catch {
                    print("Decoding error for document \(document.documentID): \(error)")
                    return nil
                }
            }
            self.hasMoreProducts = self.products.count == self.pageLimit
        }
    }
    
    func fetchMoreProducts() {
        guard let lastDocument else { return }
        
        db.collection("products").order(by: "productName")
            .start(afterDocument: lastDocument)
            .limit(to: pageLimit)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching more products: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                self.lastDocument = documents.last
                
                let newProducts = documents.compactMap { document in
                    do {
                        return try document.data(as: Product.self)
                    } catch {
                        print("Decoding error for document \(document.documentID): \(error)")
                        return nil
                    }
                }
                self.products.append(contentsOf: newProducts)
                
                if newProducts.count < self.pageLimit {
                    self.hasMoreProducts = false
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
        let randomPrice: Double = Double.random(in: 1.0...100.0)
        
        guard let randomProduct = allProducts.products.randomElement(),
              let randomStore = allStores.stores.randomElement()
                
        else {
            print("Couldn't find a random product or store ID")
            return
        }
        
        let newStockData: [String: Any] = [
            "productId": randomProduct.productId,
            "storeId": randomStore.storeId,
            "stockQuantity": randomStockQuantity,
            "storeName": randomStore.storeName,
            "productPrice": randomPrice
        ]
        
        db.collection("productStocks").addDocument(data: newStockData) { error in
            if let error = error {
                print("Error adding stock: \(error.localizedDescription)")
            }
            else {
                print("Stock added for \(randomProduct.productId) to \(randomStore.storeId) successfully")
            }
        }
    }
}

