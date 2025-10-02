import SwiftUI
import CoreData

struct StartWorkoutView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // Fetch all available workout templates
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.name!, order: .forward)],
        predicate: NSPredicate(format: "isTemplate == YES")
    ) private var workoutTemplates: FetchedResults<Workout>

    // State to manage the active workout session
    @State private var showingActiveWorkout = false
    @State private var selectedTemplate: Workout? // nil for starting from scratch

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Start From Scratch
                Section {
                    Button {
                        // 1. Set template to nil (Start Blank)
                        selectedTemplate = nil
                        // 2. Present ActiveWorkoutView
                        showingActiveWorkout = true
                        
                    } label: {
                        HStack {
                            Image(systemName: "pencil.and.scribble")
                                .foregroundColor(.blue)
                            Text("Start Blank Workout")
                                .foregroundColor(Color(red: 141/255, green: 65/255, blue: 0, opacity: 1.0))
                                .font(.system(size: 30))
                        }
                        
                    }
                }


                // MARK: - Start From Template
                if workoutTemplates.count > 0 {
                    Section("Templates") {
                        ForEach(workoutTemplates) { template in
                            Button {
                                // 1. Set the selected template
                                selectedTemplate = template
                                // 2. Present ActiveWorkoutView
                                showingActiveWorkout = true
                            } label: {
                                TemplateRowView(template: template)
                            }
                        }
                    }
                }
            }
            //.navigationTitle("Start Workout")
            .fullScreenCover(isPresented: $showingActiveWorkout) {
                // LINE 70: This is the updated line to show ActiveWorkoutView
                ActiveWorkoutView(template: selectedTemplate, context: viewContext)
            }
        }
    }
}

// Sub-view for displaying a template row
struct TemplateRowView: View {
    @ObservedObject var template: Workout
    
    // Quick count of unique exercises in the template
    var exerciseCount: Int {
        return (template.exercise as? Swift.Set<Exercise>)?.count ?? 0
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(template.name ?? "Untitled Template")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("\(exerciseCount) Exercises")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
    }
}
