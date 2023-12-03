//
//  MapUtilities.swift
//  NearMe
//
//  Created by tom montgomery on 12/1/23.
//

import Foundation
import MapKit
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
