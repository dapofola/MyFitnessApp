// TemplateSetEditorView
//
// View for users to edit or create new template workouts
//
// Created by Dapo Folami
import SwiftUI

struct TemplateSetEditorView: View {
    // The specific exercise and its sets within the template state
    @Binding var templateExercise: TemplateExercise
    
    // Assumes SetType enum is defined in FitnessEnums.swift
    // let setTypes = SetType.allCases

    var body: some View {
        Form {
            Section("Sets for \(templateExercise.exercise.name ?? "Exercise")") {
                // Display and edit individual sets
                ForEach($templateExercise.sets) { $set in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Set \(templateExercise.sets.firstIndex(where: { $0.id == set.id })! + 1)")
                            .font(.headline)
                        
                        // Set Type Picker
                        Picker("Type", selection: $set.setType) {
                            ForEach(SetType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        
                        // Reps and Weight (using a stepper/TextField combo for control)
                        HStack {
                            Stepper("\(set.reps) Reps", value: $set.reps, in: 0...100)
                            Divider()
                            TextField("Weight (kg)", value: $set.weight, format: .number)
                                .keyboardType(.decimalPad)
                                .frame(width: 100)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        // RPE and Duration
                        HStack {
                            Text("RPE: \(set.rpe, specifier: "%.1f")")
                            Slider(value: $set.rpe, in: 1...10, step: 0.5)
                        }
                        
                        HStack {
                            Text("Duration (sec):")
                            Spacer()
                            TextField("Duration", value: $set.duration, format: .number)
                                .keyboardType(.numberPad)
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    .padding(.vertical, 5)
                }
                .onDelete(perform: deleteSet)

                // Add Set Button
                Button {
                    templateExercise.sets.append(TemplateSet())
                } label: {
                    Label("Add Set", systemImage: "plus.circle.fill")
                }
            }
        }
        .navigationTitle(templateExercise.exercise.name ?? "Set Editor")
        .navigationBarItems(trailing: EditButton())
        .onAppear {
            // Ensure at least one set exists when opening a new exercise
            if templateExercise.sets.isEmpty {
                templateExercise.sets.append(TemplateSet())
            }
        }
    }
    
    private func deleteSet(offsets: IndexSet) {
        templateExercise.sets.remove(atOffsets: offsets)
    }
}
