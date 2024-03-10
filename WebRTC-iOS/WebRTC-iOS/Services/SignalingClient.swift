//
//  SignalingClient.swift
//  WebRTC-iOS
//
//  Created by Yu Wakui on 2024/03/09.
//

import Foundation
import WebRTC

protocol SignalingClientDelegate {
    func signalClientDidConnect(_ signalClient: SignalingClient)
    func signalClientDidDisconnect(_ signalClient: SignalingClient)
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription)
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate)
}

final class SignalingClient {
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let webSocket: WebSocketProvider
    var delegate: SignalingClientDelegate?
    
    init(webSocket: WebSocketProvider) {
        self.webSocket = webSocket
    }
    
    func connect() {
        webSocket.delegate = self
        webSocket.connect()
    }
    
    func send(sdp rtcSdp: RTCSessionDescription) {
        do {
            let message = Message.sdp(SessionDescription(from: rtcSdp))
            let dataMessage = try encoder.encode(message)
            webSocket.send(data: dataMessage)
        } catch {
            debugPrint("Warning: Could not encode sdp: \(error)")
        }
    }
    
    func send(candidate rtcIceCandidate: RTCIceCandidate) {
        do {
            let message = Message.candidate(IceCandidate(from: rtcIceCandidate))
            let dataMessage = try self.encoder.encode(message)
            self.webSocket.send(data: dataMessage)
        }
        catch {
            debugPrint("Warning: Could not encode candidate: \(error)")
        }
    }
}

extension SignalingClient: WebSocketProviderDelegate {
    func webSocketDidConnect(_ webSocket: WebSocketProvider) {
        delegate?.signalClientDidConnect(self)
    }
    
    func webSocketDidDisconnect(_ webSocket: WebSocketProvider) {
        delegate?.signalClientDidDisconnect(self)
        
        // 2秒ごとに再接続を試みる
        Task.detached {
            sleep(2)
            debugPrint("Trying to reconnect to signaling server...")
            self.webSocket.connect()
        }
    }
    
    func webSocket(_ webSocket: WebSocketProvider, didReceiveData data: Data) {
        do {
            // TODO: Error handling when nil without forced unwrapping
            let jsonData: Data = removePrefix(data)!
            let message = try decoder.decode(Message.self, from: jsonData)
            
            switch message {
            case .sdp(let sessionDescription):
                delegate?.signalClient(self, didReceiveRemoteSdp: sessionDescription.rtcSessionDescription)
            case .candidate(let iceCandidate):
                delegate?.signalClient(self, didReceiveCandidate: iceCandidate.rtcIceCandidate)
            }
        } catch {
            debugPrint("Warning: Could not decode incoming message: \(error)")
        }
    }

    func removePrefix(_ data: Data) -> Data? {
        let prefix = "Server received your message: "
        guard let dataString = String(data: data, encoding: .utf8) else {
            return nil
        }

        guard let jsonSubstring = dataString.components(separatedBy: prefix).last else {
            return nil
        }

        guard let jsonData = jsonSubstring.data(using: .utf8) else {
            return nil
        }

        return jsonData
    }
}
