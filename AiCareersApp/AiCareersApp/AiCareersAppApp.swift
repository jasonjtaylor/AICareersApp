//
//  AiCareersAppApp.swift
//  DreamPath
//
//  Created by Jason on 2025-10-15.
//

import SwiftData
import SwiftUI

// Import the models explicitly
// UserProfile, Progress, and Badge are defined in UserProfile.swift

@main
struct DreamPathApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(
                for: UserProfile.self, 
                Progress.self, 
                Badge.self
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
    }
}
