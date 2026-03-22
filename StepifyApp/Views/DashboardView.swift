import CoreData
import SwiftUI

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var store: PurchaseManager
    @FetchRequest(fetchRequest: GoalEntity.fetchRequestAll()) private var goals: FetchedResults<GoalEntity>

    @State private var isPresentingComposer = false
    @State private var isPresentingPaywall = false

    private var completedGoals: Int {
        goals.filter { $0.completionRatio >= 1 && !$0.taskArray.isEmpty }.count
    }

    private var totalTasks: Int {
        goals.reduce(0) { $0 + $1.taskArray.count }
    }

    private var completedTasks: Int {
        goals.reduce(0) { $0 + $1.completedCount }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(hex: 0xFFF7ED), Color(hex: 0xEEF2FF), Color(hex: 0xE0F2FE)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        DashboardHeaderView(goalsCount: goals.count, completedGoals: completedGoals, completedTasks: completedTasks, totalTasks: totalTasks)

                        if goals.isEmpty {
                            EmptyDashboardView(addAction: { isPresentingComposer = true })
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(goals) { goal in
                                    GoalCardView(goal: goal)
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Stepify")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Unlock") {
                        isPresentingPaywall = true
                    }
                    .font(.subheadline.weight(.semibold))
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if goals.count >= 3 && !store.unlockedUnlimitedGoals {
                            isPresentingPaywall = true
                        } else {
                            isPresentingComposer = true
                        }
                    } label: {
                        Label("New Goal", systemImage: "plus.circle.fill")
                    }
                    .fontWeight(.bold)
                }
            }
            .sheet(isPresented: $isPresentingComposer) {
                GoalComposerSheet()
                    .environment(\.managedObjectContext, context)
            }
            .sheet(isPresented: $isPresentingPaywall) {
                PaywallView()
                    .environmentObject(store)
            }
        }
    }
}

private struct DashboardHeaderView: View {
    let goalsCount: Int
    let completedGoals: Int
    let completedTasks: Int
    let totalTasks: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Make big ambitions feel achievable.")
                .font(.largeTitle.bold())
                .foregroundStyle(.primary)

            Text("Create a goal, split it into actionable milestones, and build momentum one checkmark at a time.")
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                MetricPill(title: "Goals", value: "\(goalsCount)", icon: "flag.checkered.2.crossed")
                MetricPill(title: "Wins", value: "\(completedGoals)", icon: "sparkles")
                MetricPill(title: "Tasks", value: totalTasks == 0 ? "0" : "\(completedTasks)/\(totalTasks)", icon: "checklist")
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                }
        )
    }
}

private struct MetricPill: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.bold())
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct EmptyDashboardView: View {
    let addAction: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "circle.hexagongrid.fill")
                .font(.system(size: 52))
                .foregroundStyle(.orange, .purple)
            Text("Start your first goal map")
                .font(.title2.bold())
            Text("Stepify keeps your planning original and focused: write the goal, list the steps, then track progress with simple cards.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Create Goal", action: addAction)
                .buttonStyle(.borderedProminent)
                .tint(.purple)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}
