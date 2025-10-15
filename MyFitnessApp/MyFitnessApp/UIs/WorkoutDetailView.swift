// WorkoutDetailView
//
// View for users to see details of previous workouts they've completed
//
// Created by Dapo Folami

import SwiftUI
import CoreData

struct WorkoutDetailView: View {
    @ObservedObject var workout: Workout
    
    // Sort sets based on exercise order within the workout, then by creation UUID
    private var setsByExercise: [Exercise: [Set]] {
        guard let allSets = workout.sets?.allObjects as? [Set] else { return [:] }
        
        var exerciseSetMap: [Exercise: [Set]] = [:]
        
        // Group all sets by their respective exercise
        for set in allSets {
            if let exercise = set.exercise {
                // Initialize the array if necessary
                if exerciseSetMap[exercise] == nil {
                    exerciseSetMap[exercise] = []
                }
                exerciseSetMap[exercise]?.append(set)
            }
        }
        
        // Sort the sets within each exercise by UUID
        for (exercise, sets) in exerciseSetMap {
            exerciseSetMap[exercise] = sets.sorted(by: { $0.uuid ?? UUID() < $1.uuid ?? UUID() })
        }
        
        return exerciseSetMap
    }
    
    var body: some View {
        List {
            // MARK: - Summary Header
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(workout.name ?? "Untitled Workout")
                        .font(.largeTitle.bold())
                    
                    Text(workout.date!, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Simple summary line
                    Text("\(workout.orderedExercises.count) exercises logged.")
                        .font(.caption)
                }
                .padding(.vertical, 8)
            }
            
            // MARK: - Exercise Breakdown
            Section("Exercises Logged") {
                ForEach(workout.orderedExercises, id: \.self) { exercise in
                    if let sets = setsByExercise[exercise], sets.count > 0 {
                        // Use DisclosureGroup for exercise/set grouping, read-only
                        DetailExerciseDisclosure(exercise: exercise, sets: sets)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Workout Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Read-only Disclosure Group for History
struct DetailExerciseDisclosure: View {
    @ObservedObject var exercise: Exercise
    var sets: [Set] // Already sorted for this exercise
    
    @State private var isExpanded = true

    private func setIndex(for set: Set) -> Int {
        return sets.firstIndex(of: set) ?? 0
    }
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(spacing: 0) {
                // Sets List
                ForEach(sets) { set in
                    DetailSetRowView(set: set, index: setIndex(for: set) + 1)
                        .padding(.horizontal, 1)
                        .padding(.vertical, 4)
                }
                .listRowSeparator(.visible, edges: .top)
            }
            .padding(.top, 4)
        } label: {
            HStack {
                Text(exercise.name ?? "Unknown Exercise")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(sets.count) Sets")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .listRowSeparator(.visible, edges: .top)
        .padding(.vertical, 4)
        .listRowBackground(Color(.systemBackground))
    }
}

// Read-only Set Row for History
struct DetailSetRowView: View {
    @ObservedObject var set: Set
    let index: Int
    
    var isDurationSet: Bool {
        return set.exercise?.movementType == MovementType.cardio.rawValue
    }
    
    var body: some View {
        HStack {
            // Set Number
            Text("Set \(index):")
                .font(.subheadline)
                .frame(width: 60, alignment: .leading)
            
            Spacer()
            
            // Reps/Time & Weight
            if isDurationSet {
                Text("\(set.duration)s")
            } else {
                Text("\(set.reps) reps @ \(String(format: "%.1f", set.weight)) kg")
            }
            
            // RPE
            if set.rpe > 0 {
                Text("| RPE: \(String(format: "%.1f", set.rpe))")
                    .foregroundColor(.orange)
            }
        }
        .font(.callout)
        
    }
}
