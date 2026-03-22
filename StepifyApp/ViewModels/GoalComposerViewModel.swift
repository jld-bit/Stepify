import CoreData
import Foundation

@MainActor
final class GoalComposerViewModel: ObservableObject {
    @Published var title = ""
    @Published var details = ""
    @Published var draftTasks = ["", "", ""]
    @Published var selectedPalette: GoalPalette = .electric

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func addTaskField() {
        draftTasks.append("")
    }

    func save(context: NSManagedObjectContext) {
        let goal = GoalEntity(context: context)
        goal.id = UUID()
        goal.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        goal.details = details.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        goal.createdAt = .now
        goal.accentKey = selectedPalette.rawValue

        draftTasks
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .forEach { TaskEntity.create(title: $0, in: goal, context: context) }

        PersistenceController.shared.save(context: context)
        reset()
    }

    func reset() {
        title = ""
        details = ""
        draftTasks = ["", "", ""]
        selectedPalette = .electric
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
