import SwiftUI

struct GoalComposerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel = GoalComposerViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("Main Goal") {
                    TextField("Run my first half marathon", text: $viewModel.title)
                    TextField("Why it matters", text: $viewModel.details, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }

                Section("Visual Energy") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(GoalPalette.allCases) { palette in
                                Button {
                                    viewModel.selectedPalette = palette
                                } label: {
                                    VStack(alignment: .leading, spacing: 10) {
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .fill(LinearGradient(colors: palette.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .frame(width: 120, height: 84)
                                            .overlay(alignment: .topTrailing) {
                                                if viewModel.selectedPalette == palette {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.title3)
                                                        .foregroundStyle(.white)
                                                        .padding(8)
                                                }
                                            }
                                        Text(palette.title)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.primary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }

                Section("Break It Down") {
                    ForEach($viewModel.draftTasks.indices, id: \.self) { index in
                        TextField("Task \(index + 1)", text: $viewModel.draftTasks[index])
                    }

                    Button {
                        viewModel.addTaskField()
                    } label: {
                        Label("Add another task", systemImage: "plus.circle.fill")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(hex: 0xF8FAFC))
            .navigationTitle("New Goal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.save(context: context)
                        dismiss()
                    }
                    .disabled(!viewModel.canSave)
                }
            }
        }
        .presentationDetents([.large])
    }
}
