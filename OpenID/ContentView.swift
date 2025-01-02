//
//  ContentView.swift
//  OpenID
//
//  Created by Liam Willey on 1/1/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            // TODO: add onboarding
            MyProfileView()
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    ContentView()
}
