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
                        SKStoreReviewController.requestReview()
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
        .sheet(isPresented: $showTipJar) {
            TipJarView()
        }
        .sheet(isPresented: $showOptions) {
            OptionsView()
        }
    }
    
    func getRandomPrompt(from collectionName: String) {
        let db = Firestore.firestore()
        let collectionRef = db.collection(collectionName)
        
        // Get the document count to choose a random document
        collectionRef.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else {
                print("No documents found in \(collectionName)")
                return
            }

            // Filter out the current prompt so we don't get it again
            let filteredDocuments = documents.filter {
                ($0.data()["prompt"] as? String) != self.currentPrompt
            }
            
            guard !filteredDocuments.isEmpty else {
                print("No other prompts available in \(collectionName)")
                return
            }

            // Get a random document from the filtered documents
            let randomDoc = filteredDocuments.randomElement()
            guard let prompt = randomDoc?.data()["prompt"] as? String else {
                print("Error retrieving prompt from \(collectionName)")
                return
            }

            // Set the currentPrompt to the retrieved prompt
            DispatchQueue.main.async {
                self.currentPrompt = prompt
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
