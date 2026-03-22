import CoreData
import Foundation

@objc(GoalEntity)
public final class GoalEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var details: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var accentKey: String
    @NSManaged public var tasks: Set<TaskEntity>?
}

@objc(TaskEntity)
public final class TaskEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var isCompleted: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var goal: GoalEntity?
}

extension GoalEntity {
    static func fetchRequestAll() -> NSFetchRequest<GoalEntity> {
        let request = NSFetchRequest<GoalEntity>(entityName: "GoalEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \GoalEntity.createdAt, ascending: false)]
        return request
    }

    var taskArray: [TaskEntity] {
        (tasks ?? []).sorted { $0.createdAt < $1.createdAt }
    }

    var completionRatio: Double {
        let tasks = taskArray
        guard !tasks.isEmpty else { return 0 }
        let done = tasks.filter(\.isCompleted).count
        return Double(done) / Double(tasks.count)
    }

    var completedCount: Int {
        taskArray.filter(\.isCompleted).count
    }

    var palette: GoalPalette {
        GoalPalette(rawValue: accentKey) ?? .sunrise
    }
}

extension TaskEntity {
    static func create(title: String, in goal: GoalEntity, context: NSManagedObjectContext) {
        let task = TaskEntity(context: context)
        task.id = UUID()
        task.title = title
        task.createdAt = .now
        task.isCompleted = false
        task.goal = goal
    }
}
