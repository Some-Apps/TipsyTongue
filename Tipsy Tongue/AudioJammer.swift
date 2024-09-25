//
//  AudioJammer.swift
//  SpeechJammer
//
//  Created by Jared Jones on 10/2/23.
//

import AVFoundation
import SwiftUI

class AudioJammer: ObservableObject {
    private var delayChangeTimer: Timer?
    private var volumeChangeTimer: Timer?
    private var pitchChangeTimer: Timer?
    private var mixer = AVAudioMixerNode()
    
    private var recordingEngine = AVAudioEngine()
    private var playbackEngine = AVAudioEngine()
    private var playbackNode: AVAudioPlayerNode!

    private var delayEffect = AVAudioUnitDelay()
    private var pitchEffect = AVAudioUnitTimePitch()
    
    private var buffer: AVAudioPCMBuffer? // This will hold the recorded audio samples
    private var isBufferReadyForPlayback = false // A flag to indicate when there's enough data in the buffer for playback
    private var playerNode: AVAudioPlayerNode! // This node will play audio from our buffer
    private var bufferDuration: TimeInterval = 0.1 // Length of time for our buffer, e.g., 0.5 seconds
    private var bufferWritePosition: AVAudioFramePosition = 0 // This keeps track of where to write next in our buffer
    private var individualBufferDuration: TimeInterval = 0.1 // Adjust this for desired delay

    
    private var buffers: [AVAudioPCMBuffer] = []
    private let numberOfBuffers = 10
    private var currentBufferIndex = 0
    
    @AppStorage("delayChangeInterval") var delayChangeInterval = 0.5
    @AppStorage("pitchChangeInterval") var pitchChangeInterval = 0.6
    @AppStorage("volumeChangeInterval") var volumeChangeInterval = 0.7
    @AppStorage("minimumDelay") var minimumDelay = 0.0
    @AppStorage("maximumDelay") var maximumDelay = 0.25
    @AppStorage("minimumPitch") var minimumPitch = -100
    @AppStorage("maximumPitch") var maximumPitch = 100
    @AppStorage("minimumVolume") var minimumVolume = 0.5
    @AppStorage("maximumVolume") var maximumVolume = 1.0

    init() {
            setupAudioSession()
            setupRecordingEngine()
            setupPlaybackEngine()
        }
    
    deinit {
        delayChangeTimer?.invalidate()
        volumeChangeTimer?.invalidate()
        pitchChangeTimer?.invalidate()
        
        recordingEngine.stop()
        playbackEngine.stop()
        
        recordingEngine.inputNode.removeTap(onBus: 0)
    }

    
    private func setupRecordingEngine() {
        let inputNode = recordingEngine.inputNode
        let audioFormat = inputNode.outputFormat(forBus: 0)

        print("Recording channel count:", audioFormat.channelCount)

        // Determine the buffer capacity based on the number of buffers and the desired buffer duration
//        let bufferSampleFrameCapacity = AVAudioFrameCount(audioFormat.sampleRate * bufferDuration / Double(numberOfBuffers))
//        let individualBufferDuration: TimeInterval = 0.1 // You can adjust this for desired delay
        let bufferSampleFrameCapacity = AVAudioFrameCount(audioFormat.sampleRate * individualBufferDuration)


        // Initialize the buffers
        for _ in 0..<numberOfBuffers {
            let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: bufferSampleFrameCapacity)!
            buffers.append(buffer)
        }
        
