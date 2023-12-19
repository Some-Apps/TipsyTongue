//
//  HelpView.swift
//  DrunkInterview
//
//  Created by Jared Jones on 12/19/23.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 35) {
            Text("How To Use")
                .underline()
                .bold()
            Text("Turn up the volume as high as you are comfortable with, tap \"Start Jamming\", and try to speak. Make sure you are using earbuds or headphones.")
            Text("You can tap \"Tongue Twister\" or \"Open Ended Prompt\" to show a random prompt.")
            Text("Tap the icon in the top right corner to change how the speech jammer works.")
        }
        .padding()
    }
}

#Preview {
    HelpView()
}
