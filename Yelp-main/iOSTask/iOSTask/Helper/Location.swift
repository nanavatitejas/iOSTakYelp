import Foundation
import CoreLocation


class UserLocation {
    let locationManager : CLLocationManager?

    init(location :CLLocationManager ) {
        self.locationManager = location

        locationManager?.requestAlwaysAuthorization()
        locationManager?.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager?.distanceFilter = 10.0

            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.startUpdatingLocation()

        }
    }
}






