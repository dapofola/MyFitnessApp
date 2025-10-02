import SwiftUI
import CoreData

struct ActiveWorkoutView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    // The temporary, live workout object being created/edited
    @State private var currentWorkout: Workout
    @State private var workoutStartTime = Date() // To track how long the workout has been active
    
    // State for managing the "Add Exercise" sheet
    @State private var showingAddExerciseSheet = false
    
    // State for tracking the currently selected exercise (used only to set focus after adding)
    @State private var selectedExercise: Exercise?
    
    // Sorted list of all sets in the current workout
    private var sortedSets: [Set] {
        return (currentWorkout.sets?.allObjects as? [Set] ?? [])
            .sorted { (set1, set2) -> Bool in
                // Sort first by exercise index in the workout, then by set creation order (UUID is a good proxy)
                let exerciseOrder = currentWorkout.orderedExercises.firstIndex(of: set1.exercise!) ?? 0
                let exerciseOrder2 = currentWorkout.orderedExercises.firstIndex(of: set2.exercise!) ?? 0
                
                if exerciseOrder != exerciseOrder2 {
                    return exerciseOrder < exerciseOrder2
                }
                
                // Secondary sort by UUID
                return (set1.uuid ?? UUID()) < (set2.uuid ?? UUID())
            }
    }

    // MARK: - Initializer
    init(template: Workout? = nil, context: NSManagedObjectContext) {
        // 1. Create a new managed Workout object
        let newWorkout = Workout(context: context)
        newWorkout.uuid = UUID()
        newWorkout.date = Date()
        newWorkout.isTemplate = false
        newWorkout.name = template?.name ?? "Workout \(Date.now.formatted(date: .numeric, time: .omitted))"

        // 2. If a template is provided, copy its structure (exercises and sets)
        if let template = template {
            newWorkout.name = template.name ?? "New Workout"
            
            // Set up relationship copies (Exercises)
            if let templateExercises = template.exercise as? Swift.Set<Exercise> {
                newWorkout.exercise = NSSet(set: templateExercises)
            }
            
            // Set up relationship copies (Sets)
            if let templateSets = template.sets?.allObjects as? [Set] {
                let newSets = templateSets.map { templateSet -> Set in
                    let newSet = Set(context: context)
                    newSet.uuid = UUID()
                    newSet.reps = templateSet.reps
                    newSet.weight = templateSet.weight
                    newSet.rpe = templateSet.rpe
                    newSet.duration = templateSet.duration
                    newSet.setType = templateSet.setType
                    newSet.exercise = templateSet.exercise
                    return newSet
                }
                newWorkout.sets = NSSet(array: newSets)
            }
        }
        
        _currentWorkout = State(initialValue: newWorkout)
        
        // Initialize selectedExercise for the Add Exercise Sheet if necessary
        if let firstExercise = template?.orderedExercises.first {
            _selectedExercise = State(initialValue: firstExercise)
        }
    }
    
    // MARK: - View Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Workout Name Header
                HStack {
                    TextField("Workout Name", text: Binding(
                        get: { currentWorkout.name ?? "" },
                        set: { currentWorkout.name = $0 }
                    ))
                    .font(.title2.bold())
                    .textFieldStyle(.roundedBorder)
                    .padding(.leading)
                    
                    // Add Exercise Button (Top Right)
                    Button {
                        showingAddExerciseSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .padding(.trailing)
                }
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                
                // MARK: - Exercise List (Disclosure Groups)
                List {
                    ForEach(currentWorkout.orderedExercises, id: \.self) { exercise in
                        ExerciseRowDisclosure(
                            currentWorkout: currentWorkout,
                            exercise: exercise,
                            sets: setsForExercise(exercise),
                            // Pass the set addition function directly
                            addSetAction: { addSet(to: exercise) }
                        )
                    }
                    // This onDelete is for deleting the Exercise from the workout
                    .onDelete { indices in
                        deleteExercise(offsets: indices)
                    }
                }
                .listStyle(.insetGrouped)
                // Note: The main List now handles the exercises, and the sets are within the DisclosureGroup.
            }
            .navigationTitle(currentWorkout.name ?? "Active Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        cancelWorkout()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Finish") {
                        finishWorkout()
                    }
                    .font(.headline)
                }
            }
            .sheet(isPresented: $showingAddExerciseSheet) {
                AddExerciseToWorkoutSheet(currentWorkout: currentWorkout, selectedExercise: $selectedExercise)
            }
            .toolbarBackground(Color(red: 1.0, green: 150/255, blue: 140/255, opacity: 0.05), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    // MARK: - Helper Methods
    
    private func setsForExercise(_ exercise: Exercise) -> [Set] {
        return sortedSets.filter { $0.exercise == exercise }
    }
    
    private func addSet(to exercise: Exercise) {
        let newSet = Set(context: viewContext)
        newSet.uuid = UUID()
        newSet.reps = 0
        newSet.weight = 0.0
        newSet.rpe = 0.0
        newSet.duration = 0
        newSet.setType = SetType.normal.rawValue
        newSet.exercise = exercise
        
        currentWorkout.addToSets(newSet)
        
        // Copy values from the last set of this exercise, if one exists
        if let lastSet = setsForExercise(exercise).last {
            newSet.reps = lastSet.reps
            newSet.weight = lastSet.weight
            newSet.rpe = lastSet.rpe
            newSet.duration = lastSet.duration
            newSet.setType = lastSet.setType
        }
        
        saveContext()
    }
    
    private func deleteExercise(offsets: IndexSet) {
        let exercisesToDelete = offsets.map { currentWorkout.orderedExercises[$0] }
        
        for exercise in exercisesToDelete {
            // Remove all associated sets first
            let setsToClear = setsForExercise(exercise)
            for set in setsToClear {
                viewContext.delete(set)
            }
            
            // Remove the exercise from the workout's relationship
            currentWorkout.removeFromExercise(exercise)
        }
        
        saveContext()
    }
    
    private func finishWorkout() {
        currentWorkout.date = Date()
        currentWorkout.isTemplate = false
        
        saveContext()
        dismiss()
    }
    
    private func cancelWorkout() {
        if let sets = currentWorkout.sets?.allObjects as? [Set] {
            for set in sets {
                viewContext.delete(set)
            }
        }
        viewContext.delete(currentWorkout)
        
        saveContext()
        dismiss()
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error saving context: \(nsError), \(nsError.userInfo)")
        }
    }
}


