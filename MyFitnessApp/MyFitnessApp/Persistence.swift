// Persistence
//
// Prepopulate app wit common templates and exercises for suers
//
// Created by Dapo Folami

import CoreData
import SwiftUI

// MARK: - Sample Data Structures (for seedDefaultData)

private struct SampleExerciseData {
    let name: String
    let bodyRegion: BodyRegion
    let movementType: MovementType
    let primaryMuscleGroup: PrimaryMuscleGroup
    let equipment: Equipment
}

// 1. Over 100 Sample Exercises
private let allSampleExercises: [SampleExerciseData] = [
    // --- Chest/Push (15) ---
    .init(name: "Barbell Bench Press", bodyRegion: .upper, movementType: .compound, primaryMuscleGroup: .chest, equipment: .barbell),
    .init(name: "Incline Dumbbell Press", bodyRegion: .upper, movementType: .push, primaryMuscleGroup: .chest, equipment: .dumbbell),
    .init(name: "Cable Fly", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .chest, equipment: .cable),
    .init(name: "Push Up", bodyRegion: .upper, movementType: .push, primaryMuscleGroup: .chest, equipment: .bodyweight),
    .init(name: "Dumbbell Pullover", bodyRegion: .upper, movementType: .pull, primaryMuscleGroup: .chest, equipment: .dumbbell),
    .init(name: "Machine Pec Dec", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .chest, equipment: .machine),
    .init(name: "Decline Barbell Press", bodyRegion: .upper, movementType: .push, primaryMuscleGroup: .chest, equipment: .barbell),
    .init(name: "Dumbbell Hex Press", bodyRegion: .upper, movementType: .push, primaryMuscleGroup: .chest, equipment: .dumbbell),
    .init(name: "Cable Crossover (High)", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .chest, equipment: .cable),
    .init(name: "Svend Press", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .chest, equipment: .other),
    .init(name: "Weighted Dips", bodyRegion: .upper, movementType: .compound, primaryMuscleGroup: .chest, equipment: .bodyweight),
    .init(name: "Smith Machine Press", bodyRegion: .upper, movementType: .push, primaryMuscleGroup: .chest, equipment: .machine),
    .init(name: "Landmine Press", bodyRegion: .upper, movementType: .push, primaryMuscleGroup: .chest, equipment: .barbell),
    .init(name: "Floor Press", bodyRegion: .upper, movementType: .push, primaryMuscleGroup: .chest, equipment: .barbell),
    .init(name: "One-Arm Dumbbell Press", bodyRegion: .upper, movementType: .push, primaryMuscleGroup: .chest, equipment: .dumbbell),
    
    // --- Back/Pull (25) ---
    .init(name: "Barbell Row", bodyRegion: .upper, movementType: .compound, primaryMuscleGroup: .back, equipment: .barbell),
    .init(name: "Pull Up (Weighted)", bodyRegion: .upper, movementType: .compound, primaryMuscleGroup: .back, equipment: .bodyweight),
    .init(name: "Lat Pulldown (Wide Grip)", bodyRegion: .upper, movementType: .pull, primaryMuscleGroup: .back, equipment: .cable),
    .init(name: "T-Bar Row", bodyRegion: .upper, movementType: .compound, primaryMuscleGroup: .back, equipment: .machine),
    .init(name: "Deadlift (Conventional)", bodyRegion: .fullBody, movementType: .compound, primaryMuscleGroup: .back, equipment: .barbell),
    .init(name: "Seated Cable Row", bodyRegion: .upper, movementType: .pull, primaryMuscleGroup: .back, equipment: .cable),
    .init(name: "Dumbbell Shrugs", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .back, equipment: .dumbbell),
    .init(name: "Hyperextension", bodyRegion: .lower, movementType: .isolation, primaryMuscleGroup: .back, equipment: .bodyweight),
    .init(name: "Face Pull", bodyRegion: .upper, movementType: .pull, primaryMuscleGroup: .back, equipment: .cable),
    .init(name: "Straight Arm Pulldown", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .back, equipment: .cable),
    .init(name: "Incline Bench Dumbbell Row", bodyRegion: .upper, movementType: .pull, primaryMuscleGroup: .back, equipment: .dumbbell),
    .init(name: "Reverse Grip Barbell Row", bodyRegion: .upper, movementType: .pull, primaryMuscleGroup: .back, equipment: .barbell),
    .init(name: "Single Arm Dumbbell Row", bodyRegion: .upper, movementType: .pull, primaryMuscleGroup: .back, equipment: .dumbbell),
    .init(name: "Chest Supported Row", bodyRegion: .upper, movementType: .pull, primaryMuscleGroup: .back, equipment: .machine),
    .init(name: "V-Bar Pulldown", bodyRegion: .upper, movementType: .pull, primaryMuscleGroup: .back, equipment: .cable),
    .init(name: "Kroc Row", bodyRegion: .upper, movementType: .pull, primaryMuscleGroup: .back, equipment: .dumbbell),
    .init(name: "Deficit Deadlift", bodyRegion: .fullBody, movementType: .compound, primaryMuscleGroup: .back, equipment: .barbell),
    .init(name: "Rack Pull", bodyRegion: .fullBody, movementType: .compound, primaryMuscleGroup: .back, equipment: .barbell),
    .init(name: "Weighted Back Extension", bodyRegion: .lower, movementType: .isolation, primaryMuscleGroup: .back, equipment: .other),
    .init(name: "Good Morning", bodyRegion: .lower, movementType: .isolation, primaryMuscleGroup: .back, equipment: .barbell),
    .init(name: "Reverse Fly Machine", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .back, equipment: .machine),
    .init(name: "Rope Face Pull", bodyRegion: .upper, movementType: .pull, primaryMuscleGroup: .back, equipment: .cable),
    .init(name: "Australian Pull Up", bodyRegion: .upper, movementType: .pull, primaryMuscleGroup: .back, equipment: .bodyweight),
    .init(name: "Dumbbell Farmer's Walk", bodyRegion: .fullBody, movementType: .other, primaryMuscleGroup: .back, equipment: .dumbbell),
    .init(name: "Single-Arm Lat Pulldown", bodyRegion: .upper, movementType: .pull, primaryMuscleGroup: .back, equipment: .cable),
    
    // --- Legs (30) ---
    .init(name: "Barbell Squat (High Bar)", bodyRegion: .lower, movementType: .compound, primaryMuscleGroup: .quadriceps, equipment: .barbell),
    .init(name: "Leg Press", bodyRegion: .lower, movementType: .legs, primaryMuscleGroup: .quadriceps, equipment: .machine),
    .init(name: "Dumbbell Bulgarian Split Squat", bodyRegion: .lower, movementType: .legs, primaryMuscleGroup: .quadriceps, equipment: .dumbbell),
    .init(name: "Leg Extension", bodyRegion: .lower, movementType: .isolation, primaryMuscleGroup: .quadriceps, equipment: .machine),
    .init(name: "Sissy Squat", bodyRegion: .lower, movementType: .isolation, primaryMuscleGroup: .quadriceps, equipment: .bodyweight),
    .init(name: "Front Squat", bodyRegion: .lower, movementType: .compound, primaryMuscleGroup: .quadriceps, equipment: .barbell),
    .init(name: "Hack Squat Machine", bodyRegion: .lower, movementType: .legs, primaryMuscleGroup: .quadriceps, equipment: .machine),
    .init(name: "Walking Lunge (Dumbbell)", bodyRegion: .lower, movementType: .legs, primaryMuscleGroup: .quadriceps, equipment: .dumbbell),
    .init(name: "Step Up (Weighted)", bodyRegion: .lower, movementType: .legs, primaryMuscleGroup: .quadriceps, equipment: .other),
    .init(name: "Pistol Squat Progression", bodyRegion: .lower, movementType: .legs, primaryMuscleGroup: .quadriceps, equipment: .bodyweight),
    
    .init(name: "Romanian Deadlift (Barbell)", bodyRegion: .lower, movementType: .legs, primaryMuscleGroup: .hamstrings, equipment: .barbell),
    .init(name: "Lying Leg Curl", bodyRegion: .lower, movementType: .isolation, primaryMuscleGroup: .hamstrings, equipment: .machine),
    .init(name: "Glute Ham Raise (GHR)", bodyRegion: .lower, movementType: .isolation, primaryMuscleGroup: .hamstrings, equipment: .machine),
    .init(name: "Cable Pull Through", bodyRegion: .lower, movementType: .legs, primaryMuscleGroup: .hamstrings, equipment: .cable),
    .init(name: "Stiff Legged Deadlift (Dumbbell)", bodyRegion: .lower, movementType: .legs, primaryMuscleGroup: .hamstrings, equipment: .dumbbell),
    .init(name: "Single Leg RDL (Dumbbell)", bodyRegion: .lower, movementType: .legs, primaryMuscleGroup: .hamstrings, equipment: .dumbbell),
    .init(name: "Seated Leg Curl", bodyRegion: .lower, movementType: .isolation, primaryMuscleGroup: .hamstrings, equipment: .machine),
    .init(name: "Kettlebell Swing", bodyRegion: .fullBody, movementType: .compound, primaryMuscleGroup: .hamstrings, equipment: .other),
    .init(name: "Reverse Nordic Curl", bodyRegion: .lower, movementType: .isolation, primaryMuscleGroup: .hamstrings, equipment: .bodyweight),
    .init(name: "Banded Hamstring Curl", bodyRegion: .lower, movementType: .isolation, primaryMuscleGroup: .hamstrings, equipment: .other),
    
    .init(name: "Barbell Hip Thrust", bodyRegion: .lower, movementType: .compound, primaryMuscleGroup: .glutes, equipment: .barbell),
    .init(name: "Cable Glute Kickback", bodyRegion: .lower, movementType: .isolation, primaryMuscleGroup: .glutes, equipment: .cable),
    .init(name: "Glute Bridge (Weighted)", bodyRegion: .lower, movementType: .isolation, primaryMuscleGroup: .glutes, equipment: .other),
    .init(name: "Machine Abduction", bodyRegion: .lower, movementType: .isolation, primaryMuscleGroup: .glutes, equipment: .machine),
    .init(name: "Split Squat (Dumbbell)", bodyRegion: .lower, movementType: .legs, primaryMuscleGroup: .glutes, equipment: .dumbbell),
    
    .init(name: "Standing Calf Raise Machine", bodyRegion: .lower, movementType: .isolation, primaryMuscleGroup: .calves, equipment: .machine),
    .init(name: "Seated Calf Raise Machine", bodyRegion: .lower, movementType: .isolation, primaryMuscleGroup: .calves, equipment: .machine),
    .init(name: "Dumbbell Calf Raise", bodyRegion: .lower, movementType: .isolation, primaryMuscleGroup: .calves, equipment: .dumbbell),
    .init(name: "Bodyweight Calf Raise", bodyRegion: .lower, movementType: .isolation, primaryMuscleGroup: .calves, equipment: .bodyweight),
    .init(name: "Calf Press on Leg Press", bodyRegion: .lower, movementType: .isolation, primaryMuscleGroup: .calves, equipment: .machine),
    
    // --- Shoulders/Triceps (20) ---
    .init(name: "Overhead Press (Barbell)", bodyRegion: .upper, movementType: .compound, primaryMuscleGroup: .shoulders, equipment: .barbell),
    .init(name: "Dumbbell Lateral Raise", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .shoulders, equipment: .dumbbell),
    .init(name: "Cable Lateral Raise", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .shoulders, equipment: .cable),
    .init(name: "Face Pulls", bodyRegion: .upper, movementType: .pull, primaryMuscleGroup: .shoulders, equipment: .cable),
    .init(name: "Machine Shoulder Press", bodyRegion: .upper, movementType: .push, primaryMuscleGroup: .shoulders, equipment: .machine),
    .init(name: "Seated Dumbbell Press", bodyRegion: .upper, movementType: .push, primaryMuscleGroup: .shoulders, equipment: .dumbbell),
    .init(name: "Bent-Over Dumbbell Reverse Fly", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .shoulders, equipment: .dumbbell),
    .init(name: "Front Dumbbell Raise", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .shoulders, equipment: .dumbbell),
    .init(name: "Barbell Upright Row", bodyRegion: .upper, movementType: .pull, primaryMuscleGroup: .shoulders, equipment: .barbell),
    .init(name: "Shoulder Shrugs (Barbell)", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .shoulders, equipment: .barbell),
    
    .init(name: "Triceps Pushdown (Rope)", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .triceps, equipment: .cable),
    .init(name: "Overhead Triceps Extension (Dumbbell)", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .triceps, equipment: .dumbbell),
    .init(name: "Skullcrusher (EZ Bar)", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .triceps, equipment: .barbell),
    .init(name: "Close-Grip Bench Press", bodyRegion: .upper, movementType: .compound, primaryMuscleGroup: .triceps, equipment: .barbell),
    .init(name: "Triceps Kickback (Dumbbell)", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .triceps, equipment: .dumbbell),
    .init(name: "V-Bar Pushdown", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .triceps, equipment: .cable),
    .init(name: "Bench Dips", bodyRegion: .upper, movementType: .push, primaryMuscleGroup: .triceps, equipment: .bodyweight),
    .init(name: "Cable Overhead Extension", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .triceps, equipment: .cable),
    .init(name: "Single Arm Cable Pushdown", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .triceps, equipment: .cable),
    .init(name: "Floor Triceps Extension (Dumbbell)", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .triceps, equipment: .dumbbell),
    
    // --- Biceps/Forearms/Other (17) ---
    .init(name: "Barbell Curl", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .biceps, equipment: .barbell),
    .init(name: "Dumbbell Hammer Curl", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .biceps, equipment: .dumbbell),
    .init(name: "Cable Bicep Curl", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .biceps, equipment: .cable),
    .init(name: "Preacher Curl Machine", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .biceps, equipment: .machine),
    .init(name: "Concentration Curl", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .biceps, equipment: .dumbbell),
    .init(name: "Reverse Curl (Barbell)", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .forearms, equipment: .barbell),
    .init(name: "Wrist Curl (Dumbbell)", bodyRegion: .upper, movementType: .isolation, primaryMuscleGroup: .forearms, equipment: .dumbbell),
    .init(name: "Treadmill Running", bodyRegion: .cardio, movementType: .cardio, primaryMuscleGroup: .cardio, equipment: .machine),
    .init(name: "Elliptical Machine", bodyRegion: .cardio, movementType: .cardio, primaryMuscleGroup: .cardio, equipment: .machine),
    .init(name: "Rowing Machine", bodyRegion: .cardio, movementType: .cardio, primaryMuscleGroup: .cardio, equipment: .machine),
    .init(name: "Plank", bodyRegion: .core, movementType: .isolation, primaryMuscleGroup: .abs, equipment: .bodyweight),
    .init(name: "Crunches", bodyRegion: .core, movementType: .isolation, primaryMuscleGroup: .abs, equipment: .bodyweight),
    .init(name: "Hanging Leg Raise", bodyRegion: .core, movementType: .isolation, primaryMuscleGroup: .abs, equipment: .bodyweight),
    .init(name: "Bicycle Crunches", bodyRegion: .core, movementType: .isolation, primaryMuscleGroup: .abs, equipment: .bodyweight),
    .init(name: "Cable Ab Crunch", bodyRegion: .core, movementType: .isolation, primaryMuscleGroup: .abs, equipment: .cable),
    .init(name: "Weighted Russian Twist", bodyRegion: .core, movementType: .isolation, primaryMuscleGroup: .obliques, equipment: .other),
    .init(name: "Side Plank", bodyRegion: .core, movementType: .isolation, primaryMuscleGroup: .obliques, equipment: .bodyweight),
]

