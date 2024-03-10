//
//  WebRTCStatusView.swift
//  WebRTC-iOS
//
//  Created by Yu Wakui on 2024/03/09.
//

import SwiftUI

struct WebRTCStatusView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        VStack {
            Text("WebRTC Status:")
                .font(.title)
                .bold()
            Text(viewModel.webRTCStatusLabel)
                .font(.title)
                .foregroundColor(viewModel.webRTCStatusTextColor)
                .bold()
        }
    }
}
