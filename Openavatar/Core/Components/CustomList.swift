//
//  CustomList.swift
//  Openavatar
//
//  Created by Liam Willey on 1/13/25.
//

import SwiftUI

struct CustomList<Content>: View where Content : View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(.lightGray).opacity(0.25), lineWidth: 1)
        }
    }
}
