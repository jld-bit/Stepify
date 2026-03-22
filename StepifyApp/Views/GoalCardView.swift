import SwiftUI

struct GoalCardView: View {
    @Environment(\.managedObjectContext) private var context
    @ObservedObject var goal: GoalEntity
    @State private var newTaskTitle = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text(goal.title)
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                if let details = goal.details, !details.isEmpty {
                    Text(details)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.84))
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Progress")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                    Spacer()
                    Text("\(Int(goal.completionRatio * 100))%")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                }

                AnimatedProgressBar(progress: goal.completionRatio)
            }

            VStack(spacing: 10) {
                ForEach(goal.taskArray, id: \.id) { task in
                    TaskRow(task: task) {
                        task.isCompleted.toggle()
                        PersistenceController.shared.save(context: context)
                    }
                }
            }

            HStack(spacing: 10) {
                TextField("Add another step", text: $newTaskTitle)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .foregroundStyle(.white)

                Button {
                    addTask()
                } label: {
                    Image(systemName: "plus")
                        .font(.headline.bold())
                        .padding(12)
                        .background(Color.white.opacity(0.25), in: Circle())
                }
                .foregroundStyle(.white)
                .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(20)
        .background(
            LinearGradient(colors: goal.palette.colors, startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
        .shadow(color: goal.palette.colors.last?.opacity(0.2) ?? .clear, radius: 18, y: 12)
    }

    private func addTask() {
        let title = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        TaskEntity.create(title: title, in: goal, context: context)
        PersistenceController.shared.save(context: context)
        newTaskTitle = ""
    }
}

private struct TaskRow: View {
    @ObservedObject var task: TaskEntity
    let toggle: () -> Void

    var body: some View {
        Button(action: toggle) {
            HStack(spacing: 12) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                Text(task.title)
                    .strikethrough(task.isCompleted, color: .white.opacity(0.8))
                Spacer()
            }
            .padding(14)
            .foregroundStyle(.white)
            .background(Color.white.opacity(task.isCompleted ? 0.24 : 0.14), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct AnimatedProgressBar: View {
    let progress: Double
    @State private var animatedProgress = 0.0

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.18))
                Capsule()
                    .fill(.white)
                    .frame(width: max(proxy.size.width * animatedProgress, 8))
            }
            .animation(.spring(duration: 0.7, bounce: 0.25), value: animatedProgress)
            .onAppear { animatedProgress = progress }
            .onChange(of: progress) { _, newValue in animatedProgress = newValue }
        }
        .frame(height: 12)
    }
}