// MARK: - Utility Extension to Order Exercises in a Workout
extension Workout {
    var orderedExercises: [Exercise] {
        guard let exercisesSet = self.exercise as? Swift.Set<Exercise> else { return [] }
        return exercisesSet.sorted { $0.name ?? "" < $1.name ?? "" }
    }
}

// MARK: - Sub Views

// 1. New Exercise Row using DisclosureGroup (Replaces ExerciseSetSection)
struct ExerciseRowDisclosure: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var currentWorkout: Workout
    @ObservedObject var exercise: Exercise
    var sets: [Set] // Filtered list of sets for this exercise
    let addSetAction: () -> Void
    
    // Keep the disclosure open by default for an active logging screen
    @State private var isExpanded = true

    private func setIndex(for set: Set) -> Int {
        return sets.firstIndex(of: set) ?? 0
    }
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(spacing: 0) {
                // List of Sets
                ForEach(sets) { set in
                    // We use an explicit SetRowView for the UI
                    SetRowView(set: set, index: setIndex(for: set) + 1)
                        .listRowInsets(EdgeInsets()) // Match list appearance
                        .padding(.horizontal)
                }
                .onDelete { indices in
                    deleteSet(offsets: indices)
                }
                
                // Add Set Button (inside the dropdown)
                Button {
                    addSetAction()
                } label: {
                    Text("Add Set")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 8)
                .buttonStyle(.bordered)
                .padding(.horizontal, 16)
                .padding(.top, 4)
            }
            .padding(.top, 4)
            
        } label: {
            // Header: Exercise Name and Set Count Summary
            HStack {
                Text(exercise.name ?? "Unknown Exercise")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(sets.count) Sets")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            // Ensure the disclosure arrow is visible and the tap area is responsive
            .contentShape(Rectangle())
        }
        // Ensure the DisclosureGroup is treated as one list item
        .listRowSeparator(.visible, edges: .top)
        .padding(.vertical, 8)
        .listRowBackground(Color(.systemBackground))
        .toolbarBackground(Color(red: 1.0, green: 150/255, blue: 140/255, opacity: 0.05), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    private func deleteSet(offsets: IndexSet) {
        let setsToDelete = offsets.map { sets[$0] }
        
        for set in setsToDelete {
            currentWorkout.removeFromSets(set)
            viewContext.delete(set)
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Error deleting set: \(error)")
        }
    }
}


// 2. Row for logging a single set
struct SetRowView: View {
    @ObservedObject var set: Set
    let index: Int
    
    var isDurationSet: Bool {
        return set.exercise?.movementType == MovementType.cardio.rawValue
    }
    
    var body: some View {
        HStack {
            // Set Number
            Text("\(index)")
                .font(.headline)
                .frame(width: 25)
            
            Divider()
            
            // MARK: - Input Fields
            Group {
                if isDurationSet {
                    NumericInputView(label: "Time (s)", value: $set.duration)
                    
                } else {
                    NumericInputView(label: "Reps", value: $set.reps)
                    NumericInputView(label: "Weight (kg)", value: $set.weight)
                }
            }
            
            // RPE Input
            NumericInputView(label: "RPE", value: Binding(
                get: { set.rpe },
                set: { set.rpe = min(10.0, max(0.0, $0)) } // Clamp RPE
            ))
        }
        .padding(.vertical, 4)
    }
}

// 3. Custom Numeric Input Field Component (Kept from previous version)
struct NumericInputView: View {
    let label: String
    private let doubleBinding: Binding<Double>?
    private let int16Binding: Binding<Int16>?
    private let isDouble: Bool
    
    init(label: String, value: Binding<Int16>) {
        self.label = label
        self.int16Binding = value
        self.doubleBinding = nil
        self.isDouble = false
    }
    
    init(label: String, value: Binding<Double>) {
        self.label = label
        self.doubleBinding = value
        self.int16Binding = nil
        self.isDouble = true
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            if isDouble, let binding = doubleBinding {
                TextField(label, value: binding, format: .number.precision(.fractionLength(1)))
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
            } else if let binding = int16Binding {
                // Requires the .toInt extension from BindingExtensions.swift
                TextField(label, value: binding.toInt, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
            } else {
                Text("Error: Type Mismatch")
            }
        }
    }
}


// 4. Sheet for adding exercises to the active workout (Kept from previous version)
struct AddExerciseToWorkoutSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var currentWorkout: Workout
    @Binding var selectedExercise: Exercise?
    
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.name!, order: .forward)]
    ) private var allExercises: FetchedResults<Exercise>
    
    @State private var searchText = ""
    
    var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return Array(allExercises)
        } else {
            return allExercises.filter { $0.name?.localizedCaseInsensitiveContains(searchText) ?? false }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                
                List(filteredExercises, id: \.self) { exercise in
                    Button {
                        addExercise(exercise)
                        dismiss()
                    } label: {
                        ExerciseSelectRow(exercise: exercise)
                    }
                }
            }
            .navigationTitle("Add Exercise")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addExercise(_ exercise: Exercise) {
        currentWorkout.addToExercise(exercise)
        selectedExercise = exercise
        
        let newSet = Set(context: viewContext)
        newSet.uuid = UUID()
        newSet.reps = 0
        newSet.weight = 0.0
        newSet.rpe = 0.0
        newSet.duration = 0
        newSet.setType = SetType.normal.rawValue
        newSet.exercise = exercise
        currentWorkout.addToSets(newSet)
        
        do {
            try viewContext.save()
        } catch {
            print("Error adding exercise and initial set: \(error)")
        }
    }
}

// 5. Simple Search Bar component (Kept from previous version)
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search exercises", text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray5))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

// 6. Row view for selecting an exercise (Kept from previous version)
struct ExerciseSelectRow: View {
    @ObservedObject var exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(exercise.name ?? "Untitled Exercise")
                .font(.headline)
            Text("\(exercise.primaryMuscleGroup ?? "N/A") - \(exercise.movementType ?? "N/A")")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
