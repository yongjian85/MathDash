//
//  MathDashApp.swift
//  MathDash
//
//  Created by yong jian on 2026-07-29.
//

import SwiftUI
import CoreData

@main
struct MathDashApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
