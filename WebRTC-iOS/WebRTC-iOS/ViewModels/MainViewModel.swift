//
//  MainViewModel.swift
//  WebRTC-iOS
//
//  Created by Yu Wakui on 2024/03/09.
//

import SwiftUI
import Foundation
import WebRTC

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
    @Published var webRTCStatusTextColor: Color = .black
    @Published var remoteCandidateCount = 0
    
    private let signalClient: SignalingClient
    private let webRTCClient: WebRTCClient
    
    init() {
        let wsProvider = WebSocketProvider(url: Config.default.signalingServerUrl)
        signalClient = SignalingClient(webSocket: wsProvider)
        webRTCClient = WebRTCClient(iceServers: Config.default.webRTCIceServers)
        
        signalClient.delegate = self
        webRTCClient.delegate = self
        
        // シグナリングサーバーとコネクションを確立する(WebSocket)
        signalClient.connect()
    }
    
    func handleButtonTap(action: ActionType) {
        switch action {
        case .mute:
            break
        case .sendData:
            break
        case .speaker:
            break
        case .offer:
            Task.detached {
                // LocalOfferSDPを生成
                let sdp = try await self.webRTCClient.offer()
                // Viewが参照しているプロパティはMainスレッドで変更
                await MainActor.run {
                    self.hasLocalSdp = true
                }
                // シグナリングサーバー経由でOfferSDPを送信する
                self.signalClient.send(sdp: sdp)
            }
        case .answer:
            Task.detached {
                // LocalAnswerSDPを生成
                let localSdp = try await self.webRTCClient.answer()
                await MainActor.run {
                    self.hasLocalSdp = true
                }
                // シグナリングサーバー経由でAnswerSDPを送信する
                self.signalClient.send(sdp: localSdp)
            }
        }
    }
}

// MARK: - Signaling
extension MainViewModel: SignalingClientDelegate {
    // シグナリングサーバーとの接続が完了
    func signalClientDidConnect(_ signalClient: SignalingClient) {
        Task { @MainActor in
            signalingConnected = true
        }
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        Task { @MainActor in
            signalingConnected = false
        }
    }
    
    // Remote SDPを受け取る
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        print("Received remote sdp")
        
        Task {
            do {
                try await self.webRTCClient.set(remoteSdp: sdp)
                await MainActor.run { self.hasRemoteSdp = true }
            } catch {
                await MainActor.run { self.hasRemoteSdp = false }
                debugPrint("Error setting remote SDP: \(error)")
            }
        }
    }
    
    // Remote candidateを受け取る
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        print("Received remote candidate")
        
        Task {
            do {
                try await self.webRTCClient.set(remoteCandidate: candidate)
                await MainActor.run { self.remoteCandidateCount += 1 }
            } catch {
                debugPrint("Error setting remote candidate: \(error)")
            }
        }
    }
}

// MARK: - WebRTC
extension MainViewModel: WebRTCClientDelegate {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        Task { @MainActor in
            print("discovered local candidate")
            self.localCandidateCount += 1
            self.signalClient.send(candidate: candidate)
        }
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        Task { @MainActor in
            let textColor: Color
            switch state {
            case .connected, .completed:
                textColor = .green
            case .disconnected:
                textColor = .orange
            case .failed, .closed:
                textColor = .red
            case .new, .checking, .count:
                textColor = .black
            @unknown default:
                textColor = .black
            }
            
            self.webRTCStatusLabel = state.description.capitalized
            self.webRTCStatusTextColor = textColor
        }
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {}
}
