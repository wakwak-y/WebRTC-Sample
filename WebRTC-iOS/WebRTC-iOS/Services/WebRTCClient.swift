//
//  WebRTCClient.swift
//  WebRTC-iOS
//
//  Created by Yu Wakui on 2024/03/09.
//

import Foundation
import WebRTC

protocol WebRTCClientDelegate {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate)
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState)
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data)
}

final class WebRTCClient: NSObject {
    // 新しい RTCPeerConnection インスタンスの生成
    // 新しいRTCPeerConnectionは、新しい呼び出しのたびに作成されなければならないがfactoryは共有する。
    private static let factory: RTCPeerConnectionFactory = {
        RTCInitializeSSL()
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        return RTCPeerConnectionFactory(encoderFactory: videoEncoderFactory, decoderFactory: videoDecoderFactory)
    }()
    
    private var peerConnection: RTCPeerConnection
    private let rtcAudioSession =  RTCAudioSession.sharedInstance()
    private let audioQueue = DispatchQueue(label: "audio")
    private let mediaConstrains = [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
                                   kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue]
    private var localDataChannel: RTCDataChannel?
    private var remoteDataChannel: RTCDataChannel?
    
    var delegate: WebRTCClientDelegate?
    
    init(iceServers: [String]) {
        let config = RTCConfiguration()
        
        // ICEサーバーの設定
        config.iceServers = [RTCIceServer(urlStrings: iceServers)]
        // SDPセマンティクスの設定(統一プラン)
        config.sdpSemantics = .unifiedPlan
        // ICE candidateの収集ポリシーの設定
        // gatherContinuallyは、WebRTCがネットワークの変更を常に監視し、新しい候補を他のクライアントに送信することを可能にする
        config.continualGatheringPolicy = .gatherContinually
        // メディア制約の設定
        // DtlsSrtpKeyAgreementは、Webブラウザと接続できるようにするためにtrueにする必要がある
        let constrains = RTCMediaConstraints(
            mandatoryConstraints: nil,
            optionalConstraints: ["DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueTrue]
        )
        
        
        guard let peerConnection = WebRTCClient.factory.peerConnection(
            with: config,
            constraints: constrains,
            delegate: nil
        ) else {
            fatalError("Could not create new RTCPeerConnection")
        }
        
        self.peerConnection = peerConnection
        
        super.init()
        createMediaSenders()
        configureAudioSession()
        self.peerConnection.delegate = self
    }
    
    private func createMediaSenders() {
        let streamId = "stream"
        
        // Audio
        let audioTrack = createAudioTrack()
        peerConnection.add(audioTrack, streamIds: [streamId])
        
        // Data
        if let dataChannel = createDataChannel() {
            dataChannel.delegate = self
            self.localDataChannel = dataChannel
        }
    }
    
    private func configureAudioSession() {
        rtcAudioSession.lockForConfiguration()
        do {
            try rtcAudioSession.setCategory(.playAndRecord)
            try rtcAudioSession.setMode(.voiceChat)
        } catch {
            debugPrint("Error changeing AVAudioSession category: \(error)")
        }
        rtcAudioSession.unlockForConfiguration()
    }
    
    private func createAudioTrack() -> RTCAudioTrack {
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = WebRTCClient.factory.audioSource(with: audioConstrains)
        return WebRTCClient.factory.audioTrack(with: audioSource, trackId: "audio0")
    }
    
    private func createDataChannel() -> RTCDataChannel? {
        let config = RTCDataChannelConfiguration()
        guard let dataChannel = self.peerConnection.dataChannel(forLabel: "WebRTCData", configuration: config) else {
            debugPrint("Warning: Couldn't create data channel.")
            return nil
        }
        return dataChannel
    }
    
    private func makeOffer(constrains: RTCMediaConstraints) async throws -> RTCSessionDescription {
        return try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<RTCSessionDescription, Error>) in
            peerConnection.offer(for: constrains) { sdp, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let sdp = sdp {
                    self.peerConnection.setLocalDescription(sdp) { error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: sdp)
                        }
                    }
                }
            }
        }
    }
    
    private func makeAnswer(constrains: RTCMediaConstraints) async throws -> RTCSessionDescription {
        return try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<RTCSessionDescription, Error>) in
            peerConnection.answer(for: constrains) { sdp, error in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                else if let sdp = sdp {
                    self.peerConnection.setLocalDescription(sdp) { error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: sdp)
                        }
                    }
                }
            }
        }
    }
}



extension WebRTCClient {
    func offer() async throws -> RTCSessionDescription {
        let constrains = RTCMediaConstraints(
            mandatoryConstraints: self.mediaConstrains,
            optionalConstraints: nil
        )
        return try await makeOffer(constrains: constrains)
    }
    
    func answer() async throws -> RTCSessionDescription {
        let constrains = RTCMediaConstraints(
            mandatoryConstraints: mediaConstrains,
            optionalConstraints: nil
        )
        return try await makeAnswer(constrains: constrains)
    }
    
    func set(remoteSdp: RTCSessionDescription) async throws {
        try await peerConnection.setRemoteDescription(remoteSdp)
    }
    
    func set(remoteCandidate: RTCIceCandidate) async throws {
        try await peerConnection.add(remoteCandidate)
    }
}

// MARK: - RTCPeerConnectionDel
extension WebRTCClient: RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        debugPrint("peerConnection new signaling state: \(stateChanged)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        debugPrint("peerConnection did add stream")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        debugPrint("peerConnection did remove stream")
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        debugPrint("peerConnection should negotiate")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        debugPrint("peerConnection new connection state: \(newState)")
        self.delegate?.webRTCClient(self, didChangeConnectionState: newState)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        debugPrint("peerConnection new gathering state: \(newState)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        self.delegate?.webRTCClient(self, didDiscoverLocalCandidate: candidate)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        debugPrint("peerConnection did remove candidate(s)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        debugPrint("peerConnection did open data channel")
        self.remoteDataChannel = dataChannel
    }
}

// MARK: - RTCDataChannelDelegate
extension WebRTCClient: RTCDataChannelDelegate {
    func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {}
    
    func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {}
}
