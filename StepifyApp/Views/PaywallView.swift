import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: PurchaseManager

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 22) {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(LinearGradient(colors: [Color(hex: 0xF97316), Color(hex: 0xA855F7), Color(hex: 0x2563EB)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 220)
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Unlock Momentum+")
                                .font(.largeTitle.bold())
                            Text("Use native Apple in-app purchases to enable unlimited goals and deeper tracking metrics.")
                                .font(.subheadline)
                        }
                        .foregroundStyle(.white)
                        .padding(24)
                    }

                VStack(alignment: .leading, spacing: 14) {
                    FeatureRow(icon: "infinity.circle.fill", title: "Unlimited goals", subtitle: "Move beyond the starter limit and plan as many ambitions as you want.")
                    FeatureRow(icon: "chart.line.uptrend.xyaxis.circle.fill", title: "Advanced tracking", subtitle: "Reserve space for richer analytics, streaks, and more detailed insights.")
                    FeatureRow(icon: "lock.shield.fill", title: "Original, native flow", subtitle: "Built with SwiftUI and StoreKit for a clean, unique purchase experience.")
                }

                if store.products.isEmpty {
                    ProgressView("Loading purchase options…")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    VStack(spacing: 12) {
                        ForEach(store.products, id: \.id) { product in
                            Button {
                                Task { await store.purchase(product) }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(product.displayName)
                                            .font(.headline)
                                        Text(product.description)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.leading)
                                    }
                                    Spacer()
                                    Text(product.displayPrice)
                                        .font(.headline.bold())
                                }
                                .padding(18)
                                .background(Color.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Spacer()
            }
            .padding(20)
            .background(Color(hex: 0xF8FAFC).ignoresSafeArea())
            .navigationTitle("Upgrade")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.white)
                .padding(10)
                .background(LinearGradient(colors: [Color(hex: 0xFB923C), Color(hex: 0x8B5CF6)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
