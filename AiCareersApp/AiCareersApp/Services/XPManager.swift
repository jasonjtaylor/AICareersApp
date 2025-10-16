//
//  XPManager.swift
//  DreamPath
//
//  Created by Jason on 2025-10-15.
//

import Foundation
import SwiftData
import Combine

@MainActor
class XPManager: ObservableObject {
    private let modelContext: ModelContext

    // Level curve: L1=0XP, L2=100XP, L3=250XP, L4=450XP, L5=700XP, L6=1000XP...
    private let levelCurve: [Int] = [0, 100, 250, 450, 700, 1000, 1350, 1750, 2200, 2700, 3250]

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func computeLevel(totalXP: Int) -> Int {
        for (index, xpRequired) in levelCurve.enumerated() {
            if totalXP < xpRequired { return index }
        }
        return levelCurve.count
    }

    func xpForNextLevel(currentLevel: Int, totalXP: Int) -> Int {
        let nextLevel = currentLevel + 1
        guard nextLevel < levelCurve.count else { return 0 }
        let xpRequired = levelCurve[nextLevel]
        return max(0, xpRequired - totalXP)
    }

    func xpProgressForCurrentLevel(currentLevel: Int, totalXP: Int) -> Double {
        guard currentLevel > 0 && currentLevel < levelCurve.count else { return 0.0 }
        let currentLevelXP = levelCurve[currentLevel - 1]
        let nextLevelXP = levelCurve[currentLevel]
        let progressXP = totalXP - currentLevelXP
        let levelRange = nextLevelXP - currentLevelXP
        return Double(progressXP) / Double(levelRange)
    }

    func awardXP(to profile: UserProfile, reason: XPAwardReason, amount: Int? = nil) {
        let xpAmount = amount ?? reason.defaultAmount
        profile.totalXP += xpAmount
        profile.level = computeLevel(totalXP: profile.totalXP)

        // Check for level up
        if xpAmount > 0 {
            checkForLevelUp(profile: profile)
        }

        try? modelContext.save()
    }

    private func checkForLevelUp(profile: UserProfile) {
        let newLevel = computeLevel(totalXP: profile.totalXP)
        if newLevel > profile.level {
            profile.totalXP += 50 // bonus for leveling up
            profile.level = newLevel
            print("🎉 Level up! Now level \(newLevel)")
        }
    }

    func unlockBadge(for profile: UserProfile, badgeId: String) {
        // If badge already exists, just unlock & award XP
        if let existingBadge = profile.badges.first(where: { $0.id == badgeId }) {
            if !existingBadge.isUnlocked {
                existingBadge.isUnlocked = true
                existingBadge.unlockedAt = Date()
                awardXP(to: profile, reason: .badgeUnlock, amount: existingBadge.xpReward)
            }
        } else {
            // Create a new badge
            let badge = Badge(
                id: badgeId,
                name: getBadgeName(for: badgeId),
                details: getBadgeDescription(for: badgeId),
                iconName: getBadgeIcon(for: badgeId),
                xpReward: getBadgeXPReward(for: badgeId)
            )
            badge.isUnlocked = true
            badge.unlockedAt = Date()

            profile.badges.append(badge)
            awardXP(to: profile, reason: .badgeUnlock, amount: badge.xpReward)
        }

        try? modelContext.save()
    }

    func checkBadgeUnlocks(for profile: UserProfile) {
        // Explorer badge - viewed 5 careers
        if profile.completedCareers.count >= 5 {
            unlockBadge(for: profile, badgeId: "explorer")
        }
        // Scholar badge - complete 3 Learn steps (would be tracked in Progress)
        // Streaker badge - 5 day streak
        if profile.streakCount >= 5 {
            unlockBadge(for: profile, badgeId: "streaker")
        }
        // Analyst badge - complete 3 quizzes (track elsewhere)
    }

    // MARK: - Badge Information

    private func getBadgeName(for badgeId: String) -> String {
        switch badgeId {
        case "explorer": return "Explorer"
        case "scholar": return "Scholar"
        case "creator": return "Creator"
        case "streaker": return "Streaker"
        case "analyst": return "Analyst"
        case "helper": return "Helper"
        default: return "Achievement"
        }
    }

    private func getBadgeDescription(for badgeId: String) -> String {
        switch badgeId {
        case "explorer": return "Explored 5 different careers"
        case "scholar": return "Completed 3 learning activities"
        case "creator": return "Tried a creative career path"
        case "streaker": return "Maintained a 5-day streak"
        case "analyst": return "Completed 3 career quizzes"
        case "helper": return "Explored helping careers"
        default: return "Earned a special achievement"
        }
    }

    private func getBadgeIcon(for badgeId: String) -> String {
        switch badgeId {
        case "explorer": return "binoculars.fill"
        case "scholar": return "book.fill"
        case "creator": return "paintbrush.fill"
        case "streaker": return "flame.fill"
        case "analyst": return "chart.bar.fill"
        case "helper": return "heart.fill"
        default: return "star.fill"
        }
    }

    private func getBadgeXPReward(for badgeId: String) -> Int {
        switch badgeId {
        case "explorer": return 100
        case "scholar": return 150
        case "creator": return 200
        case "streaker": return 300
        case "analyst": return 150
        case "helper": return 100
        default: return 50
        }
    }
}

enum XPAwardReason {
    case quizCompletion
    case questStep
    case dailyStreak
    case firstExplore
    case careerPathComplete
    case badgeUnlock
    case levelUp

    var defaultAmount: Int {
        switch self {
        case .quizCompletion: return 100
        case .questStep: return 50
        case .dailyStreak: return 25
        case .firstExplore: return 10
        case .careerPathComplete: return 200
        case .badgeUnlock: return 0 // handled separately
        case .levelUp: return 50
        }
    }
}

