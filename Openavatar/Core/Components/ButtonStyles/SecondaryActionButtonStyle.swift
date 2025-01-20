//
//  SecondaryActionButtonStyle.swift
//  Openavatar
//
//  Created by Liam Willey on 1/19/25.
//

import SwiftUI

struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(11)
            .padding(.horizontal, 4)
            .font(.system(size: 15.5).weight(.medium))
            .foregroundStyle(.primary)
            .background(Material.regular)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.smooth(duration: 0.35), value: configuration.isPressed)
    }
}
