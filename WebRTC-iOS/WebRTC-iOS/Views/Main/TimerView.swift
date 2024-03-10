//
//  TimerView.swift
//  WebRTC-iOS
//
//  Created by Yu Wakui on 2024/03/11.
//

import SwiftUI

struct TimerView: View {
    @Binding var currentTime: TimeInterval
    
    private var formattedTime: String {
        let minutes = Int(currentTime) / 60
        let seconds = Int(currentTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        Text("\(formattedTime)")
            .font(.title)
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                currentTime += 1
            }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(currentTime: .constant(0))
    }
}
