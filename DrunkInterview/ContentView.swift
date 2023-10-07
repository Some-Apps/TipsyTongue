//
//  ContentView.swift
//  SpeechJammer
//
//  Created by Jared Jones on 10/2/23.
//

import SwiftUI

struct ContentView: View {
    @State private var isJamming = false
    @State private var showTipJar = false
    @State private var showOptions = false
    @State private var resetJammer = false

    @State private var audioJammer: AudioJammer? = AudioJammer()



    var body: some View {
        let jammer = ObservedObject(wrappedValue: audioJammer!)

        ZStack {
            // Background
            AnimatedBackgroundView()
                .ignoresSafeArea(.all)

            // Content
            VStack {
                Text("Tipsy Tongue: Speech Jammer")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                    .multilineTextAlignment(.center)
                    .onChange(of: resetJammer) { newValue in
                        if newValue {
                            audioJammer = AudioJammer()
                        }
                    }

                Text("Turn up the volume as high as you are comfortable with, tap \"Start Jamming\", and try to speak.")
                    .font(.headline)
                    .padding(.horizontal)
                Spacer()

                Button(action: {
                    if isJamming {
                        audioJammer?.stopJamming()
                        audioJammer = AudioJammer()
                    } else {
                        audioJammer?.startJamming()
                    }
                    isJamming.toggle()
                }) {
                    Text(isJamming ? "Stop Jamming" : "Start Jamming")
                }

                .font(.title)
                .buttonStyle(.borderedProminent)
                .tint(isJamming ? .red : .green)
    
                Spacer()
                HStack {
                    Button("Tip Jar") {
                        showTipJar = true
                    }
                    .buttonStyle(.bordered)
                    .tint(.white)
                    Spacer()
                    Button("Options") {
                        showOptions = true
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
        .sheet(isPresented: $showOptions) {
            OptionsView()
        }
    }
}

struct AnimatedBackgroundView: View {
    @State private var animate = false
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [animate ? .blue : .purple, animate ? .purple : .blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
            .onAppear {
                withAnimation {
                    self.animate.toggle()
                }
            }
            .ignoresSafeArea()
    }
}



#Preview {
    ContentView()
}
