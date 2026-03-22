import SwiftUI

@main
struct StepifyApp: App {
    @StateObject private var store = PurchaseManager()
    private let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(store)
                .task {
                    await store.prepare()
                }
        }
    }
}
