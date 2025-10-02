import SwiftUI
import CoreData

struct ExercisePickerSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var exercisesInTemplate: [TemplateExercise]
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Exercise.name, ascending: true)],
        animation: .default
    ) private var allExercises: FetchedResults<Exercise>
    
    // FIX 1: Added the missing @State variable for the filter sheet
    @State private var showFilters: Bool = false
    
    // State for Search and Filter
    @State private var searchText: String = ""
    @State private var selectedBodyRegion: BodyRegion? = nil
    @State private var selectedMovementType: MovementType? = nil
    @State private var selectedMuscleGroup: PrimaryMuscleGroup? = nil

    // FIX 2: Corrected the array syntax (added closing ']')
    private var filteredExercises: [Exercise] {
        allExercises.filter { exercise in
            // 1. Search Filter
            let searchMatch = searchText.isEmpty || (exercise.name?.localizedCaseInsensitiveContains(searchText) ?? false)
            
            // 2. Body Region Filter
            let regionMatch: Bool
            if let region = selectedBodyRegion {
                regionMatch = exercise.bodyRegion == region.rawValue
            } else {
                regionMatch = true
            }
            
            // 3. Movement Type Filter
            let movementMatch: Bool
            if let movement = selectedMovementType {
                movementMatch = exercise.movementType == movement.rawValue
            } else {
                movementMatch = true
            }
            
            // 4. Primary Muscle Group Filter
            let muscleMatch: Bool
            if let muscle = selectedMuscleGroup {
                muscleMatch = exercise.primaryMuscleGroup == muscle.rawValue
            } else {
                muscleMatch = true
            }

            return searchMatch && regionMatch && movementMatch && muscleMatch
        }
    }

    var body: some View {
        NavigationView {
            List {
                // Active Filters Display (using FilterTag, assumed available in scope)
                if selectedBodyRegion != nil || selectedMovementType != nil || selectedMuscleGroup != nil {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            if let region = selectedBodyRegion {
                                FilterTag(label: region.rawValue, type: .region) { selectedBodyRegion = nil }
                            }
                            if let movement = selectedMovementType {
                                FilterTag(label: movement.rawValue, type: .movement) { selectedMovementType = nil }
                            }
                            if let muscle = selectedMuscleGroup {
                                FilterTag(label: muscle.rawValue, type: .muscle) { selectedMuscleGroup = nil }
                            }
                            Button("Clear All") {
                                selectedBodyRegion = nil
                                selectedMovementType = nil
                                selectedMuscleGroup = nil
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                            .controlSize(.small)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Exercise List with Selection Logic
                ForEach(filteredExercises) { exercise in
                    Button {
                        toggleSelection(for: exercise)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(exercise.name ?? "Unknown Exercise")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                HStack {
                                    if let region = exercise.bodyRegion {
                                        Text(region).font(.caption).foregroundColor(.secondary)
                                    }
                                    if let movement = exercise.movementType {
                                        Text("| \(movement)").font(.caption).foregroundColor(.secondary)
                                    }
                                    if let muscle = exercise.primaryMuscleGroup {
                                        Text("| \(muscle)").font(.caption).foregroundColor(.secondary)
                                    }
                                }
                            }
                            Spacer()
                            if isSelected(exercise: exercise) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Exercises")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                // Filter Button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showFilters = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            // Sheet for Filters
            .sheet(isPresented: $showFilters) {
                FilterSheet(
                    selectedBodyRegion: $selectedBodyRegion,
                    selectedMovementType: $selectedMovementType,
                    selectedMuscleGroup: $selectedMuscleGroup
                )
            }
        }
    }
    
    // MARK: - Selection Logic
    
    private func isSelected(exercise: Exercise) -> Bool {
        exercisesInTemplate.contains(where: { $0.exercise.uuid == exercise.uuid })
    }
    
    private func toggleSelection(for exercise: Exercise) {
        if let index = exercisesInTemplate.firstIndex(where: { $0.exercise.uuid == exercise.uuid }) {
            // Deselect: Remove the TemplateExercise from the list
            exercisesInTemplate.remove(at: index)
        } else {
            // Select: Add a new TemplateExercise with default/empty sets
            let newTemplateExercise = TemplateExercise(exercise: exercise)
            exercisesInTemplate.append(newTemplateExercise)
            
            // Keep the list sorted by exercise name for stable display
            exercisesInTemplate.sort { $0.exercise.name ?? "" < $1.exercise.name ?? "" }
        }
    }
}
