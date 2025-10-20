import SwiftUI
import MapKit

struct MapView: View {
    let locationAuth = LocationManagerAuthorization()
    
    @State private var route: MKRoute?
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        Map(position: $cameraPosition) {
            Marker("Home", systemImage: "house.fill" ,coordinate: .Home)
                .tint(.green)
            Annotation("Arrival", coordinate: .Arrival, anchor: .bottom){
                Image(systemName: "laptopcomputer")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .padding(5)
                    .background(.green.gradient, in: .circle)
                    .contextMenu {
                        Button("Get Directions", systemImage: "arrow.turn.down.right"){
                            getDirections(to: .Arrival)
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
                        withAnimation(.easeInOut(duration: 0.5)) {
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
    MapView()
}

extension CLLocationCoordinate2D {
    static let Home = CLLocationCoordinate2D(latitude: 41.2352139, longitude: 32.6666362)
    static let Arrival = CLLocationCoordinate2D(latitude: 41.239475, longitude: 32.663714)
    
}
