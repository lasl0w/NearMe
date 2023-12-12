//
//  ContentView.swift
//  NearMe
//
//  Created by tom montgomery on 11/28/23.
//

import SwiftUI
import MapKit

// What will our sheet show?  the list&filter view or the individual detail of the selectedItem
enum DisplayMode{
    case list
    case detail
}


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
    // optional b/c we start out with nothing selected
    @State private var selectedMapItem: MKMapItem?
    @State private var displayMode: DisplayMode = .list
    // need to use the mapItem in order to get the lookAroundScene
    @State private var lookAroundScene: MKLookAroundScene?
    // store the output of requestCalculateDirections
    @State private var route: MKRoute?
    
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
    
    // refactored to make it async
    // TODO: deep dive on async await
    private func requestCalculateDirections() async {
        // first add a state var to store our MKRoute that gets returned
        
        route = nil
        
        //2nd - unwrap the selectedMapItem (gotta calc from here to there)
        if let selectedMapItem {
            // get users location.  If we can't, then no directions can be had
            guard let currentUserLocation = locationManager.manager.location else { return }
            // base the placemark on the user loca
            let startingMapItem = MKMapItem(placemark: MKPlacemark(coordinate: currentUserLocation.coordinate))
            
            // multiple ways to calculate directions - use a .task modifier or use a Task closure.  may take a perf hit on a closure if the user leaves the view b/c the task is still not cancelled
            //Task { }
            // refactored to not use a task closure
            self.route = await calculateDirections(from: startingMapItem, to: selectedMapItem)
            //once we have it, we can display it (as a MapPolyline)
        }
        
    }
    
    var body: some View {
        // wrap the map in a zstack so we can work with it in layers
        ZStack {
            // bind the map to the position to set zoom and focus
            // selection automatically animates the marker onClick, but does nothing on our sheet
            Map(position: $position, selection: $selectedMapItem) {
                
                // id is .self b/c they are all hashable
                ForEach(mapItems, id: \.self) { mapItem in
                    // one of the Marker overload functions is to simply provide the mapItem
                    // Markers automatically set the icon category and color (coffee, gas, food icons)
                    Marker(item: mapItem)
                    
                }
                
                if let route {
                    // MapPolyLine can take an MKRoute - of course!
                    MapPolyline(route)
                        .stroke(.blue, lineWidth: 5)
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
                    
                    // switch ensures we are showing the list content unless a user taps on a marker, then show detail
                    // monitor the display mode using the onChange event
                    // TODO: how do we know which onChange event to use?  why not onTap of marker?
                    switch displayMode {
                    case .list:
                        // Apply Detents & mods to the VStack, not the sheet itself
                        SearchBarView(search: $query, isSearching: $isSearching)
                        PlaceListView(mapItems: mapItems, selectedMapItem: $selectedMapItem)
                    case .detail:
                        SelectedPlaceDetailView(mapItem: $selectedMapItem)
                            .padding()
                        if selectedDetent == .medium || selectedDetent == .large {
                            // i.e. - we don't want to see it when the sheet is just 1/5th of the view
                            LookAroundPreview(initialScene: lookAroundScene)
                            // TODO:  learn how to make the LookAround have a max height in the sheet
                        
                        }


                    }
                    // add a spacer to push the TextField to the top, no matter the presentationDetents is
                    Spacer()
                }
                .presentationDetents([.fraction(0.15), .medium, .large], selection: $selectedDetent)
                // our little gray handle bar
                .presentationDragIndicator(.visible)
                // can't dismiss it all the way
                .interactiveDismissDisabled()
                // can still interact with the map at med visibility
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            })
        }
        // onChange, fire this closure
        .onChange(of: selectedMapItem, {
            if selectedMapItem != nil {
                displayMode = .detail
                // Instead of calling it here, we can move it to the .task modifier so it will handle destroying it properly
                //requestCalculateDirections()
            } else {
                // reset back to list
                displayMode = .list
            }
        })
        
        // allows us to search in other regions, not just where the user is.  Map movement awareness.
        .onMapCameraChange { context in
            // automatically have access to the context
            visibleRegion = context.region
        }
        .task(id: selectedMapItem) {
            // when the selectedMapItem changes, trigger this baby
            // ensure the last scene displayed is goneski
            lookAroundScene = nil
            if let selectedMapItem {
                // apple doesn't have scenes for everywhere.  If it doesn't exist, don't show anything
                let request = MKLookAroundSceneRequest(mapItem: selectedMapItem)
                lookAroundScene = try? await request.scene
                // Alternate place to call for directions - for proper mem handling
                await requestCalculateDirections()
            }
        }
        
    }
}

#Preview {
    ContentView()
}
