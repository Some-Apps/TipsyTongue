//
//  ContentView.swift
//  SpeechJammer
//
//  Created by Jared Jones on 10/2/23.
//

import SwiftUI

struct ContentView: View {
    @State private var isJamming = false
    @StateObject private var audioJammer = AudioJammer()

    var body: some View {
        VStack(spacing: 40) {
            Button(isJamming ? "Stop Jamming" : "Start Jamming") {
                if isJamming {
                    audioJammer.stopJamming()
                } else {
                    audioJammer.startJamming()
                }
                isJamming.toggle()
            }
        }
        .padding()
    }
}


#Preview {
    ContentView()
}
