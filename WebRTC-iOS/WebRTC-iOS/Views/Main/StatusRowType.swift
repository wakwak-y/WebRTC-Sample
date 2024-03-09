//
//  StatusRowType.swift
//  WebRTC-iOS
//
//  Created by Yu Wakui on 2024/03/09.
//

import SwiftUI

enum StatusRowType {
    case signalingStatus(Bool)
    case localSDP(Bool)
    case localCandidates(Int)
    case remoteSDP(Bool)
    
    func makeRow() -> StatusRowView {
        switch self {
        case .signalingStatus(let connected):
            return StatusRowView(title: "Signaling status:", content: connected ? Text("Connected").foregroundColor(.blue) : Text("Not Connected").foregroundColor(.red))
        case .localSDP(let hasSDP):
            return StatusRowView(title: "Local SDP:", content: hasSDP ? Text("✅").foregroundColor(.green) : Text("❌").foregroundColor(.red))
        case .localCandidates(let count):
            return StatusRowView(title: "Local Candidates:", content: Text("\(count)"))
        case .remoteSDP(let hasSDP):
            return StatusRowView(title: "Remote SDP:", content: hasSDP ? Text("✅").foregroundColor(.green) : Text("❌").foregroundColor(.red))
        }
    }
}
