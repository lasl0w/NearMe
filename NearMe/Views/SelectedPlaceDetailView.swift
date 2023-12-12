//
//  SelectedPlaceDetailView.swift
//  NearMe
//
//  Created by tom montgomery on 12/8/23.
//

import SwiftUI
import MapKit

struct SelectedPlaceDetailView: View {
    
    // we pass it in as a binding b/c we are going to set it to nil when someone moves off of it or wants to close it out
    @Binding var mapItem: MKMapItem?
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                if let mapItem {
                    PlaceView(mapItem: mapItem)
                }
            }
            Image(systemName: "xmark.circle.fill")
                .padding()
                .onTapGesture {
                    // mapItem is bound, so when it gets set to nil the view re-renders any component/control dependent
                    mapItem = nil
                }
        }
    }
}

#Preview {
    // our PreviewData.apple doesn't work b/c it's not passing an optional
    
    // so, we can create one
    // TODO: creating a Binding with getter and setter
    let apple = Binding<MKMapItem?>(
        get: {PreviewData.apple},
        set: { _ in }
    )
    // And you have change it to a return statement....
    // TODO:  why does this have to be a return statement
    return SelectedPlaceDetailView(mapItem: apple)
}
