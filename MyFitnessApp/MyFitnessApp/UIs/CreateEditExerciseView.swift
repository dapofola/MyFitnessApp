// CreateEditExerciseView
//
// View for users to create new exercises or edit exisitng ones
//
// Created by Dapo Folami

import SwiftUI
import CoreData

struct CreateEditExerciseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    // State for the new/edited exercise properties
    @State private var name: String
    @State private var bodyRegion: BodyRegion?
    @State private var movementType: MovementType?
    @State private var primaryMuscleGroup: PrimaryMuscleGroup?
    @State private var equipment: Equipment?
    @State private var notes: String
    
    // The optional existing exercise to edit
    let existingExercise: Exercise?

    // MARK: Initializer for both creation and editing
    init(existingExercise: Exercise? = nil) {
        self.existingExercise = existingExercise
        
        // Initialize state variables based on the existing exercise or defaults
        _name = State(initialValue: existingExercise?.name ?? "")
        
        // Use nil as the default for optionals; attempt to initialize from stored string
        _bodyRegion = State(initialValue: BodyRegion(rawValue: existingExercise?.bodyRegion ?? "") ?? nil)
        _movementType = State(initialValue: MovementType(rawValue: existingExercise?.movementType ?? "") ?? nil)
        _primaryMuscleGroup = State(initialValue: PrimaryMuscleGroup(rawValue: existingExercise?.primaryMuscleGroup ?? "") ?? nil)
        _equipment = State(initialValue: Equipment(rawValue: existingExercise?.equipment ?? "") ?? nil)
        
        _notes = State(initialValue: existingExercise?.notes ?? "")
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        // Name must not be empty
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        // Must have at least a Body Region, Movement Type, and Primary Muscle Group
        bodyRegion != nil && movementType != nil && primaryMuscleGroup != nil
    }

    private var availableMovementTypes: [MovementType] {
        if let region = bodyRegion {
            return MovementType.types(for: region)
        } else {
            return MovementType.allCases.filter { $0 != .cardio }
        }
    }

    private var availableMuscleGroups: [PrimaryMuscleGroup] {
        if let movement = movementType {
            return MovementType.groups(for: movement)
        } else {
            return PrimaryMuscleGroup.allCases
        }
    }

    // MARK: - View Body
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Name
                Section("Details") {
                    VStack {
                        TextField("Exercise Name", text: $name)
                            .padding(10)
                            .background(Color.containerBackground)
                            .cornerRadius(8)
                    }
                    .listRowBackground(Color.clear)
                }

                // MARK: - Classification Pickers
                Section("Classification") {
                    Picker("Body Region", selection: $bodyRegion) {
                        Text("Select Region").tag(nil as BodyRegion?)
                        ForEach(BodyRegion.allCases) { region in
                            Text(region.rawValue).tag(region as BodyRegion?)
                        }
                    }
                    .onChange(of: bodyRegion) {
                        // Reset MovementType and MuscleGroup if BodyRegion changes and the selected values are invalid
                        if let region = bodyRegion,
                           let movement = movementType,
                           !MovementType.types(for: region).contains(movement) {
                            movementType = nil
                            primaryMuscleGroup = nil
                        }
                    }

                    Picker("Movement Type", selection: $movementType) {
                        Text("Select Type").tag(nil as MovementType?)
                        ForEach(availableMovementTypes) { type in
                            Text(type.rawValue).tag(type as MovementType?)
                        }
                    }
                    .onChange(of: movementType) {
                        // Reset MuscleGroup if MovementType changes and the selected value is invalid
                        if let movement = movementType,
                           let muscle = primaryMuscleGroup,
                           !MovementType.groups(for: movement).contains(muscle) {
                            primaryMuscleGroup = nil
                        }
                    }

                    Picker("Primary Muscle Group", selection: $primaryMuscleGroup) {
                        Text("Select Group").tag(nil as PrimaryMuscleGroup?)
                        ForEach(availableMuscleGroups) { group in
                            Text(group.rawValue).tag(group as PrimaryMuscleGroup?)
                        }
                    }
                    
                    Picker("Equipment", selection: $equipment) {
                        Text("Select Equipment").tag(nil as Equipment?)
                        ForEach(Equipment.allCases) { equipment in
                            Text(equipment.rawValue).tag(equipment as Equipment?)
                        }
                    }
                }
                
                // MARK: - Notes
                Section("Notes (Optional)") {
                    
                    TextEditor(text: $notes)
                        .frame(minHeight: 150) // Ensure enough height for notes
                        .padding(8)
                        .background(Color.containerBackground) 
                        .cornerRadius(8)
                        .listRowBackground(Color.clear)
                }
            }
            .navigationTitle(existingExercise == nil ? "New Exercise" : "Edit Exercise")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(existingExercise == nil ? "Create" : "Save", action: saveExercise)
                        .disabled(!isFormValid)
                }
            }
            .toolbarBackground(Color(red: 1.0, green: 150/255, blue: 140/255, opacity: 0.05), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    // MARK: - CoreData Save Function
    private func saveExercise() {
        let exercise: Exercise
        
        if let existingExercise = existingExercise {
            // EDITING existing exercise
            exercise = existingExercise
        } else {
            // CREATING new exercise
            exercise = Exercise(context: viewContext)
            exercise.uuid = UUID()
            exercise.isCustom = true // Mark custom for user-added exercises
        }
        
        // Update properties
        exercise.name = name
        exercise.bodyRegion = bodyRegion?.rawValue
        exercise.movementType = movementType?.rawValue
        exercise.primaryMuscleGroup = primaryMuscleGroup?.rawValue
        exercise.equipment = equipment?.rawValue
        exercise.notes = notes
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error saving exercise: \(nsError), \(nsError.userInfo)")
        }
    }
}
