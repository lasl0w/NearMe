//
//  MapUtilities.swift
//  NearMe
//
//  Created by tom montgomery on 12/1/23.
//

import Foundation
import MapKit


func calculateDirections(from: MKMapItem, to: MKMapItem) async -> MKRoute {
    
    let directionsRequest = MKDirections.Request()
    directionsRequest.transportType = .automobile
    directionsRequest.source = from
    directionsRequest.destination = to
    
    let directions = MKDirections(request: directionsRequest)
    // it's an async function.  must use await
    let response = try? await directions.calculate()
    
    if response == nil {
        print("directions response is nil")
    }
    
    return response?.routes.first ?? MKRoute()
}


func calculateDistance(from: CLLocation, to: CLLocation) -> Measurement<UnitLength> {
    // benefit of the Measurement API is that you get the distance based on the locale.  might be in yards vs meters, miles vs kilometers depending on where you are in the world
    
    // TODO:  Draw out CLLocation and all it's children.  a picture with boxes
    // 'from' is the user's location.  'to' is the mark on the map.  just use the distance function (returns meters by default)
    let distanceInMeters = from.distance(from: to)
    print("Distance in Meters: \(distanceInMeters)")
    return Measurement(value: distanceInMeters, unit: .meters)
}


// Create it as a "stateless function"
// need a search term and we want to pass in the visible region
// async and can throw
func performSearch(searchTerm: String, visibleRegion: MKCoordinateRegion?) async throws -> [MKMapItem] {
    
    // A search request to apple maps
    let request = MKLocalSearch.Request()
    // what are we searching for?  use natural lang query
    request.naturalLanguageQuery = searchTerm
    request.resultTypes = .pointOfInterest
    
    // unwrap the region b/c it's nullable.  it's optional
    guard let region = visibleRegion else { return [] }
    // set the region for the request - must set it or it may use the last know region (some other place and zoom level)
    request.region = region
    
    let search = MKLocalSearch(request: request)
    // since is uses async await - we have to call it in that context
    let response = try await search.start()
    
    return response.mapItems
}
