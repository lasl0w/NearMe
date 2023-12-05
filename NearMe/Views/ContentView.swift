//
//  ContentView.swift
//  NearMe
//
//  Created by tom montgomery on 11/28/23.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @State private var query = ""
    @State private var selectedDetent: PresentationDetent = .fraction(0.15)
    @State private var locationManager = LocationManager.shared
    // new with iOS 17 is our mapcameraPosition - use the user's location
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    // to allow async await function, need a state var here.  use the 'task' mod to kick it off
    @State private var isSearching: Bool = false
    // all the totally sweet marks we're going to put on the map
    @State private var mapItems: [MKMapItem] = []
    // set visibleRegion so we can search as the map moves - only set it if the user moves away from their location centered aspect.  might be nil
    @State private var visibleRegion: MKCoordinateRegion?
    
    // used to put the pieces together
    private func search() async {
        // could use locationManager.region, but may want a different one
        do {
            // this func will return mapItems
            // replace locationManager.region w/ visibleRegion so we can search as the map moves
            mapItems = try await performSearch(searchTerm: query, visibleRegion: visibleRegion)
            print(mapItems)
            isSearching = false
        } catch {
            // if it fails we want to throw everything away
            mapItems = []
            print(error.localizedDescription)
            isSearching = false
        }
        
    }
    
    var body: some View {
        // wrap the map in a zstack so we can work with it in layers
        ZStack {
            // bind the map to the position to set zoom and focus
            Map(position: $position) {
                
                // id is .self b/c they are all hashable
                ForEach(mapItems, id: \.self) { mapItem in
                    // one of the Marker overload functions is to simply provide the mapItem
                    // Markers automatically set the icon category and color (coffee, gas, food icons)
                    Marker(item: mapItem)
                    
                }
                
                // Display the user loca from the locationManager
                // Once you add UserAnnotation - add the info.plist entry for location whenInUse (or the level we need)
                UserAnnotation()
            }
            .task(id: isSearching, {
                // do it here to ensure that if the view goes away, the task stops working.  This could work fine on the ZStack OR on the Map()
                if isSearching {
                    await search()
                }
            })
            // a great way to set zoom level and position is onChange of the region
            .onChange(of: locationManager.region, {
                withAnimation {
                    position = .region(locationManager.region)
                }
                
            })
            .sheet(isPresented: .constant(true), content: {
                VStack {
                    // Apply Detents & mods to the VStack, not the sheet itself
                    SearchBarView(search: $query, isSearching: $isSearching)
                    PlaceListView(mapItems: mapItems)
                    
                    
                    // add a spacer to push the TextField to the top, no matter the presentationDetents is
                    Spacer()
                }
                .presentationDetents([.fraction(0.15), .medium, .large], selection: $selectedDetent)
                // our little gray bar
                .presentationDragIndicator(.visible)
                // can't dismiss it all the way
                .interactiveDismissDisabled()
                // can still interact with the map at med visibility
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            })
        }
        // allows us to search in other regions, not just where the user is.  Map movement awareness.
        .onMapCameraChange { context in
            // automatically have access to the context
            visibleRegion = context.region
        }
        
    }
}

#Preview {
    ContentView()
}
