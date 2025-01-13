//
//  LoadingView.swift
//  OpenID
//
//  Created by Liam Willey on 1/13/25.
//

import SwiftUI

struct LoadingView: View {
    let text = String.loading
    
    var body: some View {
        // TODO: add other UI elements in background
        ProgressView(text)
    }
}

#Preview {
    LoadingView()
}
