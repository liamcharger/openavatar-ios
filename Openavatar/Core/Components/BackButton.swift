//
//  BackButton.swift
//  Openavatar
//
//  Created by Liam Willey on 1/19/25.
//

import SwiftUI

struct BackButton: View {
    let back: () -> Void
    
    var body: some View {
        Button {
            back()
        } label: {
            Image(systemName: "arrow.left")
                .frame(minHeight: 24)
        }
        .buttonStyle(CustomButtonStyle(style: .secondary))
    }
}
