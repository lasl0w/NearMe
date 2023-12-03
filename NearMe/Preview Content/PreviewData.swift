//
//  PreviewData.swift
//  NearMe
//
//  Created by tom montgomery on 12/2/23.
//

import Foundation
import MapKit
import Contacts
// add things here to prevent it from being put in the production build

// call it whatevs
struct PreviewData {
    // WE CREATED A HARDCODED MAPITEM CALLED APPLE.  WE CAN USE IT ANY TIME WE NEED A MAPITEM FOR A PREVIEW TO WORK
    
    // static - it's available without an init
    static var apple: MKMapItem {
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        
        // all from the Contacts framework, hence import Contacts
        let addressDictionary: [String: Any] = [
            CNPostalAddressStreetKey: "1 Infinite Loop",
            CNPostalAddressCityKey: "Cupertino",
            CNPostalAddressStateKey: "CA",
            CNPostalAddressPostalCodeKey: "95014",
            CNPostalAddressCountryKey: "United States"
        ]
        // now that we have the addressDict, we can create the placemark
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        // now that we have the placemark, we can create the mapItem
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Apple Inc."
        return mapItem
    }
}
