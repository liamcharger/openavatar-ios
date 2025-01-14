//
//  CustomButtonStyle.swift
//  Openavatar
//
//  Created by Liam Willey on 1/11/25.
//

import SwiftUI

enum CustomButtonType {
    case full
    case compact
}

struct CustomButtonStyle: ButtonStyle {
    let style: CustomButtonType
    
    init(style: CustomButtonType = .full) {
        self.style = style
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(minWidth: style == .full ? 100 : 20)
            .background(style == .full ? AnyShapeStyle(Color.blue.gradient) : AnyShapeStyle(Color.backgroundGray))
            .foregroundStyle(style == .full ? Color.white : Color.primary)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.smooth(duration: 0.35), value: configuration.isPressed)
    }
}
