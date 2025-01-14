//
//  HapticManager.swift
//  Openavatar
//
//  Created by Liam Willey on 1/14/25.
//

import SwiftUI

enum HapticStyle {
    case list
    case button
}

struct HapticsManager {
    static func hapticWithPattern(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    static func hapticWithImpact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

func haptic(style: HapticStyle) {
    if style == .list {
        HapticsManager.hapticWithImpact(style: .medium)
    } else {
        HapticsManager.hapticWithImpact(style: .heavy)
    }
}
