//
//  LoadingView.swift
//  Openavatar
//
//  Created by Liam Willey on 1/13/25.
//

import SwiftUI

struct LoadingView: View {
    @ObservedObject var userViewModel = UserViewModel.shared
    
    let loadingText = String.loadingText
    
    var body: some View {
        /*
         VStack(spacing: 20) {
            HStack(spacing: 44) {
                FAText("rocket", size: 32).foregroundStyle(.red)
                FAText("hourglass", size: 32).foregroundStyle(.primary.opacity(0.8))
                FAText("arrows-rotate", size: 32).foregroundStyle(.blue)
            }
            VStack {
                Text("Loading")
                    .font(.system(size: 55, design: .monospaced).weight(.heavy))
                Text(loadingText)
                    .foregroundStyle(.gray)
            }
            ProgressView()
                .scaleEffect(1.8) // We need to find a better way to scale this
                .padding()
        }
         */
        ProgressView()
    }
}

#Preview {
    LoadingView()
}
