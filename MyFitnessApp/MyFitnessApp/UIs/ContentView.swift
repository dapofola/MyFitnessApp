import SwiftUI

struct ContentView: View {
    
    // Inject the managed object context from the environment
    // This is provided by MyFitnessAppApp.swift
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        TabView {
            // MARK: - Tab 1: Exercise View
            ExerciseListView()
                .tabItem {
                    Label("Exercises", systemImage: "dumbbell.fill")
                }
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarBackground(.bar, for: .tabBar)
                .toolbarBackground(Color(red: 1.0, green: 150/255, blue: 140/255, opacity: 0.05), for: .tabBar)
            
            // MARK: - Tab 2: Start Workout (UPDATED)
            StartWorkoutView()
                .tabItem {
                    Label("Start Workout", systemImage: "plus.circle.fill")
                }
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarBackground(.bar, for: .tabBar)
                .toolbarBackground(Color(red: 1.0, green: 150/255, blue: 140/255, opacity: 0.05), for: .tabBar)
            
            // MARK: - Tab 3: History View
            HistoryView() // <<< CHANGE: Replaced Text("Workout History") with HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .toolbarBackground(.visible, for: .tabBar, .navigationBar)
                .toolbarBackground(.bar, for: .tabBar, .navigationBar)
                .toolbarBackground(Color(red: 1.0, green: 150/255, blue: 140/255, opacity: 0.05), for: .tabBar)
            
            // MARK: - Tab 4: Templates View
            TemplateListView()
                .tabItem {
                    Label("Templates", systemImage: "list.clipboard.fill")
                }
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarBackground(.bar, for: .tabBar)
                .toolbarBackground(Color(red: 1.0, green: 150/255, blue: 140/255, opacity: 0.05), for: .tabBar)
        }
        .background(Color.black)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(.bar, for: .tabBar)
        .toolbarBackground(Color(red: 1.0, green: 150/255, blue: 140/255, opacity: 1.0), for: .tabBar)
        
    }
}

// ExerciseListView and other dependencies (like FilterSheet) remain in their own files.
// Add a simple ExerciseListView struct to avoid initial errors.
// We will replace this in Step 2.
/*struct ExerciseListView: View {
    var body: some View {
        NavigationView {
            Text("Loading Exercise List...")
                .navigationTitle("Exercises")
        }
    }
}*/

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
