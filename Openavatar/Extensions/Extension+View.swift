//
//  Extension+View.swift
//  Openavatar
//
//  Created by Liam Willey on 1/17/25.
//

import SwiftUI

extension View {
    func backgroundBorder(radius: CGFloat = 20) -> some View {
        modifier(BackgroundBorderViewModifier(radius: radius))
    }
}
