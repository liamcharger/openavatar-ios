//
//  ListButtonStyle.swift
//  Openavatar
//
//  Created by Liam Willey on 1/13/25.
//

import SwiftUI

struct ListButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .buttonStyle(.plain)
            .padding()
            .foregroundStyle(Color.primary)
            .background(configuration.isPressed ? Color.backgroundLightGray : Color.backgroundGray)
    }
}
