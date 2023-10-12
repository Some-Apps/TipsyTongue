//
//  OptionsView.swift
//  DrunkInterview
//
//  Created by Jared Jones on 10/6/23.
//

import SwiftUI

struct OptionsView: View {
    @AppStorage("delayChangeInterval") var delayChangeInterval = 0.5
    @AppStorage("pitchChangeInterval") var pitchChangeInterval = 0.6
    @AppStorage("volumeChangeInterval") var volumeChangeInterval = 0.7
    @AppStorage("minimumDelay") var minimumDelay = 0.0
    @AppStorage("maximumDelay") var maximumDelay = 0.25
    @AppStorage("minimumPitch") var minimumPitch = -100
    @AppStorage("maximumPitch") var maximumPitch = 100
    @AppStorage("minimumVolume") var minimumVolume = 0.5
    @AppStorage("maximumVolume") var maximumVolume = 1.0
    
    var body: some View {
  
            Form {
                Section("Delay") {
                    Stepper("Interval: \(String(format: "%.1f", delayChangeInterval))", value: $delayChangeInterval, in: 0.2...2, step: 0.1)
                    Stepper("Minimum: \(String(format: "%.2f", minimumDelay))", value: $minimumDelay, in: 0...maximumDelay, step: 0.01)
                    Stepper("Maximum: \(String(format: "%.2f", maximumDelay))", value: $maximumDelay, in: minimumDelay...1, step: 0.01)
                }
                Section("Pitch") {
                    Stepper("Interval: \(String(format: "%.1f", pitchChangeInterval))", value: $pitchChangeInterval, in: 0.2...2, step: 0.1)
                    Stepper("Minimum: \(minimumPitch)", value: $minimumPitch, in: -500...maximumPitch, step: 50)
                    Stepper("Maximum: \(maximumPitch)", value: $maximumPitch, in: minimumPitch...500, step: 50)
                }
                Section("Volume") {
                    Stepper("Interval: \(String(format: "%.1f", volumeChangeInterval))", value: $volumeChangeInterval, in: 0.2...2, step: 0.1)
                    Stepper("Minimum: \(String(format: "%.1f", minimumVolume))", value: $minimumVolume, in: 0...maximumVolume, step: 0.1)
                    Stepper("Maximum: \(String(format: "%.1f", maximumVolume))", value: $maximumVolume, in: minimumVolume...1, step: 0.1)
                }
                Section {
                    Button("Reset To Default") {
                        delayChangeInterval = 0.5
                        pitchChangeInterval = 0.6
                        volumeChangeInterval = 0.7
                        minimumDelay = 0.0
                        maximumDelay = 0.25
                        minimumPitch = -100
                        maximumPitch = 100
                        minimumVolume = 0.5
                        maximumVolume = 1.0
                    }
                }
                Section {
                    Text("Interval refers to the number of seconds before the value is changed to a random number between minimum and maximum. The default values are what I've found to be most effective for me. The most effective values will change from person to person.")
                }
            }
        
        
    }
}

#Preview {
    OptionsView()
}
