//
//  SearchBarView.swift
//  NearMe
//
//  Created by tom montgomery on 12/4/23.
//

import SwiftUI

struct SearchBarView: View {
    
    @Binding var search: String
    @Binding var isSearching: Bool
    
    var body: some View {
        // since we will have 2 controls (components) we can put them in a vstack
        // Technique:  reverse spacing on the VStack to make things tighter
        VStack(spacing: -10) {
            TextField("Search", text: $search)
                .textFieldStyle(.roundedBorder)
            // could add more padding or style more...
                .padding()
                .onSubmit {
                    // code fired when you click return in the text field
                    isSearching = true
                }
            // SearchOptions is different b/c it takes in a closure
            SearchOptionsView { searchTerm in
                // searchTerm is the onSelected
                search = searchTerm
                // triggers the search because of the task
                isSearching = true
            }
            .padding([.leading], 10)
            .padding([.bottom], 20)
        }
    }
}

#Preview {
    // just populate some constants for the preview
    SearchBarView(search: .constant("Coffee"), isSearching: .constant(true))
}
