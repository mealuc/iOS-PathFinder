import SwiftUI
import MapKit

struct MapView: View {
    let locationAuth = LocationManagerAuthorization()
    let storeStocks: [Store]
    
    @State private var route: MKRoute?
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        Map(position: $cameraPosition) {
            
            Marker("Home", systemImage: "house.fill" ,coordinate: .Home)
                .tint(.green)
            ForEach (storeStocks){ store in
                Annotation(store.storeName, coordinate: CLLocationCoordinate2D(latitude: store.storeLatitude, longitude: store.storeLongitude), anchor: .bottom){
                    Image(systemName: "building.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.white)
                        .frame(width: 15, height: 15)
                        .padding(5)
                        .background(.green.gradient, in: .circle)
                        .contextMenu {
                            Button("Get Directions", systemImage: "arrow.turn.down.right"){
                                getDirections(to: CLLocationCoordinate2D(latitude: store.storeLatitude, longitude: store.storeLongitude))
                            }
                        }
                }
            }
            
            UserAnnotation()
            
            if let route{
                MapPolyline(route)
                    .stroke(Color.green, lineWidth: 4)
            }
            
            
        }
        .onAppear() {
            locationAuth.checkLocationAuthorizationStatus()
            /*
             // İlk mağazaya zoom yapmak için
             if let first = storeStocks.first {
             cameraPosition = .region(
             MKCoordinateRegion(
             center: CLLocationCoordinate2D(latitude: first.latitude, longitude: first.longitude),
             span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
             )
             )
             }
             */
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapPitchToggle()
            MapScaleView()
        }
    }
    
    func getUserLocation() async -> CLLocationCoordinate2D? {
        let updates = CLLocationUpdate.liveUpdates()
        
        do {
            let update = try await updates.first { $0.location?.coordinate != nil }
            return update?.location?.coordinate
        } catch {
            print("Error getting location: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getDirections(to destination: CLLocationCoordinate2D) {
        Task {
            guard let userLocation = await getUserLocation() else { return }
            
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: .init(coordinate: userLocation))
            request.destination = MKMapItem(placemark: .init(coordinate: destination))
            request.transportType = .automobile
            request.requestsAlternateRoutes = true
            
            do {
                let directions = try await MKDirections(request: request).calculate()
                route = directions.routes.first
                
                if let boundingRect = route?.polyline.boundingMapRect {
                    let region = MKCoordinateRegion(boundingRect)
                    await MainActor.run {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            cameraPosition = .region(region)
                        }
                    }
                }
            } catch
            {
                print("Error getting directions: \(error.localizedDescription)")
            }
        }
        
    }
}

#Preview {
    // 🔹 Örnek veriler (modelinle birebir uyumlu)
    let sampleStores = [
        Store(
            id: nil,
            storeId: "1",
            storeName: "Store 1",
            storeOwnerId: "owner1",
            storeAddress: "Main Street",
            storeCity: "Test City",
            storeState: "CA",
            storeZip: "90210",
            storePhone: "555-1234",
            storeEmail: "store1@example.com",
            storeLatitude: 41.239475,
            storeLongitude: 32.663714,
            storeRating: 4.2,
            storeLastUpdated: nil
        ),
        Store(
            id: nil,
            storeId: "2",
            storeName: "Store 2",
            storeOwnerId: "owner2",
            storeAddress: "Second Street",
            storeCity: "Test City",
            storeState: "CA",
            storeZip: "90211",
            storePhone: "555-4321",
            storeEmail: "store2@example.com",
            storeLatitude: 41.24521,
            storeLongitude: 32.67593,
            storeRating: 4.8,
            storeLastUpdated: nil
        )
    ]
    
    MapView(storeStocks: sampleStores)
}

extension CLLocationCoordinate2D {
    static let Home = CLLocationCoordinate2D(latitude: 41.2352139, longitude: 32.6666362)
    static let Arrival = CLLocationCoordinate2D(latitude: 41.239475, longitude: 32.663714)
    
}
