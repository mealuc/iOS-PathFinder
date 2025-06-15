import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

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
