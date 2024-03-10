//
//  MainView.swift
//  WebRTC-iOS
//
//  Created by Yu Wakui on 2024/03/09.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel = MainViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Header()
                
                StatusRowType.signalingStatus(viewModel.signalingConnected).makeRow()
                StatusRowType.localSDP(viewModel.hasLocalSdp).makeRow()
                StatusRowType.localCandidates(viewModel.localCandidateCount).makeRow()
                StatusRowType.remoteSDP(viewModel.hasRemoteSdp).makeRow()
                StatusRowType.remoteCandidates(viewModel.localCandidateCount).makeRow()
                
                Spacer()
                WebRTCStatusView(viewModel: viewModel)
                Spacer()
                
                HStack {
                    CustomButton(
                        style: .textOnly,
                        label: "Mute",
                        action: { viewModel.handleButtonTap(action: .mute) }
                    )
                    Spacer()
                    CustomButton(
                        style: .textOnly,
                        label: "Send data",
                        action: { viewModel.handleButtonTap(action: .sendData) }
                    )
                }
                .padding(.top)
                
                HStack {
                    CustomButton(
                        style: .textOnly,
                        label: "Speaker",
                        action: { viewModel.handleButtonTap(action: .speaker) }
                    )
                    Spacer()
                    NavigationLink(destination: VideoView()) {
                        Text("Video").foregroundColor(.blue)
                    }
                }
                .padding(.top)
                
                CustomButton(
                    style: .blueBackground,
                    label: "Send Offer",
                    action: { viewModel.handleButtonTap(action: .offer) }
                )
                .padding(.top)
                
                CustomButton(
                    style: .blueBackground,
                    label: "Send Answer",
                    action: { viewModel.handleButtonTap(action: .answer) }
                )
                .padding(.top)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            .background(Color.white)
        }
    }
}

#Preview {
    MainView()
}
