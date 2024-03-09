//
//  Config.swift
//  WebRTC-iOS
//
//  Created by Yu Wakui on 2024/03/09.
//

import Foundation

private let defaultSignalingServerUrl = URL(string:"ws://localhost:8080")!

// We use Google's public stun servers. For production apps you should deploy your own stun/turn servers.
private let defaultIceServers = ["stun:stun.l.google.com:19302",
                                     "stun:stun1.l.google.com:19302",
                                     "stun:stun2.l.google.com:19302",
                                     "stun:stun3.l.google.com:19302",
                                     "stun:stun4.l.google.com:19302"]

struct Config {
    let signalingServerUrl: URL
    let webRTCIceServers: [String]
    
    static let `default` = Config(signalingServerUrl: defaultSignalingServerUrl, webRTCIceServers: defaultIceServers)
}
