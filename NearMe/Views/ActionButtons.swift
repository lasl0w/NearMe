//
//  ActionButtons.swift
//  NearMe
//
//  Created by tom montgomery on 12/12/23.
//

import SwiftUI
import MapKit

func makeCall(phone: String) {
    if let url = URL(string: "tel://\(phone)") {
        // the singleton app instance
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("Device can not make calls")
        }
    }
}

struct ActionButtons: View {
    
    // have to pass it in, so the buton action knows which place to route/call
    let mapItem: MKMapItem
    
    var body: some View {
        HStack {
            // Hide/skip the call button if no phone exists
            if let phone = mapItem.phoneNumber {
                
                Button(action: {
                    // action - need to ensure all hyphens, special chars, etc have been removed prior to calling
                    // TODO: understand the .components function and params
                    let numericPhoneNumber = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                    makeCall(phone: numericPhoneNumber)
                    
                    
                }, label: {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text("Call")
                    }
                }).buttonStyle(.bordered)
            }
            
            
            Button(action: {
                // action
                MKMapItem.openMaps(with: [mapItem])
            }, label: {
                HStack {
                    Image(systemName: "car.circle.fill")
                    Text("Take me there")
                }
            }).buttonStyle(.bordered)
                .tint(.green)
            // push the buttons to the left.  now add padding in the contentView
            Spacer()
        }
    }
}

#Preview {
    // Preview is angry!
    ActionButtons(mapItem: PreviewData.apple)
}
