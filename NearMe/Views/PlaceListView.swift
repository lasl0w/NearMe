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
    // allow an item on the list to be selectable to wiggle the marker and see the detail view
    @Binding var selectedMapItem: MKMapItem?
    
    private var sortedItems: [MKMapItem] {
        
        // LocationManager is @Observable so we've got it everywhere
        guard let userLocation = LocationManager.shared.manager.location else {
            // if it fails, just abort
            return mapItems
        }
        
        // use the built-in .sorted function, BUT pass in a closure
        return mapItems.sorted { lhs, rhs in
            // get the lhs loca and the rhs loca
            // TODO: deep dive on .sorted function and overloading.  Must conform to Comparable.  runs the closure recursively?
            guard let lhsLocation = lhs.placemark.location,
                  let rhsLocation = rhs.placemark.location else {
                return false
            }
            
            // get the distance from the first two mapItems in the array
            let lhsDistance = userLocation.distance(from: lhsLocation)
            let rhsDistance = userLocation.distance(from: rhsLocation)
            
            // if lhs is smaller, it's closer
            return lhsDistance < rhsDistance
        }
        
        // When building, start by returning an empty array to avoid compiler complaints
        //return []
    }
    
    var body: some View {
        // replace mapItems with sortedItems to show the sorted list
        // make sure the selected one is captured by using the selection: property
        List(sortedItems, id: \.self, selection: $selectedMapItem) { mapItem in
        PlaceView(mapItem: mapItem)}
    }
}

#Preview {
    // leverage our PreviewData for this, but....
    // now that we are bringing in the binding, gotta set it here
    let apple = Binding<MKMapItem?>(
        get: {PreviewData.apple},
        set: { _ in }
    )
    
    // and must return if we are using a binding we created in the preview
    return PlaceListView(mapItems: [PreviewData.apple], selectedMapItem: apple)
}
