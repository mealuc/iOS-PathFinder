import CoreLocation

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
