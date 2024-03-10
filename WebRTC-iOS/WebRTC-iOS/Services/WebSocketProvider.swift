//
//  WebSocketProvider.swift
//  WebRTC-iOS
//
//  Created by Yu Wakui on 2024/03/09.
//

import Foundation
import Starscream

protocol WebSocketProviderDelegate {
    func webSocketDidConnect(_ webSocket: WebSocketProvider)
    func webSocketDidDisconnect(_ webSocket: WebSocketProvider)
    func webSocket(_ webSocket: WebSocketProvider, didReceiveData data: Data)
}

class WebSocketProvider {
    private let socket: WebSocket
    var delegate: WebSocketProviderDelegate?
    
    init(url: URL) {
        socket = WebSocket(request: URLRequest(url: url))
        socket.delegate = self
    }
    
    func connect() {
        socket.connect()
    }
    
    func send(data: Data) {
        socket.write(data: data)
    }
}

extension WebSocketProvider: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected:
            delegate?.webSocketDidConnect(self)
        case .disconnected:
            delegate?.webSocketDidDisconnect(self)
        case .text:
            debugPrint("Warning: Expected to receive data format but received a string. Check the websocket server config.")
        case .binary(let data):
            delegate?.webSocket(self, didReceiveData: data)
        default:
            break
        }
    }
}

