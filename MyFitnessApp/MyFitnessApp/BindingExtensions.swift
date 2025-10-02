// BindingExtensions.swift
import SwiftUI

extension Binding where Value == Int16 {
    // Converts Binding<Int16> to Binding<Int>
    var toInt: Binding<Int> {
        return Binding<Int>(
            get: { Int(self.wrappedValue) },
            set: { self.wrappedValue = Int16($0) }
        )
    }
}
