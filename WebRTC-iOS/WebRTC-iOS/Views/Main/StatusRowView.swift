//
//  StatusRowView.swift
//  WebRTC-iOS
//
//  Created by Yu Wakui on 2024/03/09.
//

import SwiftUI

struct StatusRowView: View {
    let title: String
    let content: Text
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title3)
                .bold()
            content
                .font(.title3)
            Spacer()
        }
        .padding(.vertical, 10)
    }
}
