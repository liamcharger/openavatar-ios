//
//  CustomButtonStyle.swift
//  Openavatar
//
//  Created by Liam Willey on 1/11/25.
//

import SwiftUI

enum CustomButtonType {
    case primary
    case secondary
    case minimal
    case minimalSecondary
}

struct CustomButtonStyle: ButtonStyle {
    let style: CustomButtonType
    
    init(style: CustomButtonType = .primary) {
        self.style = style
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(style == .minimal || style == .minimalSecondary ? 12 : 16)
            .frame(minWidth: style == .primary ? 100 : 20)
            .background(style == .primary || style == .minimal ? AnyShapeStyle(Color.blue.gradient) : AnyShapeStyle(Color.backgroundGray))
            .foregroundStyle(style == .primary || style == .minimal ? Color.white : Color.primary)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.smooth(duration: 0.35), value: configuration.isPressed)
    }
}