// 2. 15 Sample Templates
private let sampleTemplates: [(name: String, exercises: [String])] = [
    ("Beginner Full Body A", ["Barbell Squat (High Bar)", "Barbell Bench Press", "Barbell Row", "Overhead Press (Barbell)", "Plank"]),
    ("Beginner Full Body B", ["Romanian Deadlift (Barbell)", "Pull Up (Weighted)", "Incline Dumbbell Press", "Dumbbell Lateral Raise", "Crunches"]),
    ("PPL - Push Day", ["Barbell Bench Press", "Overhead Press (Barbell)", "Incline Dumbbell Press", "Triceps Pushdown (Rope)", "Dumbbell Lateral Raise", "Close-Grip Bench Press"]),
    ("PPL - Pull Day", ["Deadlift (Conventional)", "Barbell Row", "Lat Pulldown (Wide Grip)", "Barbell Curl", "Face Pull", "Dumbbell Shrugs"]),
    ("PPL - Leg Day", ["Barbell Squat (High Bar)", "Romanian Deadlift (Barbell)", "Leg Extension", "Lying Leg Curl", "Standing Calf Raise Machine", "Barbell Hip Thrust"]),
    ("Arnold - Chest/Back", ["Incline Dumbbell Press", "Barbell Bench Press", "T-Bar Row", "Pull Up (Weighted)", "Dumbbell Pullover", "Seated Cable Row"]),
    ("Arnold - Shoulders/Arms", ["Overhead Press (Barbell)", "Cable Lateral Raise", "Barbell Curl", "Triceps Pushdown (Rope)", "Dumbbell Hammer Curl", "Skullcrusher (EZ Bar)"]),
    ("Arnold - Legs/Core", ["Front Squat", "Leg Press", "Romanian Deadlift (Barbell)", "Glute Ham Raise (GHR)", "Hanging Leg Raise", "Weighted Russian Twist"]),
    ("Upper/Lower - Upper", ["Barbell Bench Press", "Barbell Row", "Overhead Press (Barbell)", "Single Arm Dumbbell Row", "Triceps Pushdown (Rope)", "Barbell Curl"]),
    ("Upper/Lower - Lower", ["Deadlift (Conventional)", "Barbell Hip Thrust", "Leg Extension", "Lying Leg Curl", "Standing Calf Raise Machine", "Cable Glute Kickback"]),
    ("Cardio Blast", ["Treadmill Running", "Elliptical Machine", "Rowing Machine"]),
    ("Core Stability", ["Plank", "Side Plank", "Mountain Climbers", "Bicycle Crunches", "Cable Ab Crunch"]),
    ("Powerlifting Block", ["Barbell Squat (High Bar)", "Barbell Bench Press", "Deadlift (Conventional)", "Overhead Press (Barbell)"]),
    ("Hypertrophy - Back & Bi", ["Lat Pulldown (Wide Grip)", "Seated Cable Row", "Incline Bench Dumbbell Row", "Barbell Curl", "Concentration Curl", "Reverse Curl (Barbell)"]),
    ("Hypertrophy - Chest & Tri", ["Decline Barbell Press", "Machine Pec Dec", "Cable Fly", "Close-Grip Bench Press", "Overhead Triceps Extension (Dumbbell)", "V-Bar Pushdown"]),
]

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        // Add sample data for preview
        result.seedDefaultData()
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MyFitnessApp")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { [weak self] (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }

            if !inMemory {
                self?.seedDefaultData()
            }
        })
    }

    // MARK: - Sample Data Seeding
    
    private func seedDefaultData() {
        let context = container.viewContext
        // Check if data already exists
        if (try? context.count(for: Exercise.fetchRequest())) ?? 0 > 0 {
            return
        }

        // --- 1. Exercises (100+ Total) ---
        var allCreatedExercises: [String: Exercise] = [:]
        
        for exerciseData in allSampleExercises {
            let ex = createExercise(
                context: context,
                name: exerciseData.name,
                bodyRegion: exerciseData.bodyRegion,
                movementType: exerciseData.movementType,
                primaryMuscleGroup: exerciseData.primaryMuscleGroup,
                equipment: exerciseData.equipment
            )
            allCreatedExercises[ex.name!] = ex
        }
        
        // --- 2. Templates (15 Total) ---
        for templateData in sampleTemplates {
            if let template = createWorkoutTemplate(context: context, name: templateData.name, exerciseNames: templateData.exercises, allExercises: allCreatedExercises) {
                // Apply a few default sets (3x10 or 3x6) to each exercise in the template
                let allSets = NSMutableSet()
                for exercise in (template.exercise?.allObjects as? [Exercise] ?? []) {
                    let isCardio = exercise.movementType == MovementType.cardio.rawValue
                    let setsToCreate = isCardio ? 1 : 3
                    
                    for _ in 0..<setsToCreate {
                        let reps = isCardio ? 0 : [6, 8, 10].randomElement()!
                        let weight = isCardio ? 0.0 : [30.0, 50.0, 70.0, 90.0].randomElement()!
                        let duration = isCardio ? [180, 300].randomElement()! : 0
                        
                        let set = createSet(
                            context: context,
                            workout: template, // Link set to the template
                            ex: exercise,
                            reps: reps,
                            weight: weight,
                            rpe: isCardio ? 0 : 7.5,
                            duration: duration,
                            setType: isCardio ? SetType.warmUp : SetType.normal // Use WarmUp for cardio sets
                        )
                        allSets.add(set)
                    }
                }
                template.sets = allSets
            }
        }
        
        // --- 3. History Workouts (5 Total, Reverse Chronological) ---
        
        let historyDates = [449, 448, 447, 445, 444].map { Calendar.current.date(byAdding: .day, value: -$0, to: Date())! }
        
        let historyWorkoutSpecs: [(name: String, date: Date, exercises: [String])] = [
            // Oldest: Full Body A
            (sampleTemplates[0].name, historyDates[0], sampleTemplates[0].exercises),
            // PPL - Push
            (sampleTemplates[2].name, historyDates[1], sampleTemplates[2].exercises),
            // PPL - Pull
            (sampleTemplates[3].name, historyDates[2], sampleTemplates[3].exercises),
            // PPL - Leg
            (sampleTemplates[4].name, historyDates[3], sampleTemplates[4].exercises),
            // Most Recent: Upper/Lower - Upper
            (sampleTemplates[8].name, historyDates[4], sampleTemplates[8].exercises),
        ]
        
        for spec in historyWorkoutSpecs {
            if let workout = createHistoryWorkout(context: context, name: spec.name, date: spec.date, exerciseNames: spec.exercises, allExercises: allCreatedExercises) {
                
                let allSets = NSMutableSet()
                for exercise in (workout.exercise?.allObjects as? [Exercise] ?? []) {
                    let setsToCreate = [3, 4].randomElement()!
                    
                    for _ in 0..<setsToCreate {
                        // Use slightly heavier weights for history to show progress
                        let weight = [40.0, 60.0, 80.0, 100.0, 120.0].randomElement()!
                        let reps = [5, 8, 10].randomElement()!
                        
                        let set = createSet(
                            context: context,
                            workout: workout, // Link set to the history workout
                            ex: exercise,
                            reps: reps,
                            weight: weight,
                            rpe: 8.0,
                            setType: SetType.normal
                        )
                        allSets.add(set)
                    }
                }
                workout.sets = allSets
            }
        }
    }

    // MARK: Exercise Creation Helper
    
    private func createExercise(context: NSManagedObjectContext, name: String, bodyRegion: BodyRegion, movementType: MovementType, primaryMuscleGroup: PrimaryMuscleGroup, equipment: Equipment, isCustom: Bool = false, notes: String? = nil) -> Exercise {
        let exercise = Exercise(context: context)
        exercise.uuid = UUID()
        exercise.name = name
        exercise.bodyRegion = bodyRegion.rawValue
        exercise.movementType = movementType.rawValue
        exercise.primaryMuscleGroup = primaryMuscleGroup.rawValue
        exercise.equipment = equipment.rawValue
        exercise.isCustom = isCustom
        exercise.notes = notes
        return exercise
    }
    
    // MARK: Workout/Template Creation Helpers

    private func createWorkoutTemplate(context: NSManagedObjectContext, name: String, exerciseNames: [String], allExercises: [String: Exercise]) -> Workout? {
        let workout = Workout(context: context)
        workout.uuid = UUID()
        workout.name = name
        workout.isTemplate = true // Mark as template

        let exercises: [Exercise] = exerciseNames.compactMap { allExercises[$0] }
        
        guard !exercises.isEmpty else { return nil }
        
        // Link exercises to the workout (Template)
        workout.exercise = NSSet(array: exercises)
        
        return workout
    }

    private func createHistoryWorkout(context: NSManagedObjectContext, name: String, date: Date, exerciseNames: [String], allExercises: [String: Exercise]) -> Workout? {
        let workout = Workout(context: context)
        workout.uuid = UUID()
        workout.name = name
        workout.isTemplate = false // Mark as history
        workout.date = date // Set the history date

        let exercises: [Exercise] = exerciseNames.compactMap { allExercises[$0] }
        
        guard !exercises.isEmpty else { return nil }
        
        // Link exercises to the workout (History)
        workout.exercise = NSSet(array: exercises)
        
        return workout
    }
    
    // MARK: Set Creation Helper
    
    private func createSet(context: NSManagedObjectContext, workout: Workout? = nil, ex: Exercise, reps: Int, weight: Double, rpe: Double, duration: Int = 0, setType: SetType, notes: String? = nil) -> Set {
        let set = Set(context: context)
        set.uuid = UUID()
        set.reps = Int16(reps)
        set.weight = weight
        set.rpe = rpe
        set.duration = Int16(duration)
        set.setType = setType.rawValue
        set.exercise = ex
        set.workout = workout // Link the set to the workout (for CoreData relationship)
        return set
    }
    
    // MARK: Exercise Fetch Helper (Kept for compatibility, though not used in new seed logic)

    private func fetchExercise(context: NSManagedObjectContext, name: String) -> Exercise? {
        let fetchRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.fetchLimit = 1
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Error fetching exercise \(name): \(error)")
            return nil
        }
    }
}
