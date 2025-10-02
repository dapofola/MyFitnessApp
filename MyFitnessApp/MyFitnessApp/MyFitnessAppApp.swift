import SwiftUI

// MARK: - Custom Color Extension (NEW ADDITION)
extension Color {
    // A nice, soft Blue for the primary accent
    static let fitnessAccent = Color(red: 141/255, green: 65/255, blue: 0, opacity: 1.0)
    // Light gray for subtle backgrounds on text fields/containers
    static let containerBackground = Color(red: 1, green: 1, blue: 1, opacity: 1.0)
}

@main
struct MyFitnessAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                // APPLY GLOBAL ACCENT COLOR
                .tint(.fitnessAccent)
        }
    }
}
