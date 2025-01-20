//
//  HeaderView.swift
//  Openavatar
//
//  Created by Liam Willey on 1/19/25.
//

import SwiftUI

struct HeaderView: View {
    let title: LocalizedStringKey
    let icon: String
    let subtitle: LocalizedStringKey?
    let accent: Color
    let error: Bool

    init(title: LocalizedStringKey, icon: String, subtitle: LocalizedStringKey? = nil, accent: Color = .primary, error: Bool = false) {
        self.title = title
        self.icon = icon
        self.subtitle = subtitle
        self.accent = accent
        self.error = error
    }
    
    var body: some View {
        VStack(spacing: 10) {
            FAText(icon, size: 31)
                .padding(14)
                .background(accent == .primary ? .clear : accent.opacity(0.15))
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(accent, lineWidth: 4)
                }
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .foregroundColor(accent)
                .animation(.smooth(duration: 0.4), value: icon)
            Text(title)
                .font(.system(size: 24, design: .monospaced).weight(.bold))
            if let subtitle {
                Text(subtitle)
                    .foregroundStyle(error ? Color.red : Color(.lightGray))
            }
        }
        .multilineTextAlignment(.center)
    }
}
