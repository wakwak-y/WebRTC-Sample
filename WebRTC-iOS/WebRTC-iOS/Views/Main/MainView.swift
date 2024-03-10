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
                
                if viewModel.isAudioSettionActive {
                    TimerView(currentTime: $viewModel.currentTime)
                    Spacer()
                }
                
                if !viewModel.hasLocalSdp && !viewModel.hasRemoteSdp{
                    CustomButton(
                        style: .greenBackBround,
                        label: "🤙Offer",
                        action: { viewModel.handleButtonTap(action: .offer) }
                    )
                    .padding(.top)
                } else if !viewModel.hasLocalSdp && viewModel.hasRemoteSdp {
                    CustomButton(
                        style: .greenBackBround,
                        label: "Answer👍",
                        action: { viewModel.handleButtonTap(action: .answer) }
                    )
                    .padding(.top)
                }
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
