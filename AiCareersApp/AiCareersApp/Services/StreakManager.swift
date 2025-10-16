//
//  StreakManager.swift
//  DreamPath
//
//  Created by Jason on 2025-10-15.
//

import Foundation
import SwiftData
import Combine

@MainActor
class StreakManager: ObservableObject {
    @Published var currentStreak: Int = 0
    @Published var lastActiveDate: Date = .init()

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadStreakData()
    }

    private func loadStreakData() {
        // Load from UserDefaults for now, could be moved to SwiftData
        currentStreak = UserDefaults.standard.integer(forKey: "currentStreak")

        if let lastActive = UserDefaults.standard.object(forKey: "lastActiveDate") as? Date {
            lastActiveDate = lastActive
        }
    }

    func incrementIfNewDay() -> Bool {
        let calendar = Calendar.current
        let today = Date()

        // Check if it's a new day since last activity
        if !calendar.isDate(lastActiveDate, inSameDayAs: today) {
            // Check if it's consecutive (yesterday)
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

            if calendar.isDate(lastActiveDate, inSameDayAs: yesterday) {
                // Consecutive day - increment streak
                currentStreak += 1
            } else {
                // Not consecutive - reset streak
                currentStreak = 1
            }

            lastActiveDate = today

            // Save to UserDefaults
            UserDefaults.standard.set(currentStreak, forKey: "currentStreak")
            UserDefaults.standard.set(lastActiveDate, forKey: "lastActiveDate")

            return true
        }

        return false
    }

    func updateProfileStreak(_ profile: UserProfile) {
        if incrementIfNewDay() {
            profile.streakCount = currentStreak
            profile.lastActiveAt = lastActiveDate
            try? modelContext.save()
        }
    }

    func resetStreak() {
        currentStreak = 0
        lastActiveDate = Date()

        UserDefaults.standard.set(currentStreak, forKey: "currentStreak")
        UserDefaults.standard.set(lastActiveDate, forKey: "lastActiveDate")
    }

    func getStreakMessage() -> String {
        switch currentStreak {
        case 0:
            return "Start your journey today!"
        case 1:
            return "Great start! Keep it going!"
        case 2 ... 4:
            return "You're on fire! 🔥"
        case 5 ... 9:
            return "Amazing streak! You're unstoppable!"
        case 10...:
            return "Incredible! You're a DreamPath champion! 🏆"
        default:
            return "Keep exploring!"
        }
    }
}
