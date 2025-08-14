import AlertToast
import FirebaseFirestore
import SwiftUI


struct ContentView: View {
    @Environment(\.requestReview) private var requestReview
    @State private var tongueTwisterPrompts = [String]()
    @State private var openEndedPrompts = [String]()
    @State private var isJamming = false
    @State private var showHelp = false
    @State private var showOptions = false
    @State private var resetJammer = false
    @AppStorage("currentPrompt") var currentPrompt = "Peter Piper picked a peck of pickled peppers. A peck of pickled peppers Peter Piper picked. If Peter Piper picked a peck of pickled peppers, Where’s the peck of pickled peppers Peter Piper picked?"
    @AppStorage("currentPromptCategory") var currentPromptCategory = "Tongue Twister"
    @State private var audioJammer: AudioJammer? = AudioJammer()
    @AppStorage("jamSessions") var jamSessions = 0
    @State private var isProcessing = false

    let collections = ["Tongue Twisters", "Open Ended"]
    
    
    var body: some View {
        NavigationView {
        let jammer = ObservedObject(wrappedValue: audioJammer!)
        ZStack {
            
            VStack {
                HStack {
                    Button {
                        showHelp = true
                    } label: {
                        Image(systemName: "questionmark.app")
                    }
                    .padding([.top, .leading])

                    NavigationLink(destination: SupportView()) {
                        Image(systemName: "heart.circle")
                    }
                    .padding([.top, .leading])

                    Spacer()

                    Button {
                        showOptions = true
                    } label: {
                        Image(systemName: "slider.vertical.3")
                    }
                    .padding([.top, .trailing])
                }
                .ignoresSafeArea()
                .fontWeight(.black)
                .font(.title)
                .foregroundStyle(.secondary)
                
                
                Spacer()
                Button {
                    getRandomPrompt(from: collections.randomElement()!)
                } label: {
                    VStack(spacing: 10) {
                        Text(currentPromptCategory)
                            .font(.title2)
                            .underline()
                            .bold()
                            .foregroundStyle(.secondary)
                        Text(currentPrompt)
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(10)
                    .foregroundStyle(.white)
                    .background {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.ultraThinMaterial)
                    }
                    .padding()
                }
            }
            Button(action: {
                isProcessing = true
                if isJamming {
                    DispatchQueue.global(qos: .userInitiated).async {
                        audioJammer?.stopJamming()
                        DispatchQueue.main.async {
                            audioJammer = AudioJammer()
                            jamSessions += 1
                            if jamSessions % 5 == 0 {
                                requestReview()
                            }
                            isJamming.toggle()
                            isProcessing = false
                        }
                    }
                } else {
                    DispatchQueue.global(qos: .userInitiated).async {
                        audioJammer?.startJamming()
                        DispatchQueue.main.async {
                            isJamming.toggle()
                            isProcessing = false
                        }
                    }
                }
            }) {
                    Label(isJamming ? "Stop Jamming" : "Start Jamming", systemImage: "mic")
            }
            .font(.largeTitle)
            .fontWeight(.black)
            .buttonStyle(.bordered)
            .tint(isProcessing ? .gray : (isJamming ? .red : .green))

            .onChange(of: resetJammer) { newValue in
                if newValue {
                    audioJammer = AudioJammer()
                }
            }
        }
        
        .background(.white.opacity(0.1))
        .onAppear {
            fetchAllPrompts()
        }
        .sheet(isPresented: $showHelp) {
            HelpView()
        }
        .sheet(isPresented: $showOptions) {
            OptionsView()
        }
        .toast(isPresenting: $isProcessing) {
            AlertToast(displayMode: .alert, type: .loading)
        }
        
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
        let prompts = collectionName == "Tongue Twisters" ? tongueTwisterPrompts : openEndedPrompts
        let filteredPrompts = prompts.filter { $0 != self.currentPrompt }
        
        if filteredPrompts.isEmpty {
            print("No other prompts available in \(collectionName)")
            DispatchQueue.main.async {
                // You can set a default prompt here or provide some UI feedback
                self.currentPrompt = "No more prompts available."
            }
            return
        }
        
        if let randomPrompt = filteredPrompts.randomElement() {
            DispatchQueue.main.async {
                self.currentPrompt = randomPrompt
                self.currentPromptCategory = collectionName == "Tongue Twisters" ? "Tongue Twister" : "Open Ended"
            }
        } else {
            print("Error selecting a random prompt from \(collectionName)")
        }
    }
}



#Preview {
    ContentView()
}
