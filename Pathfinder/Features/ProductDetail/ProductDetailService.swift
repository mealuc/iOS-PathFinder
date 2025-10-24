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

class GetProductStock {
    var db = Firestore.firestore()
    
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
