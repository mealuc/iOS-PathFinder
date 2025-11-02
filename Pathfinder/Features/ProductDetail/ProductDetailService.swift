import CoreLocation
import SwiftUI
import MapKit
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

class MapService: ObservableObject {
    
    @Published var route: MKRoute?
    
    func getDirections(to destination: CLLocationCoordinate2D) async -> MKCoordinateRegion? {
        guard let userLocation = await getUserLocation() else { return nil }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: .init(coordinate: userLocation))
        request.destination = MKMapItem(placemark: .init(coordinate: destination))
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        do {
            let directions = try await MKDirections(request: request).calculate()
            if let route = directions.routes.first {
                self.route = route
                let boundingRect = route.polyline.boundingMapRect
                let region = MKCoordinateRegion(boundingRect)
                return region
            }
        } catch {
            print("Error getting route directions: \(error.localizedDescription)")
        }
        return nil
    }
    
    func getUserLocation() async -> CLLocationCoordinate2D? {
        let updates = CLLocationUpdate.liveUpdates()
        
        do {
            let update = try await updates.first { $0.location?.coordinate != nil }
            return update?.location?.coordinate
        } catch {
            print("Error getting user location: \(error.localizedDescription)")
            return nil
        }
    }
}

class CameraPosition: ObservableObject {
    @Published var cameraPosition: MapCameraPosition = .automatic
}
