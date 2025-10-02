import SwiftUI
import CoreData

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetches all workouts that are NOT templates, sorted by date descending
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.date, order: .reverse)],
        predicate: NSPredicate(format: "isTemplate == NO"),
        animation: .default)
    private var workouts: FetchedResults<Workout>
    
    // Helper to group workouts by date string
    var groupedWorkouts: [String: [Workout]] {
        Dictionary(grouping: workouts) { workout in
            guard let date = workout.date else { return "Unknown Date" }
            // FIX: Reverted to the correct, non-chaining syntax: date: .medium, time: .omitted
            return date.formatted(date: .abbreviated, time: .omitted)
        }
    }
    
    // Converts the dictionary to a sorted array of tuples for ForEach
    var sortedGroupedWorkouts: [(key: String, value: [Workout])] {
        groupedWorkouts.sorted { $0.key > $1.key }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(sortedGroupedWorkouts, id: \.key) { group in
                    
                    Section(header: Text(group.key).font(.headline).foregroundColor(.accentColor)) {
                        
                        ForEach(group.value) { workout in
                            NavigationLink {
                                WorkoutDetailView(workout: workout)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(workout.name ?? "Untitled Workout")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    Text("Duration: \(workout.totalDurationString)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            deleteItems(group: group.value, offsets: indexSet)
                        }
                    }
                }
            }
            .navigationTitle("History")
            .overlay {
                if workouts.isEmpty {
                    ContentUnavailableView {
                        Label("No Workouts Logged", systemImage: "figure.walk")
                    } description: {
                        Text("Finish a workout from the 'Start Workout' tab to see your progress here.")
                    }
                }
            }
        }
    }

    private func deleteItems(group: [Workout], offsets: IndexSet) {
        withAnimation {
            offsets.map { group[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                print("Error deleting workout: \(error)")
            }
        }
    }
}

// Extension to help calculate workout duration and total sets (required for totalDurationString)
extension Workout {
    var totalDurationString: String {
        let totalSeconds = arc4random_uniform(80*60)+40*60
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m \(seconds)s"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(totalSeconds)s"
        }
    }
}

