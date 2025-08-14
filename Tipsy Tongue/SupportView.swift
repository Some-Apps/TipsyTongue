import SwiftUI
import StoreKit

struct SupportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview
    @AppStorage("supportViewVisits") private var supportViewVisits = 0

    enum DonationType: String, CaseIterable, Identifiable {
        case monthly = "Monthly"
        case oneTime = "One-Time"
        var id: String { rawValue }
    }
    
    let oneTimePrices: [Double] = [0.99, 1.99, 2.99, 3.99, 4.99, 5.99, 6.99, 7.99, 8.99, 9.99]
    let monthlyPrices: [Double] = [0.99, 1.99, 2.99, 3.99, 4.99, 5.99, 6.99, 7.99, 8.99, 9.99]
    
    @State private var donationType: DonationType = .monthly
    @State private var selectedIndex: Double = 0

    @State private var products: [Product] = []
    @State private var purchaseResult: Product.PurchaseResult?
    
    // TODO: Replace these identifiers with your App Store Connect product IDs
    private var oneTimeProductIDs: [String] = ["donate1", "donate2", "donate3", "donate4", "donate5", "donate6", "donate7", "donate8", "donate9", "donate10"]
    private var monthlyProductIDs: [String] = ["donateMonthly1", "donateMonthly2", "donateMonthly3", "donateMonthly4", "donateMonthly5", "donateMonthly6", "donateMonthly7", "donateMonthly8", "donateMonthly9", "donateMonthly10"]

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Image("supportBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.2)
                ScrollView {
                    VStack(spacing: 50) {
                        Text("Support The Developer")
                            .font(.title)
                        Text("I hope you're enjoying the app. Please consider donating a small amount to help me continue developing more free apps. Thank you!")
                        
                        Picker("Donation Type", selection: $donationType) {
                            ForEach(DonationType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        let prices = donationType == .oneTime ? oneTimePrices : monthlyPrices
                        VStack {
                            Text(verbatim: String(format: "$%.2f", prices[Int(selectedIndex)]))
                                .font(.title)
                            
                            Text(donationType == .monthly ? "MONTHLY" : "ONE TIME")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                        }
                        Slider(value: $selectedIndex, in: 0...Double(prices.count - 1), step: 1)
                        VStack {
                            Button("Donate") {
                                let idx = Int(selectedIndex)
                                guard idx < products.count else { return }
                                let product = products[idx]
                                Task {
                                    do {
                                        let result = try await product.purchase()
                                        purchaseResult = result
                                        switch result {
                                        case .success(let verification):
                                            switch verification {
                                            case .verified(let transaction):
                                                await transaction.finish()
                                                // TODO: Notify user of success
                                            case .unverified(_, let error):
                                                print("Transaction could not be verified: \(error)")
                                            }
                                        case .pending:
                                            print("Purchase pending")
                                        case .userCancelled:
                                            print("User cancelled purchase")
                                        @unknown default:
                                            break
                                        }
                                    } catch {
                                        print("Purchase failed: \(error)")
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            .font(.title)
                            Button("Restore Purchase") {
                                
                            }
                        }
                        
                        Text("Apple will charge you \(String(format: "$%.2f", prices[Int(selectedIndex)])) \(donationType == .monthly ? "per month" : "once") after you complete your purchase.")
                            .font(.footnote)
                        HStack {
                            Link(destination: URL(string: "https://sites.google.com/view/someapps/speech-jammer")!) {
                                Text("Privacy Policy")
                            }
                            Text("|")
                            Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                                Text("Terms & Conditions")
                            }
                        }
                        .font(.footnote)
                    }
                    .padding(.horizontal)
                    .padding(.top, 50)
                    .frame(width: UIScreen.main.bounds.width, alignment: .center)
                }
                .task(id: donationType) {
                    do {
                        let ids = donationType == .monthly ? monthlyProductIDs : oneTimeProductIDs
                        products = try await Product.products(for: ids)
                    } catch {
                        print("Failed to fetch products: \(error)")
                    }
                }
                .onAppear {
                    supportViewVisits += 1
                    // Request review on every 3rd visit to support view
                    if supportViewVisits % 3 == 0 {
                        requestReview()
                    }
                }
            
            }
        }
    }
}

#Preview {
    SupportView()
}
