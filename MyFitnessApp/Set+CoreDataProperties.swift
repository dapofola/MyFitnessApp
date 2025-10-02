//
//  Set+CoreDataProperties.swift
//  MyFitnessApp
//
//  Created by Dapo Folami on 2025-07-28.
//
//

import Foundation
import CoreData


extension Set {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Set> {
        return NSFetchRequest<Set>(entityName: "Set")
    }
    
    @NSManaged public var duration: Int16
    @NSManaged public var notes: String?
    @NSManaged public var reps: Int16
    @NSManaged public var rpe: Double
    @NSManaged public var setType: String?
    @NSManaged public var uuid: UUID?
    @NSManaged public var weight: Double
    @NSManaged public var exercise: Exercise?
    @NSManaged public var workout: Workout?

}

extension Set : Identifiable {

}
