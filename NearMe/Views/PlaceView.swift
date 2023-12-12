//
//  PlaceView.swift
//  NearMe
//
//  Created by tom montgomery on 12/2/23.
//

import SwiftUI
import MapKit

// Single Place Item, fully
struct PlaceView: View {
    
    // pass in the mapItem so we can work with it
    let mapItem: MKMapItem
    
    private var address: String {
        let placemark = mapItem.placemark
        // the whole darn thing
        return "\(placemark.subThoroughfare ?? "") \(placemark.thoroughfare ?? "") , \(placemark.locality ?? ""), \(placemark.administrativeArea ?? "") \(placemark.postalCode ?? ""), \(placemark.country ?? "")"
    }
    
    // TODO: is this using generics?  need to brush up on <type> usage and use cases
    private var distance: Measurement<UnitLength>? {
        
        guard let userLocation = LocationManager.shared.manager.location,
              let destinationLocation = mapItem.placemark.location
        else {
            return nil
        }
        return calculateDistance(from: userLocation, to: destinationLocation)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(mapItem.name ?? "")
                .font(.title3)
            // Placemark has address
            Text(address)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let distance {
                // TODO: could pass in the userlocation as a dependency so the preview can render
                Text(distance, formatter: MeasurementFormatter.distance)
            }
        }
        
    }
}

#Preview {
    PlaceView(mapItem: PreviewData.apple)
}
