import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        let model = Self.makeModel()
        container = NSPersistentContainer(name: "StepifyModel", managedObjectModel: model)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func save(context: NSManagedObjectContext) {
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            context.rollback()
            assertionFailure("Failed to save context: \(error.localizedDescription)")
        }
    }
}

private extension PersistenceController {
    static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let goalEntity = NSEntityDescription()
        goalEntity.name = "GoalEntity"
        goalEntity.managedObjectClassName = NSStringFromClass(GoalEntity.self)

        let taskEntity = NSEntityDescription()
        taskEntity.name = "TaskEntity"
        taskEntity.managedObjectClassName = NSStringFromClass(TaskEntity.self)

        let goalID = NSAttributeDescription()
        goalID.name = "id"
        goalID.attributeType = .UUIDAttributeType
        goalID.isOptional = false

        let goalTitle = NSAttributeDescription()
        goalTitle.name = "title"
        goalTitle.attributeType = .stringAttributeType
        goalTitle.isOptional = false

        let goalDetails = NSAttributeDescription()
        goalDetails.name = "details"
        goalDetails.attributeType = .stringAttributeType
        goalDetails.isOptional = true

        let goalCreatedAt = NSAttributeDescription()
        goalCreatedAt.name = "createdAt"
        goalCreatedAt.attributeType = .dateAttributeType
        goalCreatedAt.isOptional = false

        let goalAccent = NSAttributeDescription()
        goalAccent.name = "accentKey"
        goalAccent.attributeType = .stringAttributeType
        goalAccent.isOptional = false
        goalAccent.defaultValue = GoalPalette.sunrise.rawValue

        let taskID = NSAttributeDescription()
        taskID.name = "id"
        taskID.attributeType = .UUIDAttributeType
        taskID.isOptional = false

        let taskTitle = NSAttributeDescription()
        taskTitle.name = "title"
        taskTitle.attributeType = .stringAttributeType
        taskTitle.isOptional = false

        let taskIsCompleted = NSAttributeDescription()
        taskIsCompleted.name = "isCompleted"
        taskIsCompleted.attributeType = .booleanAttributeType
        taskIsCompleted.isOptional = false
        taskIsCompleted.defaultValue = false

        let taskCreatedAt = NSAttributeDescription()
        taskCreatedAt.name = "createdAt"
        taskCreatedAt.attributeType = .dateAttributeType
        taskCreatedAt.isOptional = false

        let goalToTasks = NSRelationshipDescription()
        goalToTasks.name = "tasks"
        goalToTasks.destinationEntity = taskEntity
        goalToTasks.minCount = 0
        goalToTasks.maxCount = 0
        goalToTasks.deleteRule = .cascadeDeleteRule
        goalToTasks.isOptional = true
        goalToTasks.isOrdered = false

        let taskToGoal = NSRelationshipDescription()
        taskToGoal.name = "goal"
        taskToGoal.destinationEntity = goalEntity
        taskToGoal.minCount = 0
        taskToGoal.maxCount = 1
        taskToGoal.deleteRule = .nullifyDeleteRule
        taskToGoal.isOptional = true

        goalToTasks.inverseRelationship = taskToGoal
        taskToGoal.inverseRelationship = goalToTasks

        goalEntity.properties = [goalID, goalTitle, goalDetails, goalCreatedAt, goalAccent, goalToTasks]
        taskEntity.properties = [taskID, taskTitle, taskIsCompleted, taskCreatedAt, taskToGoal]
        model.entities = [goalEntity, taskEntity]

        return model
    }
}
