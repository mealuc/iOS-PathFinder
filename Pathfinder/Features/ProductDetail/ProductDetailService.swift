import CoreLocation
import FirebaseFirestore

class LocationManagerAuthorization: NSObject, CLLocationManagerDelegate {
    let userLocationManager = CLLocationManager()
    
    override init() {
        super.init()
        userLocationManager.delegate = self
    }
    
    func checkLocationAuthorizationStatus() {
        
        switch userLocationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            enableLocationFeatures()
            break
        case .restricted, .denied:
            disableLocationFeatures()
            break
        case .notDetermined:
            userLocationManager.requestWhenInUseAuthorization()
            break
        default:
            break
        }
    }
    
    private func enableLocationFeatures() {
        userLocationManager.startUpdatingLocation()
    }
    
    private func disableLocationFeatures() {
        userLocationManager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorizationStatus()
    }
}

class GetProductStock: BaseFirestoreService {
    
    func fetchStocks(for productId: String) async throws -> [ProductStock] {
        let querySnapshot = try await db.collection("productStocks")
            .whereField("productId", isEqualTo: productId)
            .whereField("stockQuantity", isGreaterThan: 0)
            .getDocuments()
        let stocks = querySnapshot.documents.compactMap { document -> ProductStock? in
            try? document.data(as: ProductStock.self)
        }
        return stocks
    }
}

class GetStockedStores: BaseFirestoreService {
    
    func fetchStores(for stockResult: [ProductStock]) async throws -> [Store] {
        
        let storeIds = Array(Set(stockResult.map { $0.storeId }))
        var stores: [Store] = []
        let chunks = storeIds.chunked(into: 10)
        
        for chunk in chunks {
            let querySnapshot = try await db.collection("stores")
                .whereField("storeId", in: chunk)
                .getDocuments()
            
            let fethchedStores = querySnapshot.documents.compactMap { document -> Store? in
                try? document.data(as: Store.self)
            }
            
            stores.append(contentsOf: fethchedStores)
        }
        
        return stores
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
