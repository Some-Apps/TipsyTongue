//
//  TipJarView.swift
//  DrunkInterview
//
//  Created by Jared Jones on 10/3/23.
//

import SwiftUI
import StoreKit

struct TipJarView: View {
    @StateObject var viewModel = TipJarViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AnimatedBackgroundView()
                .ignoresSafeArea(.all)
            
            VStack {
                Text("Tip Jar")
                    .font(.title)
                    .bold()
                
                ForEach(viewModel.products.sorted(by: { $0.displayPrice < $1.displayPrice }), id: \.self) { product in
                    Button {
                        viewModel.purchase(product: product)
                    } label: {
                        HStack {
                            Text(product.displayName)
                            
                            Text(product.displayPrice)
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.primary)
                }
            }
            .padding()

        }
        .onAppear {
            viewModel.fetchProducts()
        }
    }
}


#Preview {
    TipJarView()
}
