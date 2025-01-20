//
//  BackgroundBorderViewModifier.swift
//  Openavatar
//
//  Created by Liam Willey on 1/17/25.
//

import SwiftUI

struct BackgroundBorderViewModifier: ViewModifier {
    let radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .overlay {
                RoundedRectangle(cornerRadius: radius)
                    .stroke(Color(.lightGray).opacity(0.15), lineWidth: 1)
            }
    }
}
