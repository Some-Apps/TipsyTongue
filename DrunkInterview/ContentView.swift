//
//  ContentView.swift
//  SpeechJammer
//
//  Created by Jared Jones on 10/2/23.
//

import SwiftUI
//import FirebaseStorage

struct ContentView: View {
    @State private var isJamming = false
    @State private var showTipJar = false
    @StateObject private var audioJammer = AudioJammer()

    var body: some View {
        ZStack {
            // Background
            AnimatedBackgroundView()
                .ignoresSafeArea(.all)

            // Content
            VStack(spacing: 30) {
                Text("Drunk Interview")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                Text("Turn up the volume as high as you are comfortable and have your friend interview you with open ended questions.")
                    .font(.headline)
                    .padding(.horizontal)
                Spacer()

                Button(action: {
                    if isJamming {
                        audioJammer.stopJamming()
                    } else {
                        audioJammer.startJamming()
                    }
                    isJamming.toggle()
                }) {
                    Text(isJamming ? "Stop Interview" : "Start Interview")
                }
                .buttonStyle(.borderedProminent)
                .tint(isJamming ? .red : .green)
                
                Spacer()
                HStack {
                    Button("Tip Jar") {
                        showTipJar = true
                    }
                    .buttonStyle(.bordered)
                    .tint(.white)
                }
                .padding()
            }
        }
        .sheet(isPresented: $showTipJar) {
            TipJarView()
        }
    }
}

struct AnimatedBackgroundView: View {
    @State private var animate = false
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [animate ? .blue : .purple, animate ? .purple : .blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true))
            .onAppear {
                self.animate.toggle()
            }
            .ignoresSafeArea()
    }
}


//#Preview {
//    ContentView()
//}
