//
//  PlaceListView.swift
//  NearMe
//
//  Created by tom montgomery on 12/5/23.
//

import SwiftUI
import MapKit

// this view is dependent on a list of mapItems - get em in here!
struct PlaceListView: View {
    
    let mapItems: [MKMapItem]
    
    var body: some View {
        List(mapItems, id: \.self) { mapItem in
        PlaceView(mapItem: mapItem)}
    }
}

#Preview {
    // leverage our PreviewData for this
    PlaceListView(mapItems: [PreviewData.apple])
}
