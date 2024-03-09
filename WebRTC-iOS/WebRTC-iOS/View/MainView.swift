//
//  MainView.swift
//  WebRTC-iOS
//
//  Created by Yu Wakui on 2024/03/09.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationView {
            VStack {
                Header()
                
                StatusRow(title: "Signaling status:", content: "{status}")
                StatusRow(title: "Local SDP:", content: "{localSdp}")
                StatusRow(title: "Local Candidates:", content: "{#candidates}")
                StatusRow(title: "Remote SDP: ", content: "{remoteSdp}")
                
                Spacer()
                
                Text("WebRTC Status:")
                    .font(.title)
                    .bold()
                Text("{WebRTC Status}")
                    .font(.title)
                    .bold()
                
                Spacer()
                
                HStack {
                    CustomButon(
                        style: .textOnly,
                        label: "Mute",
                        action: { print("Mute button tapped") }
                    )
                    
                    Spacer()
                    
                    CustomButon(
                        style: .textOnly,
                        label: "Send data",
                        action: { print("Send data button tapped") }
                    )
                }
                
                HStack {
                    CustomButon(
                        style: .textOnly,
                        label: "Speaker",
                        action: { print("Speaker button tapped") }
                    )
                    
                    Spacer()
                    
                    NavigationLink(destination: VideoView()) {
                        Text("Video").foregroundColor(.blue)
                    }
                }
                .padding(.top)
                
                CustomButon(
                    style: .blueBackground,
                    label: "Send Offer",
                    action: { print("Send offer button tapped") }
                )
                .padding(.top)
                
                CustomButon(
                    style: .blueBackground,
                    label: "Send Answer",
                    action: { print("Send answer button tapped") }
                )
                .padding(.top)
                
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            .background(.white)
        }
    }
}

struct Header: View {
    var body: some View {
        Image("header")
            .resizable()
            .scaledToFit()
            .scaleEffect(0.9)
            .padding()
    }
}

struct StatusRow: View {
    let title: String
    let content: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title3)
                .bold()
            Text(content)
                .font(.title3)
            Spacer()
        }
        .padding(.vertical, 10)
    }
}

enum ButtonStyle {
    case textOnly
    case blueBackground
}

struct CustomButon: View {
    
    enum ButtonStyle {
        case textOnly
        case blueBackground
    }
    
    let style: ButtonStyle
    let label: String
    let action: () -> Void
    
    var body: some View {
        switch style {
        case .textOnly:
            Button(action: action) {
                Text(label)
                    .foregroundColor(.blue)
            }
        case .blueBackground:
            Button(action: action) {
                Text(label)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(.blue)
        }
    }
}



#Preview {
    MainView()
}
