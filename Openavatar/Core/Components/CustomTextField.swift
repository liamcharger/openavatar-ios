//
//  CustomTextField.swift
//  Openavatar
//
//  Created by Liam Willey on 1/11/25.
//

import SwiftUI

struct CustomTextField: View {
    enum `Type` {
        case normal
        case secure
    }
    
    let type: `Type`
    let title: LocalizedStringKey
    @Binding var text: String
    
    init(_ title: LocalizedStringKey, text: Binding<String>, type: `Type` = .normal) {
        self.type = type
        self.title = title
        self._text = text
    }
    
    var body: some View {
        let textField = Group {
            if type == .normal {
                TextField(title, text: $text)
            } else {
                SecureField(title, text: $text)
            }
        }
        
        textField
            .textFieldStyle(.plain)
            .font(.title3)
            .padding(12)
            .background(Color.backgroundGray)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.lightGray).opacity(0.25), lineWidth: 1)
            }
            .autocorrectionDisabled()
    }
}
