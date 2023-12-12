//
//  MeasurementFormatter+Extension.swift
//  NearMe
//
//  Created by tom montgomery on 12/5/23.
//

import Foundation

extension MeasurementFormatter {
    
    static var distance: MeasurementFormatter {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        formatter.unitOptions = .naturalScale
        formatter.locale = Locale.current
        return formatter
    }
}
