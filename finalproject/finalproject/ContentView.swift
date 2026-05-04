//
//  ContentView.swift
//  finalproject
//
//  Created by Ellison Suhoza on 4/20/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            FeedView()
                .navigationBarTitleDisplayMode(.inline)
        }
        .tint(.primary)
    }
}

#Preview {
    ContentView()
}
