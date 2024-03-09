//
//  VideoView.swift
//  WebRTC-iOS
//
//  Created by Yu Wakui on 2024/03/09.
//

import SwiftUI

struct VideoView: View {
    var body: some View {
        ZStack {
            Color.gray
                .opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    LocalVideoView()
                }
            }
        }
        .navigationBarTitle("Video")
    }
}

struct LocalVideoView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
            Text("Local Video")
                .foregroundColor(.white)
        }
        .frame(
            width: UIScreen.main.bounds.width * 0.33,
            height: UIScreen.main.bounds.height * 0.25
        )
        .padding(.trailing)
    }
}

#Preview {
    VideoView()
}