        inputNode.installTap(onBus: 0, bufferSize: bufferSampleFrameCapacity, format: audioFormat) { [weak self] (incomingBuffer, time) in
            guard let self = self else { return }
            
            let currentBuffer = self.buffers[self.currentBufferIndex]
            
            // Copy the incoming data to the current buffer
            self.copyAudioData(from: incomingBuffer, fromFrame: 0, to: currentBuffer, toFrame: AVAudioFramePosition(currentBuffer.frameLength), count: incomingBuffer.frameLength)
            
            currentBuffer.frameLength += incomingBuffer.frameLength
            
            // If the current buffer is full, schedule it for playback
            if currentBuffer.frameLength == currentBuffer.frameCapacity {
                self.playbackNode.scheduleBuffer(currentBuffer, completionHandler: nil)
                if !self.playbackNode.isPlaying {
                    self.playbackNode.play()
                }
                // Move to the next buffer and reset its frame length
                self.currentBufferIndex = (self.currentBufferIndex + 1) % self.numberOfBuffers
                self.buffers[self.currentBufferIndex].frameLength = 0
            }
        }
    }

    
    private func copyAudioData(from sourceBuffer: AVAudioPCMBuffer, fromFrame: AVAudioFramePosition, to destinationBuffer: AVAudioPCMBuffer, toFrame: AVAudioFramePosition, count: AVAudioFrameCount) {
        let sourceData = sourceBuffer.floatChannelData!
        let destinationData = destinationBuffer.floatChannelData!
        
        for channelIndex in 0..<Int(sourceBuffer.format.channelCount) {
            let sourceChannel = sourceData[channelIndex]
            let destinationChannel = destinationData[channelIndex]
            
            for frameIndex in 0..<Int(count) {
                destinationChannel[frameIndex + Int(toFrame)] = sourceChannel[frameIndex + Int(fromFrame)]
            }
        }
    }

    
    private func setupPlaybackEngine() {
        playbackNode = AVAudioPlayerNode()
        playbackEngine.attach(playbackNode)
        playbackEngine.attach(pitchEffect)
        playbackEngine.attach(mixer)
        playbackEngine.attach(delayEffect)
        
        delayEffect.delayTime = 0
        delayEffect.feedback = 0
        delayEffect.wetDryMix = 100
        
        pitchEffect.pitch = 0
        
        let recordingAudioFormat = recordingEngine.inputNode.outputFormat(forBus: 0)
        
        playbackEngine.connect(playbackNode, to: pitchEffect, format: recordingAudioFormat)
        playbackEngine.connect(pitchEffect, to: mixer, format: recordingAudioFormat)
        playbackEngine.connect(mixer, to: delayEffect, format: recordingAudioFormat)
        playbackEngine.connect(delayEffect, to: playbackEngine.mainMixerNode, format: recordingAudioFormat)
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
    
    func startJamming() {
            startDelayChangeTimer()
            startVolumeChangeTimer()
            startPitchChangeTimer()

            // Start recording and playback engines here:
        // Check if engines are running before trying to start them
            if !recordingEngine.isRunning {
                do {
                    try recordingEngine.start()
                } catch {
                    print("Error starting recording engine:", error)
                }
            }
            
            if !playbackEngine.isRunning {
                do {
                    try playbackEngine.start()
                } catch {
                    print("Error starting playback engine:", error)
                }
            }
    }
    
    func stopJamming() {
        recordingEngine.stop()
        playbackEngine.stop()
        delayChangeTimer?.invalidate()
        volumeChangeTimer?.invalidate()
        pitchChangeTimer?.invalidate() // Invalidate the pitch change timer

    }
    
    private func startDelayChangeTimer() {
        // Invalidate the previous timer if it exists
        delayChangeTimer?.invalidate()
        
        delayChangeTimer = Timer.scheduledTimer(withTimeInterval: delayChangeInterval, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            // Randomly change the delay time between 0.05 and 0.2 seconds
            let randomDelay = Double.random(in: minimumDelay...maximumDelay)
            self.delayEffect.delayTime = randomDelay
        }
    }
    
    private func startVolumeChangeTimer() {
        volumeChangeTimer?.invalidate()
        volumeChangeTimer = Timer.scheduledTimer(withTimeInterval: volumeChangeInterval, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            let randomVolume = Float.random(in: Float(minimumVolume)...Float(maximumVolume))
            self.mixer.outputVolume = randomVolume
        }
    }
    
    private func startPitchChangeTimer() { // 4. Add a timer for pitch change
        pitchChangeTimer?.invalidate()
        pitchChangeTimer = Timer.scheduledTimer(withTimeInterval: pitchChangeInterval, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            let randomPitch = Float.random(in: Float(minimumPitch)...Float(maximumPitch))
            self.pitchEffect.pitch = randomPitch
        }
    }
}
