import SwiftUI
import CoreData

struct TemplateListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch only workouts marked as templates
    // NOTE: This fetch requires 'isTemplate' to be added to the Workout CoreData model.
    @FetchRequest(
        entity: Workout.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Workout.name, ascending: true)],
        predicate: NSPredicate(format: "isTemplate == YES")
    ) private var templates: FetchedResults<Workout>
    
    @State private var showCreateTemplateSheet: Bool = false

    var body: some View {
        NavigationView {
            List {
                ForEach(templates) { template in
                    // NavigationLink to edit the template
                    NavigationLink {
                        // We will define this view next.
                        CreateEditTemplateView(template: template)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(template.name ?? "Untitled Template")
                                .font(.headline)
                            
                            // Safely unwrap and count the exercises relationship
                            // NOTE: Assumes 'exercise' is an NSSet property on Workout
                            let exerciseCount = (template.exercise as? Swift.Set<Exercise>)?.count ?? 0
                            
                            if exerciseCount > 0 {
                                Text("\(exerciseCount) Exercises")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Empty Template")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteTemplates)
            }
            .navigationTitle("Templates")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreateTemplateSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            // Sheet for creating a new template
            .sheet(isPresented: $showCreateTemplateSheet) {
                CreateEditTemplateView() // No template passed = creating new
            }
        }
    }
    
    private func deleteTemplates(offsets: IndexSet) {
        withAnimation {
            offsets.map { templates[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error deleting template \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
