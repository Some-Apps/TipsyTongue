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
    
    var body: some View {
        ZStack {
//            AnimatedBackgroundView()
//                .ignoresSafeArea(.all)
            
            VStack {
                Text("Tip Jar")
                    .font(.largeTitle)
                    .bold()
                
                ForEach(viewModel.products.sorted(by: { $0.displayPrice < $1.displayPrice }), id: \.self) { product in
                    TipOption(viewModel: viewModel, option: product.displayName, optionPrice: product.displayPrice, product: product)
                }

            }
            .padding()

        }
        .onAppear {
            viewModel.fetchProducts()
        }
    }
}

struct TipOption: View {
    @ObservedObject var viewModel: TipJarViewModel

    let option: String
    let optionPrice: String
    let product: Product
    
    var body: some View {
        Button {
            viewModel.purchase(product: product)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(.thickMaterial)
                    .frame(maxHeight: 100)
                
                VStack {
                    HStack {
                        Spacer()
                        Text(option)
                        Spacer()
                        Text(optionPrice)
                        Spacer()
                    }
                    .font(.title3)
                    .bold()
                    .padding()
                }
            }
        }
        .padding(.horizontal)
    }
}


#Preview {
    TipJarView()
}
