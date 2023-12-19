//
//  ContentView.swift
//  SpeechJammer
//
//  Created by Jared Jones on 10/2/23.
//

import AlertToast
import FirebaseFirestore
import SwiftUI
import StoreKit

struct ContentView: View {
//    @ObservedObject var viewModel = TipJarViewModel()
    @State private var tongueTwisterPrompts = [String]()
    @State private var openEndedPrompts = [String]()

    @State private var isJamming = false
    @State private var showTipJar = false
    @State private var showOptions = false
    @State private var resetJammer = false
    @AppStorage("currentPrompt") var currentPrompt = "Peter Piper picked a peck of pickled peppers. A peck of pickled peppers Peter Piper picked. If Peter Piper picked a peck of pickled peppers, Where’s the peck of pickled peppers Peter Piper picked?"
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
                    .bold()
                    .padding()
                    .multilineTextAlignment(.center)
                    .onChange(of: resetJammer) { newValue in
                        if newValue {
                            audioJammer = AudioJammer()
                        }
                    }
                Text("Turn up the volume as high as you are comfortable with, tap \"Start Jamming\", and try to speak. (Make sure to use earbuds or headphones)")
                    .font(.headline)
                    .padding()
                    .multilineTextAlignment(.center)
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
                    Label(isJamming ? "Stop Jamming" : "Start Jamming", systemImage: "mic")
                }
                .font(.title)
                .bold()
                .buttonStyle(.bordered)
                .tint(isJamming ? .red : .green)
                Spacer()
                VStack {
                    
                    HStack {
                        Button("Tongue Twister") {
                            getRandomPrompt(from: "Tongue Twisters")
                        }
                        Button("Open Ended Prompt") {
                            getRandomPrompt(from: "Open Ended Questions")
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.primary)
                    Text(currentPrompt)
                        .frame(maxWidth: .infinity, maxHeight: 200)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.thinMaterial)
                                .frame(height: 200)
                        }
                }
                HStack {
                    Button("Tip Jar") {
                        showTipJar = true
                    }
                    Spacer()
                    Button("Rate App") {
                        if let url = URL(string: "https://apps.apple.com/app/id6468891787?action=write-review") {
                            UIApplication.shared.open(url)
                        }
                    }
                    Spacer()
                    Button("Mixer") {
                        showOptions = true
                    }
                }
                .padding()
                .buttonStyle(.borderless)
                .tint(.primary)
            }
            .padding()
        }
        .onAppear {
                   fetchAllPrompts()
               }
        .sheet(isPresented: $showTipJar) {
            TipJarView()
        }
        .sheet(isPresented: $showOptions) {
            OptionsView()
        }
    }
    
    func fetchAllPrompts() {
            let db = Firestore.firestore()
            db.collection("Tongue Twisters").getDocuments { (snapshot, error) in
                if let documents = snapshot?.documents {
                    self.tongueTwisterPrompts = documents.compactMap { $0.data()["prompt"] as? String }
                }
            }
        db.collection("Open Ended Questions").getDocuments { (snapshot, error) in
            if let documents = snapshot?.documents {
                self.openEndedPrompts = documents.compactMap { $0.data()["prompt"] as? String }
            }
        }
        }
    
    func getRandomPrompt(from collectionName: String) {
        if collectionName == "Tongue Twisters" {
            let filteredPrompts = tongueTwisterPrompts.filter { $0 != self.currentPrompt }

            guard !filteredPrompts.isEmpty else {
                print("No other prompts available in \(collectionName)")
                return
            }

            // Get a random prompt
            if let randomPrompt = filteredPrompts.randomElement() {
                DispatchQueue.main.async {
                    self.currentPrompt = randomPrompt
                }
            }
        } else if collectionName == "Open Ended Questions" {
            let filteredPrompts = openEndedPrompts.filter { $0 != self.currentPrompt }

            guard !filteredPrompts.isEmpty else {
                print("No other prompts available in \(collectionName)")
                return
            }

            // Get a random prompt
            if let randomPrompt = filteredPrompts.randomElement() {
                DispatchQueue.main.async {
                    self.currentPrompt = randomPrompt
                }
            }
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
