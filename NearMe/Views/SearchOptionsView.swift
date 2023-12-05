//
//  SearchOptionsView.swift
//  NearMe
//
//  Created by tom montgomery on 12/2/23.
//

import SwiftUI
// anytime someone selects a search option, it's going to call a closure - could also do it with a binding instead
struct SearchOptionsView: View {
    
    let searchOptions = ["Restaurants": "fork.knife", "Hotels": "bed.double.fill", "Coffee": "cup.and.saucer.fill", "Gas": "fuelpump.fill"]
    
    let onSelected: (String) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                // List of search options
                // TODO: what's with the sort of > ?
                // since these are dictionaries, use the id: of the key (\.0)
                ForEach(searchOptions.sorted(by: >), id: \.0) { key, value in
                    Button(action: {
                        // action
                        onSelected(key)
                    }, label: {
                        HStack {
                            Image(systemName: value)
                            Text(key)
                        }
                    })
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 236/255, green: 240/255, blue: 241/255, opacity: 1.0))
                    .foregroundStyle(.black)
                    .padding(4)
                }
            }
        }
    }
}

#Preview {
    // passing in an empty closure so the previews can at least work
    SearchOptionsView(onSelected: { _ in })
}
