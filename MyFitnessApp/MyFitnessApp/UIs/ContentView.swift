// ContentView
//
// Basic view baseline for appp
//
// Created by Dapo Folami

import SwiftUI

struct ContentView: View {
    
    // Get context from the environment
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
            
            // MARK: - Tab 2: Start Workout
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

// Preview for testing
#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
