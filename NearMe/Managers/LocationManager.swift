//
//  LocationManager.swift
//  NearMe
//
//  Created by tom montgomery on 11/29/23.
//

import Foundation
import MapKit
import Observation // to get the macro

enum LocationError: LocalizedError {
    
    // keep adding cases as you encounter them or set a catchall
    case authorizedDenied
    case authorizedRestricted
    case unknownLocation
    case accessDenied
    case network
    case operationFailed
    
    // conforms to localizedError
    var errorDescription: String? {
        // self is the whole LocationError object
        switch self {
        case .authorizedDenied:
            return NSLocalizedString("Location access denied.", comment: "")
        case .authorizedRestricted:
            return NSLocalizedString("Location access restricted.", comment: "")
        case .unknownLocation:
            return NSLocalizedString("Unknown location", comment: "")
        case .accessDenied:
            return NSLocalizedString("Access denied", comment: "")
        case .network:
            return NSLocalizedString("Network failed", comment: "")
        case .operationFailed:
            return NSLocalizedString("Operation failed", comment: "")
        }
    }
}



// iOS 17 macro that auto makes everything observable, instead of manually conforming to it
@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    
    // create the REAL location manager - the starter/stopper of loca events
    let manager = CLLocationManager()
    // then create the 'shared' singleton of our whole class
    // TODO: why can it be 'let' if we are changing some props?
    static let shared = LocationManager()
    
    // Need an instance of the loca error to potentially write to it
    var error: LocationError? = nil
    // since we are using the @observable macro, the view has the published error - so we can use it
    
    // the users current region (or some specified alternative)
    var region: MKCoordinateRegion = MKCoordinateRegion()
    
    // since we are conforming to NSObject, gotta override
    private override init() {
        // make private to explicitly prevent anyone else making a 2nd loca manager.  singleton enforced!
        super.init()
        
        // set the delegate 'worker' to our singleton
        self.manager.delegate = self
    }
}

// it's clean to keep function implementations in an extension.  preference, not required.
extension LocationManager {
    
    // basics to implement a loca delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // fired when a user loca is updated
        // GOAL = find the 'region' surrounding the user
        // plenty of options but the locations.last is popular as it's the latest
        locations.last.map {
            // do something with the last known location ($0)
            MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            // span is the zoom factor
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
        case .notDetermined:
            // first launch of app OR reinstall
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        case .denied:
            // No User loca, fallback to highlighted sights view
            print("loca denied")
            error = .authorizedDenied
        case .restricted:
            // restricted loca services, fallback to highlighted sights view
            print("loca denied")
            error = .authorizedRestricted
        @unknown default:
            // handle future states - abort
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // required to conform to the protocol
        
        // Need to cast it to a CLError
        if let clError = error as? CLError {
            // TODO: must use self.error instead of error.  why? b/c it was cast - no, to disambiguate that we are talking about the singletons error property and NOT the local cast one of the same name.  i think.
            switch clError.code {
            case .locationUnknown:
                self.error = .unknownLocation
            case .denied:
                self.error = .accessDenied
            case .network:
                self.error = .network
            default:
                self.error = .operationFailed
                print(error.localizedDescription)
            }
        }
    }
}
