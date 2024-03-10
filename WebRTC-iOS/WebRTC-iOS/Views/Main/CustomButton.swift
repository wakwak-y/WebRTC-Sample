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
        case greenBackBround
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
        case .greenBackBround:
            Button(action: action) {
                Text(label)
                    .foregroundColor(.white)
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity, maxHeight: 70)
                    .cornerRadius(10)
                    .background(Color.green)
            }
        }
    }
}
