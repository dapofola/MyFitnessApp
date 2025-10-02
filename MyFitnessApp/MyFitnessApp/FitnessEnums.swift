//
//  FitnessEnums.swift
//  MyFitnessApp
//

import Foundation

// MARK: - Classification Enums

enum BodyRegion: String, CaseIterable, Identifiable {
    case upper = "Upper Body"
    case lower = "Lower Body"
    case fullBody = "Full Body"
    case core = "Core"
    case cardio = "Cardio"
    case other = "Other"

    var id: String { self.rawValue }
}

enum MovementType: String, CaseIterable, Identifiable {
    case push = "Push"
    case pull = "Pull"
    case legs = "Legs"
    case compound = "Compound"
    case isolation = "Isolation"
    case cardio = "Cardio"
    case other = "Other"

    var id: String { self.rawValue }

    // Helper 1: Filters Movement Types based on Body Region (Used in CreateExerciseView)
    static func types(for bodyRegion: BodyRegion) -> [MovementType] {
        switch bodyRegion {
        case .upper:
            return [.push, .pull, .compound, .isolation, .other]
        case .lower:
            return [.legs, .compound, .isolation, .other]
        case .fullBody:
            return [.compound, .other]
        case .core:
            return [.isolation, .compound, .other]
        case .cardio:
            return [.cardio]
        case .other:
            return MovementType.allCases.filter { $0 != .cardio }
        }
    }

    // Helper 2: Filters Primary Muscle Groups based on Movement Type (Used in CreateExerciseView & potentially ExerciseListView)
    // This is the function that must be defined here, NOT on PrimaryMuscleGroup.
    static func groups(for movementType: MovementType) -> [PrimaryMuscleGroup] {
        switch movementType {
        case .push:
            return [.chest, .shoulders, .triceps, .other]
        case .pull:
            return [.back, .biceps, .forearms, .other]
        case .legs:
            return [.quadriceps, .hamstrings, .glutes, .calves, .other]
        case .compound:
            return [.fullBody, .chest, .back, .shoulders, .quadriceps, .hamstrings, .glutes, .abs, .other]
        case .isolation:
            return [.biceps, .triceps, .shoulders, .chest, .back, .quadriceps, .hamstrings, .glutes, .calves, .abs, .obliques, .forearms, .other]
        case .cardio:
            return [.cardio]
        case .other:
            // Filter out cardio and fullBody, as they're usually implied by the filters
            return PrimaryMuscleGroup.allCases.filter { $0 != .cardio && $0 != .fullBody }
        }
    }
}

enum PrimaryMuscleGroup: String, CaseIterable, Identifiable {
    // Upper Body
    case chest = "Chest"
    case triceps = "Triceps"
    case shoulders = "Shoulders"
    case back = "Back"
    case biceps = "Biceps"
    case forearms = "Forearms"
    // Lower Body
    case quadriceps = "Quadriceps"
    case hamstrings = "Hamstrings"
    case glutes = "Glutes"
    case calves = "Calves"
    // Core/Other
    case abs = "Abs"
    case obliques = "Obliques"
    case fullBody = "Full Body"
    case cardio = "Cardio"
    case other = "Other"

    var id: String { self.rawValue }
}

enum Equipment: String, CaseIterable, Identifiable {
    case barbell = "Barbell"
    case dumbbell = "Dumbbell"
    case machine = "Machine"
    case cable = "Cable"
    case bodyweight = "Bodyweight"
    case other = "Other"

    var id: String { self.rawValue }
}

// MARK: - Set Enums

enum SetType: String, CaseIterable, Identifiable {
    case normal = "Normal"
    case warmUp = "Warm-up"
    case dropSet = "Drop Set"
    case failure = "To Failure"
    case superSet = "Superset"
    case giantSet = "Giant Set"
    case pyramid = "Pyramid"
    case custom = "Custom"
    case unknown = "Unknown"

    var id: String { self.rawValue }
}
