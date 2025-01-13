//
//  CustomButtonStyle.swift
//  Openavatar
//
//  Created by Liam Willey on 1/11/25.
//

import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(minWidth: 100)
            .background(Color.blue.gradient)
            .foregroundStyle(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.smooth(duration: 0.35), value: configuration.isPressed)
    }
}
