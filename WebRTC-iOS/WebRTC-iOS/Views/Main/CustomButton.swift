//
//  CustomButton.swift
//  WebRTC-iOS
//
//  Created by Yu Wakui on 2024/03/09.
//

import SwiftUI

import SwiftUI

struct CustomButton: View {
    enum ButtonStyle {
        case textOnly
        case blueBackground
    }
    
    let style: ButtonStyle
    let label: String
    let action: () -> Void
    
    var body: some View {
        switch style {
        case .textOnly:
            Button(action: action) {
                Text(label)
                    .foregroundColor(.blue)
            }
        case .blueBackground:
            Button(action: action) {
                Text(label)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: 50)
            .cornerRadius(10)
            .background(Color.blue)
        }
    }
}
