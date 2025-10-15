import SwiftUI

// MARK: - Custom Color Extension
extension Color {
    static let fitnessAccent = Color(red: 141/255, green: 65/255, blue: 0, opacity: 1.0)
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
