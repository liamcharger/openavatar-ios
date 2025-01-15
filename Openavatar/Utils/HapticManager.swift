//
//  HapticManager.swift
//  Openavatar
//
//  Created by Liam Willey on 1/14/25.
//

import SwiftUI

struct HapticsManager {
    static func hapticWithPattern(type: UINotificationFeedbackGenerator.FeedbackType) {
        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    
    static func hapticWithImpact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        DispatchQueue.main.async {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        }
    }
}

func haptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
    HapticsManager.hapticWithImpact(style: style)
}

func haptic(type: UINotificationFeedbackGenerator.FeedbackType) {
    HapticsManager.hapticWithPattern(type: type)
}
