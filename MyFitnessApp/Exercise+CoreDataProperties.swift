//
//  Exercise+CoreDataProperties.swift
//  MyFitnessApp
//
//  Created by Dapo Folami on 2025-07-28.
//
//

import Foundation
import CoreData


extension Exercise {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exercise> {
        return NSFetchRequest<Exercise>(entityName: "Exercise")
    }

    @NSManaged public var bodyRegion: String?
    @NSManaged public var equipment: String?
    @NSManaged public var isCustom: Bool
    @NSManaged public var movementType: String?
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var primaryMuscleGroup: String?
    @NSManaged public var uuid: UUID?
    @NSManaged public var set: NSSet?
    @NSManaged public var workout: NSSet?

}

// MARK: Generated accessors for set
extension Exercise {

    @objc(addSetObject:)
    @NSManaged public func addToSet(_ value: Set)

    @objc(removeSetObject:)
    @NSManaged public func removeFromSet(_ value: Set)

    @objc(addSet:)
    @NSManaged public func addToSet(_ values: NSSet)

    @objc(removeSet:)
    @NSManaged public func removeFromSet(_ values: NSSet)

}

// MARK: Generated accessors for workout
extension Exercise {

    @objc(addWorkoutObject:)
    @NSManaged public func addToWorkout(_ value: Workout)

    @objc(removeWorkoutObject:)
    @NSManaged public func removeFromWorkout(_ value: Workout)

    @objc(addWorkout:)
    @NSManaged public func addToWorkout(_ values: NSSet)

    @objc(removeWorkout:)
    @NSManaged public func removeFromWorkout(_ values: NSSet)

}

extension Exercise : Identifiable {

}
