//
//  TipJarViewModel.swift
//  DrunkInterview
//
//  Created by Jared Jones on 10/3/23.
//

import StoreKit
import SwiftUI
import Foundation

class TipJarViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var productPurchased = false
    @Published var showThankYou = false
    
    func fetchProducts() {
        Task.init {
            do {
                let products = try await Product.products(for: ["SpeechJammer_smallTip", "SpeechJammer_mediumTip", "SpeechJammer_largeTip"])
                DispatchQueue.main.async {
                    self.products = products
                }
            }
            catch {
                print(error)
            }
        }
    }
    
    func purchase(product: Product) {
        Task.init {
            do {
                let result = try await product.purchase()
                switch result {
                case .success(let verification):
                    switch verification {
                    case .verified(let transaction):
                        print(transaction.productID)
                        print("Poduct Purchased!")
                    case .unverified(_):
                        break
                    }
                case .userCancelled:
                    break
                case .pending:
                    break
                 default:
                    break
                }
            }
            catch {
                print(error)
            }
        }
    }
}
