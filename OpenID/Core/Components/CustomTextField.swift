//
//  CustomTextField.swift
//  OpenID
//
//  Created by Liam Willey on 1/11/25.
//

import SwiftUI

struct CustomTextField: View {
    let title: LocalizedStringKey
    @Binding var text: String
    
    init(_ title: LocalizedStringKey, text: Binding<String>) {
        self.title = title
        self._text = text
    }
    
    var body: some View {
        TextField(title, text: $text)
            .textFieldStyle(.plain)
            .font(.title3)
            .padding(12)
            .background(Color.backgroundGray)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .autocorrectionDisabled()
            .autocapitalization(.none)
    }
}
