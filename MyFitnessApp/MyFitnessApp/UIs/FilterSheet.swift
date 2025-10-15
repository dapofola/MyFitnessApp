// FilterSheet
//
// Sheet to add filter to the exercise list view
//
// Created by Dapo Folami

import SwiftUI

struct FilterSheet: View {
    @Binding var selectedBodyRegion: BodyRegion?
    @Binding var selectedMovementType: MovementType?
    @Binding var selectedMuscleGroup: PrimaryMuscleGroup?
    
    @Environment(\.dismiss) var dismiss

    // MARK: - Computed Properties to Resolve buildExpression Error
    
    private var availableMovementTypes: [MovementType] {
        if let region = selectedBodyRegion {
            return MovementType.types(for: region)
        } else {
            // If no region is selected, show all general types (excluding Cardio)
            return MovementType.allCases.filter { $0 != .cardio }
        }
    }
    
    private var availableMuscleGroups: [PrimaryMuscleGroup] {
        if let movement = selectedMovementType {
            return MovementType.groups(for: movement)
        } else {
            // If no movement is selected, show all
            return PrimaryMuscleGroup.allCases
        }
    }

    var body: some View {
        NavigationView {
            Form {
                // MARK: - Body Region Filter
                Section("Body Region") {
                    Picker("Select Region", selection: $selectedBodyRegion) {
                        Text("All").tag(nil as BodyRegion?)
                        ForEach(BodyRegion.allCases) { region in
                            Text(region.rawValue).tag(region as BodyRegion?)
                        }
                    }
                }
                
                // MARK: - Movement Type Filter
                Section("Movement Type") {
                    Picker("Select Movement", selection: $selectedMovementType) {
                        Text("All").tag(nil as MovementType?)
                        
                        // Use the pre-computed property here
                        ForEach(availableMovementTypes) { movement in
                            Text(movement.rawValue).tag(movement as MovementType?)
                        }
                    }
                    .onChange(of: selectedBodyRegion) {
                        if let region = selectedBodyRegion,
                           let movement = selectedMovementType,
                           !MovementType.types(for: region).contains(movement) {
                            selectedMovementType = nil
                        }
                    }
                }
                
                // MARK: - Primary Muscle Group Filter
                Section("Primary Muscle Group") {
                    Picker("Select Group", selection: $selectedMuscleGroup) {
                        Text("All").tag(nil as PrimaryMuscleGroup?)
                        
                        // Use the pre-computed property here
                        ForEach(availableMuscleGroups) { group in
                            Text(group.rawValue).tag(group as PrimaryMuscleGroup?)
                        }
                    }
                    // Fix 2: Update onChange to iOS 17 standard and implement logic
                    .onChange(of: selectedMovementType) {
                        if let movement = selectedMovementType,
                           let muscle = selectedMuscleGroup,
                           !MovementType.groups(for: movement).contains(muscle) {
                            selectedMuscleGroup = nil
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            // The previous, reliable fix for the toolbar ambiguity
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}
