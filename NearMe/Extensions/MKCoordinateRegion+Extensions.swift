//
//  MKCoordinateRegion+Extensions.swift
//  NearMe
//
//  Created by tom montgomery on 12/1/23.
//

import Foundation
import MapKit

extension MKCoordinateRegion: Equatable {
    
    // create the comparison operator for regions
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        if lhs.center.latitude == rhs.center.latitude && lhs.span.latitudeDelta == rhs.span.latitudeDelta && lhs.span.longitudeDelta == rhs.span.longitudeDelta {
            return true
        } else {
            return false
        }
        // public b/c it needs to be used by all
        // static b/c it is part of the MKCoordinateRegion definition from the start - no init needed
    }
}
