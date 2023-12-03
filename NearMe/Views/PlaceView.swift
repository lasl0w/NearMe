//
//  PlaceView.swift
//  NearMe
//
//  Created by tom montgomery on 12/2/23.
//

import SwiftUI
import MapKit

struct PlaceView: View {
    
    // pass in the mapItem so we can work with it
    let mapItem: MKMapItem
    
    private var address: String {
        let placemark = mapItem.placemark
        // the whole darn thing
        return "\(placemark.subThoroughfare ?? "") \(placemark.thoroughfare ?? "") , \(placemark.locality ?? ""), \(placemark.administrativeArea ?? "") \(placemark.postalCode ?? ""), \(placemark.country ?? "")"
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(mapItem.name ?? "")
                .font(.title3)
            // Placemark has address
            Text(address)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        
    }
}

#Preview {
    PlaceView(mapItem: PreviewData.apple)
}
