import SwiftUI
import CoreData

// NOTE: Ensure the TemplateSet and TemplateExercise structs from Section 1 are included in this file.

// MARK: - Template Structs (Used for SwiftUI State)
struct TemplateSet: Identifiable, Hashable {
    let id = UUID()
    var reps: Int = 0
    var weight: Double = 0.0
    var rpe: Double = 0.0
    var duration: Int = 0
    var setType: SetType = .normal // Assumes SetType enum exists
    var notes: String = ""
}

struct TemplateExercise: Identifiable, Hashable {
    var id: UUID { exercise.uuid! }
    let exercise: Exercise
    var sets: [TemplateSet] = []
    
    init(exercise: Exercise, existingSets: [Set] = []) {
        self.exercise = exercise
        self.sets = existingSets.map { set in
            TemplateSet(
                reps: Int(set.reps),
                weight: set.weight,
                rpe: set.rpe,
                duration: Int(set.duration),
                setType: SetType(rawValue: set.setType ?? SetType.normal.rawValue) ?? .normal,
                notes: set.notes ?? ""
            )
        }
    }
}


struct CreateEditTemplateView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String
    @State private var exercisesInTemplate: [TemplateExercise] // UPDATED: State holds Exercise + Sets
    @State private var showExercisePicker: Bool = false

    let template: Workout?

    // MARK: - Initializer (Handles Create and Edit)
    init(template: Workout? = nil) {
        self.template = template
        
        _name = State(initialValue: template?.name ?? "My New Template")
        
        // Load existing exercises and their set data from the template
        let initialExercises: [TemplateExercise]
        if let templateExercises = template?.exercise as? Swift.Set<Exercise> {
            initialExercises = templateExercises.compactMap { exercise in
                // Find all sets related to THIS specific exercise and THIS workout
                let setsForExercise = (template?.sets as? Swift.Set<Set> ?? []).filter { $0.exercise == exercise }
                return TemplateExercise(exercise: exercise, existingSets: setsForExercise.sorted(by: { $0.uuid!.hashValue < $1.uuid!.hashValue }))
            }.sorted { $0.exercise.name ?? "" < $1.exercise.name ?? "" } // Sort for stable order
        } else {
            initialExercises = []
        }
        _exercisesInTemplate = State(initialValue: initialExercises)
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationView {
            Form {
                // MARK: - Template Name
                Section {
                    TextField("Template Name (e.g., Push Day)", text: $name)
                        .font(.system(size: 20))
                }
                
                // MARK: - Exercises List
                Section("Exercises (\(exercisesInTemplate.count))") {
                    if exercisesInTemplate.isEmpty {
                        Text("Tap 'Add Exercise' to build this template.")
                            .foregroundColor(.secondary)
                    } else {
                        // Display and allow reordering of exercises
                        ForEach($exercisesInTemplate) { $te in
                            NavigationLink {
                                // Navigate to the Set Editor View
                                TemplateSetEditorView(templateExercise: $te)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(te.exercise.name ?? "Unknown Exercise").font(.headline)
                                    Text("\(te.sets.count) Sets Defined")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .onDelete(perform: deleteExercise)
                        // .onMove(perform: moveExercise) // Reordering can be complex with CoreData linking, but basic state management is supported.
                    }

                    // Button to open the exercise selector sheet
                    Button {
                        showExercisePicker = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Exercise")
                        }
                    }
                }
            }
            .navigationTitle(template == nil ? "New Template" : "Edit Template")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(template == nil ? "Create" : "Save", action: saveTemplate)
                        .disabled(!isFormValid)
                }
            }
            // MARK: - Exercise Selection Sheet
            .sheet(isPresented: $showExercisePicker) {
                ExercisePickerSheet(exercisesInTemplate: $exercisesInTemplate)
            }
        }
    }
    
    // MARK: - CoreData Save Function
    private func saveTemplate() {
        let templateToSave: Workout
        
        if let existingTemplate = template {
            templateToSave = existingTemplate
            // Clear all existing sets associated with this template before saving new ones
            (templateToSave.sets as? Swift.Set<Set>)?.forEach(viewContext.delete)
        } else {
            templateToSave = Workout(context: viewContext)
            templateToSave.uuid = UUID()
            templateToSave.isTemplate = true // CRUCIAL
        }
        
        templateToSave.name = name
        
        // 1. Update the Exercise relationship (NSSet)
        let exercisesSet = NSSet(array: exercisesInTemplate.map { $0.exercise })
        templateToSave.exercise = exercisesSet
        
        // 2. Create and link new Set entities based on the TemplateSet structs
        let allSets = NSMutableSet()
        
        for templateExercise in exercisesInTemplate {
            for set in templateExercise.sets {
                let newSet = Set(context: viewContext)
                newSet.uuid = UUID()
                newSet.reps = Int16(set.reps)
                newSet.weight = set.weight
                newSet.rpe = set.rpe
                newSet.duration = Int16(set.duration)
                newSet.setType = set.setType.rawValue
                newSet.notes = set.notes
                
                // Link the Set to the Exercise and the Template (Workout)
                newSet.exercise = templateExercise.exercise
                newSet.workout = templateToSave
                
                allSets.add(newSet)
            }
        }
        
        // Set the final list of sets on the template
        templateToSave.sets = allSets
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error saving template: \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func deleteExercise(offsets: IndexSet) {
        exercisesInTemplate.remove(atOffsets: offsets)
    }
}
