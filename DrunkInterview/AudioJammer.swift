//
//  AudioJammer.swift
//  SpeechJammer
//
//  Created by Jared Jones on 10/2/23.
//

import AVFoundation

class AudioJammer: ObservableObject {
    private var audioEngine = AVAudioEngine()
    private var delayEffect = AVAudioUnitDelay()
    private var delayChangeTimer: Timer?
    private var volumeChangeTimer: Timer?
    private var mixer = AVAudioMixerNode()


    init() {
        setupAudioSession()
        setupAudioEngine()
    }
    
    deinit {
        delayChangeTimer?.invalidate()
        volumeChangeTimer?.invalidate()
    }

    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth, .allowAirPlay])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session:", error)
        }
    }

    private func setupAudioEngine() {
        let inputNode = audioEngine.inputNode
        let outputNode = audioEngine.outputNode
        
        // Get the format from the input node
        let inputFormat = inputNode.outputFormat(forBus: 0)
        
        // Get the format from the output node
        let outputFormat = outputNode.inputFormat(forBus: 0)

        // Get the format from the input node
        let audioFormat = inputNode.outputFormat(forBus: 0)

        // Configure the delay effect
        delayEffect.delayTime = 0.1 // Delay time in seconds
        delayEffect.feedback = 0
        delayEffect.wetDryMix = 100

        audioEngine.attach(delayEffect)
        audioEngine.attach(mixer)
        
        audioEngine.connect(inputNode, to: delayEffect, format: audioFormat)
        audioEngine.connect(delayEffect, to: mixer, format: audioFormat)
        audioEngine.connect(mixer, to: outputNode, format: audioFormat)
    }


    func startJamming() {
        startDelayChangeTimer()
        let audioSession = AVAudioSession.sharedInstance()
        if audioSession.isInputAvailable {
            do {
                try audioEngine.start()
            } catch {
                print("Error starting audio engine:", error.localizedDescription)
            }
        } else {
            print("Audio input not available")
        }
    }

    func stopJamming() {
        audioEngine.stop()
        delayChangeTimer?.invalidate()
        volumeChangeTimer?.invalidate()
    }
    
    private func startDelayChangeTimer() {
        // Invalidate the previous timer if it exists
        delayChangeTimer?.invalidate()
        volumeChangeTimer?.invalidate()
        
        delayChangeTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            // Randomly change the delay time between 0.05 and 0.2 seconds
            let randomDelay = Double.random(in: 0.1...0.25)
            self.delayEffect.delayTime = randomDelay
        }
        
        volumeChangeTimer = Timer.scheduledTimer(withTimeInterval: 0.9, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            let randomVolume = Float.random(in: 0.9...1.0)
            self.mixer.outputVolume = randomVolume
        }
    }

}
