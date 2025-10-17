import SwiftUI
import MapKit

struct MapView: View {
    let locationAuth = LocationManagerAuthorization()
    
    var body: some View {
        Map() {
            /*Marker("Home", systemImage: "house.fill" ,coordinate: .Home)
                .tint(.green)*/
            //Marker("Arrival", coordinate: .Arrival)
            UserAnnotation()
        }
        .onAppear() {
            locationAuth.checkLocationAuthorizationStatus()
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
