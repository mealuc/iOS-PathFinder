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

class StoreStockService: BaseFirestoreService {
    
    func fetchStores(near coordinate: CLLocationCoordinate2D, radiusMeters: Double) async throws -> [Store] {
        print("fetchStores çalıştı")
        let earthRadius = 6_371_000.0
        let latDelta = (radiusMeters / earthRadius) * (180 / .pi)
        let longDelta = latDelta / cos(coordinate.latitude * .pi / 180)
        
        let minLat = coordinate.latitude - latDelta
        let maxLat = coordinate.latitude + latDelta
        let minLong = coordinate.longitude - longDelta
        let maxLong = coordinate.longitude + longDelta
        
        let snapshot = try await db.collection("stores")
            .whereField("storeLatitude", isGreaterThan: minLat)
            .whereField("storeLatitude", isLessThan: maxLat)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc -> Store? in
            guard let store = try? doc.data(as: Store.self) else { return nil }
            guard store.storeLongitude >= minLong,
                  store.storeLongitude <= maxLong else { return nil }
            return store
        }
    }
    
    func fetchStocks(for productId: String, in storeIds: [String]) async throws -> [ProductStock] {
        print("fetchStocks çalıştı")

        let chunks = storeIds.chunked(into: 10)
        var allStocks: [ProductStock] = []
        
        for chunk in chunks {
            let querySnapshot = try await db.collection("productStocks")
                .whereField("productId", isEqualTo: productId)
                .whereField("storeId", in: chunk)
                .whereField("stockQuantity", isGreaterThan: 0)
                .getDocuments()
            let stocks = querySnapshot.documents.compactMap { try? $0.data(as: ProductStock.self) }
            allStocks.append(contentsOf: stocks)
        }
        return allStocks
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
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var distanceValue: Double = 500
    @Published var storeStocks: [Store] = []
    @Published var productStocks: [ProductStock] = []
    
    var cachedStores: [Store] = []
    var cachedStocks: [ProductStock] = []
    var maxFetchedDistance: Double = 0
    
    func getDirections(to destination: CLLocationCoordinate2D) async -> MKCoordinateRegion? {
        
        guard let userLocation = self.userLocation else { return nil }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: .init(coordinate: userLocation))
        request.destination = MKMapItem(placemark: .init(coordinate: destination))
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        do {
            let directions = try await MKDirections(request: request).calculate()
            if let route = directions.routes.first {
                await MainActor.run {
                    self.route = route
                }
                let boundingRect = route.polyline.boundingMapRect
                let region = MKCoordinateRegion(boundingRect)
                return region
            }
        } catch {
            print("Error getting route directions: \(error.localizedDescription)")
        }
        return nil
    }
    
    func getUserLocation() async {
        let updates = CLLocationUpdate.liveUpdates()
        
        do {
            let update = try await updates.first { $0.location?.coordinate != nil }
            if let userCoords = update?.location?.coordinate {
                await MainActor.run {
                    self.userLocation = userCoords
                }
            }
        } catch {
            print("Error getting user location: \(error.localizedDescription)")
        }
    }
    
    func calculateDistances (for stores: [Store]) async -> [String: Double] {
        
        guard let userLocation = self.userLocation else { return [:] }
        let userCoords = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        return Dictionary(uniqueKeysWithValues: stores.map {
            let storeCoords = CLLocation(latitude: $0.storeLatitude, longitude: $0.storeLongitude)
            return ($0.storeId, storeCoords.distance(from: userCoords))
        })
    }
}

class CameraPosition: ObservableObject {
    @Published var cameraPosition: MapCameraPosition = .automatic
}


