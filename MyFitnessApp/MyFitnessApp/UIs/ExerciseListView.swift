import SwiftUI
import CoreData

struct ExerciseListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch all exercises from CoreData, sorted by name
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Exercise.name, ascending: true)],
        animation: .default)
    private var exercises: FetchedResults<Exercise>

    // State for filtering and navigation
    @State private var searchText: String = ""
    @State private var selectedBodyRegion: BodyRegion? = nil
    @State private var selectedMovementType: MovementType? = nil
    @State private var selectedMuscleGroup: PrimaryMuscleGroup? = nil
    @State private var showFilters: Bool = false
    @State private var showNewExerciseSheet: Bool = false

    // Computed property for filtered/searched exercises
    private var filteredExercises: [Exercise] {
        exercises.filter { exercise in
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
                // MARK: - Active Filters Display
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
                
                // MARK: - Exercise List
                ForEach(filteredExercises) { exercise in
                    // NavigationLink for editing the existing exercise
                    NavigationLink {
                        // Requires CreateEditExerciseView.swift to be defined
                        CreateEditExerciseView(existingExercise: exercise)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(exercise.name ?? "Unknown Exercise")
                                .font(.headline)
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
                                if exercise.isCustom {
                                    Text("| Custom").font(.caption2).fontWeight(.bold).foregroundColor(.purple)
                                }
                            }
                        }
                    }
                }
                
                if filteredExercises.isEmpty {
                    Text("No exercises match your criteria.")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Exercises")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                // ADD BUTTON: For creating a new exercise
                Button {
                    showNewExerciseSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                
                // Filter Button
                Button {
                    showFilters = true
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                }
            }
            
            // MARK: - Sheets
            .sheet(isPresented: $showFilters) {
                // Requires FilterSheet.swift to be defined
                FilterSheet(
                    selectedBodyRegion: $selectedBodyRegion,
                    selectedMovementType: $selectedMovementType,
                    selectedMuscleGroup: $selectedMuscleGroup
                )
            }
            // NEW SHEET: For adding a new exercise
            .sheet(isPresented: $showNewExerciseSheet) {
                CreateEditExerciseView()
            }
        }
    }
}

// MARK: - FilterTag Utility View

enum FilterType {
    case region, movement, muscle
}

struct FilterTag: View {
    let label: String
    let type: FilterType
    let action: () -> Void
    
    var color: Color {
        switch type {
        case .region: return .blue
        case .movement: return .green
        case .muscle: return .orange
        }
    }
    
    var body: some View {
        HStack {
            Text(label).font(.caption).fontWeight(.medium)
            Button(action: action) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain) // Ensure button is tappable within the Hstack
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(color)
        .foregroundColor(.white)
        .clipShape(Capsule())
    }
}
