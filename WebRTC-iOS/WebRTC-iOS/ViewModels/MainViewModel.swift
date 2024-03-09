//
//  MainViewModel.swift
//  WebRTC-iOS
//
//  Created by Yu Wakui on 2024/03/09.
//

import SwiftUI
import Foundation

enum ActionType {
    case mute
    case sendData
    case speaker
    case offer
    case answer
}

class MainViewModel: ObservableObject {
    @Published var signalingConnected = false
    @Published var hasLocalSdp = false
    @Published var localCandidateCount = 0
    @Published var hasRemoteSdp = false
    @Published var webRTCStatusLabel: String = "New"
    
    func handleButtonTap(action: ActionType) {
        // TODO: Handle button tap action
    }
}
