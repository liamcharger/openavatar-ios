//
//  Extension+String.swift
//  Openavatar
//
//  Created by Liam Willey on 1/12/25.
//

import SwiftUI

extension String {
    static var loadingText: LocalizedStringKey {
        let `case` = Int.random(in: 0...2)
        
        switch `case` {
        case 0:
            return LocalizedStringKey("Loading things up...")
        case 1:
            return LocalizedStringKey("Getting things ready...")
        default:
            return LocalizedStringKey("Talking to servers...")
        }
    }
}
